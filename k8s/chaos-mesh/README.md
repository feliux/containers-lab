# Chaos Mesh

Description [here](./info.md)

```sh
$ VERSION=2.6.3
$ helm repo add chaos-mesh https://charts.chaos-mesh.org && helm repo list

# Containerd
$ helm install chaos-mesh chaos-mesh/chaos-mesh \
    --version $VERSION \
    --namespace chaos-mesh \
    --create-namespace \
    --set chaosDaemon.runtime=containerd \
    --set chaosDaemon.socketPath=/run/containerd/containerd.sock \
    --set dashboard.securityMode=false \
    --set dashboard.service.nodePort=31111

# k3s
$ helm install chaos-mesh chaos-mesh/chaos-mesh \
    --version $VERSION \
    --namespace chaos-mesh \
    --create-namespace \
    --set chaosDaemon.runtime=containerd \
    --set chaosDaemon.socketPath=/run/k3s/containerd/containerd.sock \
    --set dashboard.securityMode=false \
    --set dashboard.service.nodePort=31111

# $ helm install chaos-mesh chaos-mesh/chaos-mesh \
#     -n=chaos-mesh \
#     --create-namespace \
#     --set chaosDaemon.env.DOCKER_API_VERSION="1.40" \
#     --set dashboard.securityMode=false \
#     --set dashboard.service.nodePort=31111 \
#     --version $VERSION

$ watch kubectl get deployments,pods,services --namespace chaos-mesh
# With the setting from the chart installation the chaos dashboard is accessible via a NodePort and the login security was disabled

# The Chaos Mesh has installed several custom resources
$ kubectl get crds
```

The control plane components for the Chaos Mesh are:

- ***chaos-controller-manager***: This schedules and manage the lifecycle of chaos experiments. (This is a misnomer. This should be just named controller, not controller-manager, as it's the controller based on the Operator Pattern. The controller-manager is the Kubernetes control plane component that manages all the controllers like this one).

- ***chaos-daemon***: These Pods control the chaos mesh. The Pods run on every cluster Node and are wrapped in a DaemonSet. These DaemonSets have privileged system permissions to access each Node's network, cgroups, chroot, and other resources that are accessed based on your experiments.

- ***chaos-dashboard***: An optional web interface providing you an alternate means to administer the engine and experiments. Its use is for convenience and any production use of the engine should be through the YAML resources for the Chaos Mesh CRDs.

Chech experiments types [here](./experiment-types.md)

**Network Delay Experiment**

Install an example application as a target for the experiment. This application is designed by the Chaos Mesh project as a hello world example.

```sh
# Install Example Web-show application
TARGET_IP=$(kubectl get pod -n kube-system -o wide| grep kube-controller | head -n 1 | awk '{print $6}')
$ kubectl create configmap web-show-context --from-literal=target.ip=${TARGET_IP}
$ kubectl apply -f web-show-deployment.yaml
$ kubectl apply -f web-show-service.yaml
$ kubectl get deployments,pods,services

$ kubectl get crds
$ less network-delay-experiment.yaml | tee
```

You can reference these resources to create declarative YAML manifests that define your experiment.

The experiment declares that a 10ms network delay should be injected. The delay will only be applied to the target service labeled "app": "web-show". This is the blast radius. Only the web-show app has that label.

```sh
$ kubectl get deployments,pods -l app='web-show'
# Apply experiment
$ kubectl apply -f network-delay-experiment.yaml
$ kubectl get NetworkChaos
```

The application has a built-in graph that will show the latency it's experiencing. With the experiment applied you will see the 10ms delay. Look at the dashboard, find the experiment, and drill down on its details.

```sh
# The experiment can be paused
$ kubectl annotate networkchaos web-show-network-delay experiment.chaos-mesh.org/pause=true
# And resumed
$ kubectl annotate networkchaos web-show-network-delay experiment.chaos-mesh.org/pause-

# Delete config
$ kubectl delete -f network-delay-experiment.yaml
```

**Scheduled Experiment**

Based on the previous network delay experiment, this experiment will inject network chaos periodically: 10ms network delay should be injected every minute that lasts for 30 seconds.

```sh
$ less scheduled-network-delay-experiment.yaml | tee
```

The experiment declares that a 10ms network delay should be injected every minute that lasts for 30 seconds. The delay will only be applied to the target service labeled "app": "web-show". This is the blast radius. Only the web-show app has that label.

```sh
$ kubectl get deployments,pods -l app='web-show'

# Apply experiment
$ kubectl apply -f scheduled-network-delay-experiment.yaml
# Scheduled experiment will not create NetworkChaos object immediately, instead it creates an Schedule object called web-show-scheduled-network-delay
$ kubectl get Schedule
```

The relationship between `Schedule` and `NetworkChaos` is very similar with what between `CronJob` and `Job`: `Schedule` will spawn `NetworkChaos` when trigger by `@every 60s`.

```sh
$ kubectl get NetworkChaos -w

# The experiment can be paused
$ kubectl annotate schedule web-show-scheduled-network-delay experiment.chaos-mesh.org/pause=true
# And resumed
$ kubectl annotate schedule web-show-scheduled-network-delay experiment.chaos-mesh.org/pause-

# Delete config
$ kubectl delete -f scheduled-network-delay-experiment.yaml
```

**Pod Removal Experiment**

The experiment declares that the specific pod should be killed every 15s. The removal will only be applied to the target pod labeled `"chaos": "blast here"`, which is the blast radius.
`
```sh
$ kubectl create namespace chaos-sandbox
$ kubectl apply -f nginx.yaml -n chaos-sandbox
$ less pod-removal-experiment.yaml | tee

$ kubectl get -n chaos-sandbox deployments,pods,services
$ kubectl get -n chaos-sandbox deployments,pods,services -l chaos=blast-here

# Apply experiment
$ kubectl apply -f pod-removal-experiment.yaml
$ kubectl get Schedule -n chaos-mesh

$ watch kubectl get -n chaos-sandbox deployments,pods,services
# ToDo fix: Failed to get run time: earliestTime is later than now

# Delete config
$ kubectl delete -f pod-removal-experiment.yaml
```

## References

[Chaos Mesh](https://chaos-mesh.org/)

[Chaos Mesh helm chart](https://artifacthub.io/packages/helm/chaos-mesh/chaos-mesh)
