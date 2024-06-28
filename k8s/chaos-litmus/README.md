# Litmus

Litmus is a toolset to for cloud native chaos engineering. Litmus provides tools to orchestrate chaos on Kubernetes to help SREs find weaknesses in their deployments. SREs use Litmus to run chaos experiments initially in the staging environment and eventually in production to find bugs and vulnerabilities. Fixing the weaknesses leads to increased resilience of the system.

Litmus offers you these compelling features:

- Kubernetes native CRDs to manage chaos. Using chaos API, orchestration, scheduling, and complex workflow management can be orchestrated declaratively.

- Most of the generic chaos experiments are readily available for you to get started with your initial chaos engineering needs.

- An SDK is available in GO, Python, and Ansible. A basic experiment structure is created quickly using SDK and developers and SREs just need to add the chaos logic to make a new experiment.

- It's simple to complex chaos workflows are easy to construct. Use GitOps and the chaos workflows to scale your chaos engineering efforts and increase the resilience of your Kubernetes platform.

Litmus takes a cloud native approach to create, manage, and monitor chaos. Chaos is orchestrated using the following Kubernetes Custom Resource Definitions (CRDs):

- ChaosEngine: A resource to link a Kubernetes application or Kubernetes node to a ChaosExperiment. ChaosEngine is watched by Litmus' Chaos-Operator which then invokes Chaos-Experiments.

- ChaosExperiment: A resource to group the configuration parameters of a chaos experiment. ChaosExperiment CRs are created by the operator when experiments are invoked by ChaosEngine.

- ChaosResult: A resource to hold the results of a chaos-experiment. The Chaos-exporter reads the results and exports the metrics into a configured Prometheus server.

```sh
$ kubectl create deploy nginx --image=nginx
$ kubectl get deployments,pods --show-labels
```

The Litmus engine stores its state data in Mongo and that datastore needs to bind to a volume with at least 20Gi.

```sh
# Create a directory for the store right here on the controlplane node
$ mkdir -p /tmp/data01
$ kubectl apply -f persistentvolume.yaml

# Install litmus
# https://docs.litmuschaos.io/docs/getting-started/installation/
$ VERSION=3.7.0
$ helm repo add litmuschaos https://litmuschaos.github.io/litmus-helm/ && helm repo list
$ helm install litmuschaos litmuschaos/litmus \
    --namespace=litmus \
    --create-namespace \
    --version=$VERSION \
    --set portal.frontend.service.type=NodePort # remove if not NodePort

$ kubectl get all --namespace litmus
# Get the ChaosCenter port. Login admin /// litmus
$ kubectl get svc -n litmus
# Configure an environment in ChaosCenter
# Here is an example for installing the ChaosInfrastructure
# $ kubectl apply -f litmus-chaos-enable.yaml
$ watch kubectl get pods -n litmus
$ kubectl get CustomResourceDefinitions | grep -z chaosexperiments
```

**Install Chaos Experiments**

Chaos experiments contain the actual chaos details. These experiments are installed on your cluster as Litmus resources declarations in the form of the Kubernetes CRDs. Because the chaos experiments are just Kubernetes YAML manifests, these experiments are published on [Chaos Hub](https://hub.litmuschaos.io/).

> The project refers to these common, public experiments on Chaos Hub as charts but they are different and not to be confused with Helm charts.

For this example, we'll move forward with the [generic/pod-delete](https://hub.litmuschaos.io/kubernetes/pod-delete) experiment from Chaos Hub.

```sh
# https://litmuschaos.github.io/litmus/experiments/categories/pods/pod-delete/
$ kubectl apply -f chaos-exp-pod-delete.yaml
$ kubectl get chaosexperiments
$ kubectl get chaosexperiments | grep -z 'pod-delete'
```

**Setup RBAC with Service Account**

A service account should be created to allow ChaosEngine to run experiments in your application namespace.

```sh
# https://litmuschaos.github.io/litmus/experiments/categories/pods/pod-delete/#minimal-rbac-configuration-example-optional
$ kubectl apply -f rbac.yaml
$ kubectl get serviceaccount,role,rolebinding
```

**Annotate Application**

```sh
$ kubectl annotate deploy/nginx litmuschaos.io/chaos="true"
$ kubectl describe deployments.apps nginx | grep -z 'litmuschaos.io/chaos: true'
$ kubectl get pods
```

**Prepare ChaosEngine and run the experiment**

The ChaosEngine connects the application instance to a submitted Chaos Experiment. Here is an example of a Pod deletion experiment that will target the nginx Pod.

```sh
$ kubectl apply -f chaos-engine-pod-delete.yaml
$ watch -n 1 kubectl get pods
# The experiment results are accumulated in the ChaosResult object associated with the experiment
$ kubectl describe chaosresult engine-nginx
```

## References

[Litmus](https://litmuschaos.io)

[Litmus Architecture Summary](https://docs.litmuschaos.io/docs/architecture/architecture-summary)
