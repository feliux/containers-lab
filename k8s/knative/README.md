# Knative

Knative is a Kubernetes-based platform for building, deploying, and managing modern serverless workloads. It drives with these primary features:

- Serving: Scale to zero, request-driven compute model.
- Events: Universal subscription, delivery and management of events.

In older versions of Knative there was another feature called Building. That evolved and split out into its own project called [Tekton](../tekton/).

We are going to use istio as service mesh. Go to [istio](../istio/) to see how to install Istio.

```sh
# Install the Istio operator using its installer
# $ export ISTIO_VERSION=1.13.3
$ export ISTIO_VERSION=1.22.0
$ curl -L https://istio.io/downloadIstio | sh -
$ export PATH="$PATH:/$PWD/istio-${ISTIO_VERSION}/bin"
$ istioctl version

# Initialize Istio on Kubernetes. This will start the operator
$ istioctl install --set profile=demo -y
$ kubectl get deployments,services -n istio-system
```

Knative consists of two independent and primary components: [Serving](https://knative.dev/docs/serving/) and [Eventing](https://knative.dev/docs/eventing/).

```sh
# $ export KNATIVE_VERSION=1.4.0
$ export KNATIVE_VERSION=1.14.1 # we need k8s up to v1.28
# Install the cli
$ curl -L https://github.com/knative/client/releases/download/knative-v${KNATIVE_VERSION}/kn-linux-amd64 -o /usr/bin/kn && chmod +x /usr/bin/kn
$ kn version
```

**Installing Knative Serving**

Serving is the primary layer that provides an abstraction for stateless request-based scale-to-zero services.

For the Servicing component, three Kubernetes manifests are needed:

- Serving Customer Resource Definitions (CRDs).
- Serving Core as the control plane objects.
- Networking that establishes the link between Knative and Istio.

```sh
# Install knative.
# Check first https://knative.dev/docs/install/

$ kubectl get crds | grep .knative.
$ kubectl get deployments,pods,services --namespace knative-serving | grep 'Running'
```

The Knative service control plane components perform the following.

- Activator: Receiving and buffering requests for inactive revisions and reporting metrics to the autoscaler. It also retries requests to a revision after the autoscaler scales the revision based on the reported metrics.
- Autoscaler: Receives request metrics and adjusts the number of pods required to handle the load of traffic.
- Controller: Reconciles the public Knative objects and autoscaling CRDs. When a user applies a Knative service to the Kubernetes API, this creates the configuration and route. It will convert the configuration into revisions and the revisions into deployments and Knative Pod Autoscalers (KPAs).
- Webhook: Intercepts Kubernetes API calls as well as CRD insertions and updates. It sets default values, rejects inconsistent and invalid objects, and validates and mutates Kubernetes API calls.

**First Knative Service**

Let's start a simple helloworld echoserver.

```sh
$ kubectl get crd services.serving.knative.dev
# This is not to be confused with the standard Kubernetes resource also called Service found in the core API
$ kubectl api-resources --api-group='' | grep services
```

However the two Services are differentiated by their apiVersion values and Knative currently uses `serving.knative.dev/v1`. The Knative Service declares a full Serving description for an application. A basic Knative kind Service looks like this.

```sh
$ cat << EOF > echo-server-kn-service.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: helloworld
spec:
  template:
    spec:
      containers:
        - image: jmalloc/echo-server:0.3.1
EOF

# Deploy the echoserver
$ kubectl create namespace hello
# Anything in the new hello namespace should be part of the Istio mesh
$ kubectl label namespace hello istio-injection=enabled
$ kubectl describe namespace hello

# Declare your new Knative service
$ kubectl create --namespace hello --filename echo-server-kn-service.yaml
$ kubectl get ksvc --namespace hello
# Reveal all the objects Knative is managing related to the service
$ kubectl get all --namespace hello
```

Follow these commands to call the application.

```sh
# Reveal the IP of the cluster and port for the Istio gateway to Knative
$ export ADDRESS=$(kubectl get node --output 'jsonpath={.items[0].status.addresses[0].address}'):$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}')
# Reveal the DNS name of the function
$ kubectl get routes --namespace hello
# Capture the service URL in a variable
$ export SERVICE=$(kubectl get route helloworld --namespace hello --output jsonpath='{.status.url}' | sed 's/http\?:\/\///')
$ echo Service $SERVICE is at $ADDRESS
$ curl -v -H "Host: $SERVICE" http://$ADDRESS
```

You will notice there is a slight delay. This is because the application is not actually running. Knative sees the request and spins up an instance of the echo-service to service the request. Observe that soon the echo-server Pod will be terminated in a few minutes.

```sh
$ watch kubectl get pods --namespace hello
```

Knative is handling the scaling to ensure it scales up to enough applications to handle increasing traffic for function requests. With dwindling activity, it will also scale the application back down and even to zero (if you want) to save on resources. The scaling criteria can be configured; however, the observing and scaling are part of the Knative Serving features.

```sh
# Delete config
$ kubectl delete --namespace hello --filename echo-server-kn-service.yaml
# Knative and its connection to Istio will ensure all the other supporting objects are also scrubbed
$ kubectl get all --namespace hello
```

## References

[Knative](https://knative.dev/docs/)

[Knative github docs](https://github.com/knative/docs)
