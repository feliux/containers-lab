# Google Cloud Platform

Go to [infra-lab](https://github.com/feliux/infra-lab) repository to checkout for IaC deployments.

## GKE

**Container Registry**

Confirm that needed APIs are enabled

- Cloud Build
- Container Registry

```sh
$ gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/quickstart-image .
$ gcloud builds submit --config cloudbuild.yaml .

$ cat cloudbuild.yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: [ 'build', '-t', 'gcr.io/$PROJECT_ID/quickstart-image', '.' ]
images:
- 'gcr.io/$PROJECT_ID/quickstart-image'
```

**Create cluster**

[Doc](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create)

```sh
$ export my_zone=us-central1-a
$ export my_cluster=standard-cluster-1

$ gcloud container clusters create $my_cluster --num-nodes 3 --machine-type=e2-medium --enable-ip-alias --zone $my_zone --enable-network-policy --service-account=$my_service_account
```

**Modify GKE clusters**

```sh
$ gcloud container clusters resize $my_cluster --zone $my_zone --num-nodes=4
```

**Connect to a GKE cluster**

```sh
$ gcloud container clusters get-credentials $my_cluster --zone $my_zone


$ kubectl config view
$ kubectl cluster-info
$ kubectl config current-context
$ kubectl config get-contexts
$ kubectl top nodes
$ source <(kubectl completion bash)  # enable bash autocompletion
```

[Using SDK docker image](https://cloud.google.com/sdk/docs/downloads-docker) we can generate kubeconfig with our local machine authorized

```sh
$ docker pull gcr.io/google.com/cloudsdktool/cloud-sdk:345.0.0
$ docker run -ti --name gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud auth login
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud config set project learning-310712
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk gcloud container clusters get-credentials test1 --zone us-central1-a
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk kubectl get nodes
```

Now go into the container and copy the kubeconfig file

```sh
$ docker run --rm --volumes-from gcloud-config gcr.io/google.com/cloudsdktool/cloud-sdk kubectl config view --raw
```

**Use Cloud IAM roles to grant administrative access to all the GKE clusters in the project**

1. On the **Navigation** menu, click **IAM & admin > IAM**.

2. In the IAM console, locate the row that corresponds to the username, and then click on the pencil icon at the right-end of that row to edit that user's permissions

3. Click *ADD ANOTHER ROLE* to add another dropdown selection for roles.

4. In the Select a role dropdown box, choose **Kubernetes Engine > Kubernetes Engine Cluster Admin**.

To deploy a GKE cluster, a user must also be assigned the `iam.serviceAccountUser` role on the Compute Engine default service account.

5. On the **Navigation** menu, click **IAM & admin > Service accounts**.

6. In the IAM console, click the row that corresponds to the Compute Engine default service account to select it.

7. Click the Manage access button on the screen to open the permissions information panel. On the right hand side of the page, in the Manage access pane, click *Add Member*. Type the username into the New members box.

8. In the Select a role box, choose **Service Accounts > Service Account User**.

Now the user is able to create a cluster.

**Rotate IP Address and Credentials**

It is a secure practice to do so regularly to reduce credential lifetimes. While there are separate commands to rotate the serving IP and credentials, rotating credentials additionally rotates the IP as well.

```sh
$ gcloud container clusters update $my_cluster --zone $my_zone --start-credential-rotation
$ gcloud container operations list

# If tell to upgrade node pool
$ gcloud container clusters upgrade $my_cluster --zone $my_zone --node-pool=default-pool

# Monitor
$ export UPGRADE_ID=$(gcloud container operations list --filter="operationType=UPGRADE_NODES and status=RUNNING" --format='value(name)')
$ gcloud container operations wait $UPGRADE_ID --zone=$my_zone

# To complete the credential and IP rotation tasks
$ gcloud container clusters update $my_cluster --zone $my_zone --complete-credential-rotation

```

**Upgrade your GKE cluster**

Click the name of your cluster to open its properties. To the right of the control plane version, click the *Upgrade available* link to start the upgrade wizard. You must now upgrade the nodes of your cluster to the same version as the control plane (click *Upgrade oldest node pool*).

**Configure autoscaling on the cluster**

To configure your sample application for autoscaling (and to set the maximum number of replicas to four and the minimum to one, with a CPU utilization target of 1%), execute the following command:

```sh
$ kubectl autoscale deployment web --max 4 --min 1 --cpu-percent 1
```

The `kubectl autoscale` command creates a `HorizontalPodAutoscaler` object that targets a specified resource, called the scale target, and scales it as needed. The autoscaler periodically adjusts the number of replicas of the scale target to match the average CPU utilization that you specify when creating the autoscaler.

```sh
$ kubectl get hpa
$ kubectl describe horizontalpodautoscaler web
$ kubectl get horizontalpodautoscaler web -o yaml
```

> Test the autoscale configuration

You need to create a heavy load on the web application to force it to scale out. You create a configuration file that defines a deployment of four containers that run an infinite loop of HTTP queries against the sample application web server.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loadgen
spec:
  replicas: 4
  selector:
    matchLabels:
      app: loadgen
  template:
    metadata:
      labels:
        app: loadgen
    spec:
      containers:
      - name: loadgen
        image: k8s.gcr.io/busybox
        args:
        - /bin/sh
        - -c
        - while true; do wget -q -O- http://web:8080; done
```

Once the loadgen Pod starts to generate traffic, the web deployment CPU utilization begins to increase.

```sh
$ kubectl get hpa
```

**Manage node pools**

To deploy a new node pool with three preemptible VM instances, execute the following command:

```sh
$ gcloud container node-pools create "temp-pool-1" \
  --cluster=$my_cluster --zone=$my_zone \
  --num-nodes "2" --node-labels=temp=true --preemptible
$ kubectl get nodes
$ kubectl get nodes -l temp=true
```

> Control scheduling with taints and tolerations

To prevent the scheduler from running a Pod on the temporary nodes, you add a *taint* to each of the nodes in the temp pool. Taints are implemented as a key-value pair with an effect (such as NoExecute) that determines whether Pods can run on a certain node. Only nodes that are configured to tolerate the key-value of the taint are scheduled to run on these nodes. To add a taint to each of the newly created nodes, execute the following command.

```sh
$ kubectl taint node -l temp=true nodetype=preemptible:NoExecute
```

To allow application Pods to execute on these tainted nodes, you must add a tolerations key to the deployment configuration. Edit the `.yaml` file to add the following key in the template's spec section:

```sh
tolerations:
- key: "nodetype"
  operator: Equal
  value: "preemptible"
```

To force the web deployment to use the new node-pool add a `nodeSelector` key in the template's spec section. This is parallel to the tolerations key you just added.

```sh
nodeSelector:
  temp: "true"
```

The full `.yaml` deployment should now look as follows.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      run: web
  template:
    metadata:
      labels:
        run: web
    spec:
      tolerations:
      - key: "nodetype"
        operator: Equal
        value: "preemptible"
      nodeSelector:
        temp: "true"
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        name: web
        ports:
        - containerPort: 8080
          protocol: TCP
        resources:
          # You must specify requests for CPU to autoscale
          # based on CPU utilization
          requests:
            cpu: "250m"
```

Finally the web app is running only the preemptible nodes in `temp-pool-1` after apply again `$ kubectl scale deployment loadgen --replicas 4`

### Networks example

This manifest file defines an ingress policy that allows access to Pods labeled `app: hello` from Pods labeled `app: foo`. You have to enable network policies on the cluster creation (argument `--enable-network-policy` on `gcloud container clusters create` command)

> NOTE: validate from a Pod with this command `$ wget -qO- --timeout=2 http://$PodService:$PodPort`

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: hello-allow-from-foo
spec:
  policyTypes:
  - Ingress
  podSelector:
    matchLabels:
      app: hello
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: foo

```

Defines a policy that permits Pods with the label `app: foo` to communicate with Pods labeled `app: hello` on any port number, and allows the Pods labeled `app: foo` to communicate to any computer on UDP port 53, which is used for DNS resolution. Without the DNS port open, you will not be able to resolve the hostnames.

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: foo-allow-to-hello
spec:
  policyTypes:
  - Egress
  podSelector:
    matchLabels:
      app: foo
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: hello
  - to:
    ports:
    - protocol: UDP
      port: 53
```

### LoadBalancer example

**Create static public IP addresses using Google Cloud Networking**

1. In the Google Cloud Console navigation menu, navigate to **Networking > VPC Network > External IP Addresses**.

2. Click **+ Reserve Static Address**.

3. Enter `regional-loadbalancer` for the Name.

4. Explore the options but leave the remaining settings at their defaults. Note that the default type is **Regional**.

5. Click **Reserve**.

Now we have a LoadBalancer which IP we can use in the following `ingress.yaml`

```sh
$ export STATIC_LB=$(gcloud compute addresses describe regional-loadbalancer --region us-central1 --format json | jq -r '.address')
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-lb-svc
spec:
  type: LoadBalancer
  loadBalancerIP: $STATIC_LB
  selector:
    name: hello-v2
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080

```

Let's configure a LoadBalancer with an ingress.

6. Click **+ Reserve Static Address**.

7. Enter `global-ingress` for the Name.

8. Change the Type to **Global**.

9. Leave the remaining settings at their defaults.

10. Click **Reserve**.

Note the `kubernetes.io/ingress.global-static-ip-name` option with the name of the address

```yaml
apiVersion: app/v1
kind: Ingress
metadata:
  name: hello-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.global-static-ip-name: "global-ingress"

spec:
  rules:
  - http:
      Paths:
     - path: /v1
        backend:
          serviceName: hello-svc
          servicePort: 80
      - path: /v2
        backend:
          serviceName: hello-lb-svc
          servicePort: 80
```

In Google Cloud Console, on the Navigation menu , click **Networking > Network services> Load balancing** to inspect the changes to your networking resources.

### Jobs example

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  # Unique key of the Job instance
  name: example-job
spec:
  template:
    metadata:
      name: example-job
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl"]
        args: ["-Mbignum=bpi", "-wle", "print bpi(2000)"]
      # Do not restart containers after they exit
      restartPolicy: Never
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo "Hello, World!"
          restartPolicy: OnFailure
```

### SQL + Wordpress example

**Create a Cloud SQL instance**

```sh
$ gcloud sql instances create sql-instance --tier=db-n1-standard-2 --region=us-central1
```

In the Google Cloud Console, navigate to SQL. Click **Users** menu and click on **ADD USER ACCOUNT** and create an account.

Go back to **Overview** menu, still in your instance (sql-instance), and copy your Instance connection name.

Connect to your Cloud SQL instance.

```sh
$ gcloud sql connect sql-instance
create database wordpress;
use wordpress;
show tables;
exit
```

**Prepare a Service Account with permission to access Cloud SQL**

1. To create a **Service Account**, in the Google Cloud Console navigate to **IAM & admin> Service accounts**. Click + Create Service Account. Specify a Service account name called `sql-access` then click *Create*.

2. Click Select a role. Search for **Cloud SQL**, select **Cloud SQL Client** and click *Continue*. Click Done.

3. Locate the service account `sql-access` and click on three dots icon in **Actions** column. Click **Create Key**, and make sure JSON key type is selected and click *Create*.

This will create a public/private key pair, and download the private key file automatically to your computer. You'll need this JSON file later.

4. Click Close to close the notification dialog. Locate the JSON credential file you downloaded and rename it to `credentials.json`

**Create Secrets**

```sh
$ kubectl create secret generic sql-credentials \
   --from-literal=username=sqluser\
   --from-literal=password=sqlpassword

$ kubectl create secret generic google-credentials\
   --from-file=key.json=credentials.json
```
