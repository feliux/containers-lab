# Kube Admin

```sh
$ kubeadm init phase certs all -h

# Set up the client
$ mkdir $HOME/.kube
$ sudo cp -i /etc/kubernetes/adming.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install calico network addon
$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml
$ watch kubectl get pods -n calico-system
```
