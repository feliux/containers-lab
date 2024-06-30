# Kind

Kubernetes in Docker.

```sh
# Install
$ [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64

# Create cluster from cli
$ ./kind create cluster --name kind-cluster-1 --kubeconfig kubeconfig.yaml
# Create cluster from config file
$ ./kind create cluster --config=config.yaml --kubeconfig kubeconfig.yaml

$ ./kind get clusters
$ kubectl --kubeconfig kubeconfig.yaml cluster-info

# Delete
$ ./kind delete cluster --name kind-cluster-1
```

**Load image into kind**

```sh
$ ./kind load docker-image my-custom-image-0 my-custom-image-1 --name kind-cluster-1

# Flow as
$ docker build -t my-custom-image:unique-tag ./my-image-dir
$ ./kind load docker-image my-custom-image:unique-tag
$ kubectl apply -f my-manifest-using-my-image:unique-tag

# Get a list of images present on a cluster node
$ docker exec -it my-node-name crictl images
```

## References

[Kind](https://kind.sigs.k8s.io/)
