## [Mirroring](https://istio.io/latest/docs/tasks/traffic-management/mirroring/)

Send a single request to multiple services.

Traffic mirroring, also called shadowing, is a powerful concept that allows feature teams to bring changes to production with as little risk as possible. Mirroring sends a copy of live traffic to a mirrored service. The mirrored traffic happens out of band of the critical request path for the primary service.

In this step, you will first force all traffic to v1 that comes from a test client. Then, you will apply a rule to mirror a portion of the traffic to v2.

We'll create a separate namespace for experimenting with mirror.

```sh
$ kubectl create namespace mirror
```

The default namespace is already labeled with `istio-injection=enabled`, which will cause conflicts with the command-line injection technique used in the following instructions.

**httpbin V1 and V2**

Each application records each access event to their logs. Deploy the two versions of the httpbin service.

```sh
# httpbin-v1
cat <<EOF | istioctl kube-inject -f - | kubectl create -n mirror -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin-v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v1
  template:
    metadata:
      labels:
        app: httpbin
        version: v1
    spec:
      containers:
      - image: kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin
        command: ["gunicorn", "--access-logfile", "-", "-b", "0.0.0.0:80", "httpbin:app"]
        ports:
        - containerPort: 80  
EOF
# httpbin-v2:
cat <<EOF | istioctl kube-inject -f - | kubectl create -n mirror -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin-v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v2
  template:
    metadata:
      labels:
        app: httpbin
        version: v2
    spec:
      containers:
      - image: kennethreitz/httpbin
        imagePullPolicy: IfNotPresent
        name: httpbin
        command: ["gunicorn", "--access-logfile", "-", "-b", "0.0.0.0:80", "httpbin:app"]
        ports:
        - containerPort: 80
EOF
```

Front the v1 and v2 deployments with a httpbin Kubernetes service. The service matches on the same label selector of each deployment.

```sh
$ kubectl create -n mirror -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: httpbin
  labels:
    app: httpbin
spec:
  ports:
  - name: http
    port: 8000
    targetPort: 80
  selector:
    app: httpbin
EOF
```

Start the sleep pod so you can use its curl utility to provide load.

```sh
# Failed to pull image "tutum/curl": rpc error: code = Unknown desc = Error response from daemon: pull access denied for tutum/curl, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
$ cat <<EOF | istioctl kube-inject -f - | kubectl create -n mirror -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sleep
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sleep
  template:
    metadata:
      labels:
        app: sleep
    spec:
      containers:
      - name: sleep
        image: tutum/curl
        command: ["/bin/sleep","infinity"]
        imagePullPolicy: IfNotPresent
EOF
```

Wait for all three pods to report running.

```sh
$ kubectl get pods -n mirror
```

**Creating a Default Routing Policy**

By default, Kubernetes load balances across both versions of the httpbin service. In this step, you will change that behavior so that all traffic goes to v1.

```sh
# Create a default route rule to route all traffic to v1 of the service
$ kubectl apply -n mirror -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
    - httpbin
  http:
  - route:
    - destination:
        host: httpbin
        subset: v1
      weight: 100
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: httpbin
spec:
  host: httpbin
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
EOF
```

Now all traffic goes to the httpbin:v1 service.

**Generate Traffic, Inspect Logs**

```sh
# Find the name of the sleep pod:
$ SLEEP_POD=$(kubectl get pod -n mirror -l app=sleep -o jsonpath={.items..metadata.name}) && echo "SLEEP_POD=$SLEEP_POD"
# From the sleep pod, send some traffic to the service:
$ kubectl exec "${SLEEP_POD}" -n mirror -c sleep -- curl -s http://httpbin:8000/headers
# Get the names of the v1 and v2 httpbin pods
$ V1_POD=$(kubectl get pod -n mirror -l app=httpbin,version=v1 -o jsonpath={.items..metadata.name}) && export V2_POD=$(kubectl get pod -n mirror -l app=httpbin,version=v2 -o jsonpath={.items..metadata.name}) && echo "PODS: $V1_POD, $V1_POD"

# Check the logs of the v1 and v2 httpbin pods. You should see access log entries for v1 and none for v2
$ kubectl logs -n mirror "$V1_POD" -c httpbin && echo "---" && kubectl logs -n mirror "$V2_POD" -c httpbin
```

Each curl request from the sleep pod will appear as a log entry like this.

```
127.0.0.1 - - [07/Mar/2018:19:02:43 +0000] "GET /headers HTTP/1.1" 200 321 "-" "curl/7.35.0"
```

**Mirroring Traffic to v2**

Change the route rule to mirror traffic to v2

```sh
$ kubectl apply -n mirror -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
    - httpbin
  http:
  - route:
    - destination:
        host: httpbin
        subset: v1
      weight: 100
    mirror:
      host: httpbin
      subset: v2
    mirror_percent: 100
EOF
```

This route rule sends 100% of the traffic to v1. The last stanza specifies that you want to mirror to the httpbin:v2 service. When traffic gets mirrored, the requests are sent to the mirrored service with their Host/Authority headers appended with -shadow. For example, cluster-1 becomes cluster-1-shadow.

Also, it is important to note that these requests are mirrored as “fire and forget,” which means that the responses are discarded.

You can use the `mirror_percent` field to mirror a fraction of the traffic, instead of mirroring all requests. If this field is absent, for compatibility with older versions, all traffic will be mirrored.

```sh
# Send in traffic
kubectl exec "${SLEEP_POD}" -n mirror -c sleep -- curl -s http://httpbin:8000/headers
```

Now you should see access logging for both v1 and v2. The access logs created in v2 are the mirrored requests that are actually going to v1. Notice the matching timestamps.

```sh
$ kubectl logs -n mirror "$V1_POD" -c httpbin && echo "---" && kubectl logs -n mirror "$V2_POD" -c httpbin

# Delete config
$ kubectl delete -n mirror virtualservice httpbin
$ kubectl delete -n mirror destinationrule httpbin
```
