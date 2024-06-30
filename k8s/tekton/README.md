# Tekton CI/CD

Tekton is an open source project that formed as a subproject of the [Knative](../knative/) project in March of 2019. Using established Kubernetes style declarations, whole pipelines can be declared. The pipelines run on Kubernetes like any other process. Each step runs as an independent container. Tekton also helps normalize and standardize the terms and methods for forming and running pipelines. Tekton pipelines can complement a variety of popular CI/CD engines.

**Install Registry**

```sh
# Install registry
$ helm repo add twuni https://helm.twun.io && helm repo list
$ helm install registry twuni/docker-registry \
    --version 2.1.0 \
    --namespace kube-system \
    --set service.type=NodePort \
    --set service.nodePort=31500
$ export REGISTRY=<RegistryClusterUrl>
```

**Install Registry Proxies as Node Daemons**

In the subsequent steps, the pipeline will build a container and deploy them to this registry. The Docker Engine on each Kubernetes node has tight security rules around pulling images from registries. Especially registries that are deemed as “insecure". Docker requires pulls to be SSL and with authentication. However, oftentimes you are just wanting to use the private registry within the cluster. The Docker engine will pull from a "localhost" registry without triggering its security precautions. We run a kube-registry-proxy on each node in the cluster, exposing a port on the node (via the hostPort value), which Docker accepts since it is accessed by localhost.

```sh
The kube-registry-proxy is available in this repo
$ helm repo add incubator https://charts.helm.sh/incubator && helm repo list
$ helm install registry-proxy incubator/kube-registry-proxy \
    --version 0.3.4 \
    --namespace kube-system \
    --set registry.host=registry-docker-registry.kube-system \
    --set registry.port=5000 \
    --set hostPort=5000
```

This proxy is deployed as a DaemonSet on every node in your cluster. Internal to all the container engines in the cluster, the registry is now available as a service for pushing and pulling container images. Pods can pull images from the registry at `http://localhost:5000` and the proxies resolve the requests to `https://registry-docker-registry.kube-system:5000`.

**Install Registry UI**

```sh
# Install registry UI
$ kubectl apply -f ~/registry-ui.yaml
```

We will use this example app.

```sh
$ git clone https://github.com/javajon/node-js-tekton
```

**Install Tekton**

Install Tekton from a release page.

```sh
# 1.23.4 is not compatible, need at least 1.27.0
# $ kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/previous/v0.71.0/release.yaml
# $ watch kubectl get deployments,pods,services --namespace tekton-operator

$ kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.34.1/release.yaml
$ watch kubectl get deployments,pods,services --namespace tekton-pipelines

$ kubectl get crds

$ kubectl apply -f ~/tekton-dashboard-release.yaml
```

Because Tekton is a Kubernetes Operator, it can be completely administered using the standard Kubernetes manifests using the defined custom resources that have been associated with the Tekton controllers. You can use the kubectl tool as a way to manually manage these resources. For convenience, a command-line tool called `tkn` can optionally manage these same Tekton resources.

```sh
# Install tekton cli
$ VERSION=0.23.1
$ curl -LO https://github.com/tektoncd/cli/releases/download/v${VERSION}/tkn_${VERSION}_Linux_x86_64.tar.gz
$ tar xvzf tkn_${VERSION}_Linux_x86_64.tar.gz -C /usr/local/bin/ tkn

$ source <(tkn completion bash)

# Now you can execute
$ kubectl get pipelineresources
# or this
$ tkn resources list

# To see the resources you can manage, invoke the command without any options
$ tkn
```

**Declare Pipeline Resources**

```sh
$ cd node-js-tekton
$ less pipeline/git-resource.yaml | tee
$ kubectl apply -f pipeline/git-resource.yaml
$ tkn resources list
```

**Declare Pipeline Tasks**

Pipeline tasks (and ClusterTasks) are entities that define a collection of sequential steps you would want to run as part of your continuous integration flow. A task will run inside a Pod on your cluster.

For our pipeline, we have defined two tasks:

1. task-build-src clones the source, builds the Node.js based container, and pushes the image to a registry.
2. task-deploy pulls the container image from the private registry and runs it on this Kubernetes cluster.

```sh
$ less pipeline/task-build-src.yaml | tee
$ less pipeline/task-deploy.yaml | tee

$ kubectl apply -f pipeline/task-build-src.yaml
$ kubectl apply -f pipeline/task-deploy.yaml
$ tkn tasks list
```

Everything the steps need is either in the containers or referenced as Tekton resources. Older CI/CD engines would rely on enormous plugins that were jammed into a global space on the engine. This led to many anti-patterns like shoot the messenger and dependency hell. This monolithic plugin ball of mud is avoided with Tekton by having each step be modular with atomic steps that contain all the details and dependencies to complete their sole responsibilities. Since a task is a Pod, you also are leveraging the distributed computing nature of Kubernetes and all the CPUs, memory, and I/O across your clustered machines.

**Declare Pipeline**

Pipelines are entities that group a series of Tasks that accomplish a specific build or delivery goal. Pipelines can be triggered by an event or invoked from a PipelineRun entity. Tasks can be simply sequentially ordered or organized into a Directed Acyclic Graph (DAG).

For our pipeline, we have defined the two sequential tasks to build and deploy the application.

```sh
$ less pipeline/pipeline.yaml | tee
$ kubectl apply -f pipeline/pipeline.yaml
$ tkn pipelines list
```

**Declare Service Account**

Before we run a Pipeline we have to recognize that pipelines will run tasks that will eventually need access to restricted resources such as repositories (e.g., Git) and registries (e.g., container and chart registries). These resources are accessed through secrets. To use secrets, the Pipelines are associated with service accounts. The service accounts have roles that allow them to access specific Kubernetes Secrets.

```sh
$ kubectl apply -f pipeline/service-account.yaml
# This example is simple because both the readability of the source code repo and the container image registry are not protected with a secret. Therefore, we are just setting up a simple role.
$ kubectl get ServiceAccounts
```

**Declare Runner for Pipeline**

PipelineRuns are entities that declare the trigger to run a pipeline. The triggered pipeline is given specific contexts for inputs, outputs, and execution parameters.

```sh
$ less pipeline/pipeline-run.yaml | tee
$ kubectl apply -f pipeline/pipeline-run.yaml
$ tkn pipelineruns list
$ tkn pipelineruns describe application-pipeline-run
```

The pipeline is running. Check the Registry and in a moment a new app container will appear in the list. Check the Tekton dashboard and you will see pipeline running that builds the container images and deploys container. The pipeline will only appear in the dashboard when it's running and will be removed from the interface once it completes.

Also the application is running...

```sh
$ kubectl get deployments,pods,services
```

## References

[Tekton](https://tekton.dev/)

[Tekton operator](https://tekton.dev/docs/operator/#getting-started)
