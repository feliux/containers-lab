# K3d

K3d creates containerized k3s clusters. This means, that you can spin up a multi-node k3s cluster on a single machine using docker.

```sh
# Download k3d
$ curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_DIR=$PWD bash

$ ./k3d version

# Create cluster grom cli
$ ./k3d cluster create k3d-cluster -s 1 -a 1
# Create cluster from config file
$ ./k3d cluster create k3d-cluster --config config.yaml
$ ./k3d cluster list
$ ./k3d kubeconfig get k3d-cluster > kubeconfig.yaml
$ kubectl --kubeconfig=kubeconfig.yaml get po -A

# Add nodes
$ ./k3d node create k3d-cluster-agent-1 --cluster k3d-cluster --role agent
$ ./k3d node list

# Delete cluster
$ ./k3d cluster delete k3d-cluster
· docker ps -a
```

## References

[K3d](https://k3d.io/v5.6.3/)

[K3d github](https://github.com/k3d-io/k3d)
