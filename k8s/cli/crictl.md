# Container Runtime Interface Control

All Pods are started as containers on the nodes so `crictl` is a generic tool that communicates to the container runtime to get information about running containers. As such, it replaces generic tools like `docker` and `podman`.

To use it, a runtime-endpoint and image-endpoint need to be set. The most convenient way to do so, is by defining the [/etc/crictl.yaml](./crictl.yaml) file on the nodes where you want to run `crictl`.

```sh
$ crictl ps
$ crictl pods
$ crictl inspect <containerId>

$ crictl images
$ crictl pull <imageName>
```
