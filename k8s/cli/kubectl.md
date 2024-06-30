# Kube Control

```sh
$ kubectl explain pod.spec.volumes

$ kubectl port-forward <podName> <sourcePort>:<podPort>

$ kubectl get po -A --selector foo=bar
$ kubectl scale deploy <deployName> --replicas=3
```

**Contexts**

```sh
$ kubectl config get-contexts
$ kubectl config use-context <contextName>
# Set cluster context
$ kubectl config --kubeconfig=$HOME/.kube/config set-cluster <clusterConfigName> --server=https://<ApiServerEndpoint>
# The user is a user account, defined by its X.509 certificates or other
$ kubectl config --kubeconfig=$HOME/.kube/config set-credentials <user> --client-certificate=<cert.crt> --client-key=<cert.key>
# Define the new context
$ kubectl set-context <contextName> --cluster=<clusterConfigName> --namespace=<namespace> --user=<user>
```

**DaemonSet**

```sh
# Create a daemonset
$ kubectl create deploy myds --image=nginx --dry-run=client -o yaml > /tmp/myds.yaml
# Open the yaml, change the kind to DaemonSet and delete replicas and strategy
$ kubectl apply -f myds.yaml
$ kubectl get ds
```

**Nodes**

```sh
$ kubectl get nodes
$ kubectl top nodes
$ kubectl describe node <nodeName>

# Mark a node as schedulable
$ kubectl cordon <nodeName>
# Mark a node as schedulable and remove all pods
$ kubectl drain <nodeName>
$ kubectl drain <nodeName> --ignore-daemonsets
$ kubectl drain <nodeName> --delete-emptydir-data
# These commands set a taint on the nodes
$ kubectl describe node <nodeName> | grep -i taint
$ kubectl get po -o wide
# Uncordon
$ kubectl uncordon <nodeName>

$ systemctl status kubelet
$ systemctl cat kubelet.service # check the Restart=always to ensure the daemon is always running. You can kill -9 kubelet_pid. This not work for manual operations like systemctl stop kubelet
$ journalctl -u kubelet
$ systemctl status containerd

$ ls -l /var/log

**Certs**

```bash
$ openssl x509 -inform der -in file.txt -out file.crt

$ kubectl create configmap-cacerts -n <namespace> --from-file=cacerts=./cacerts-nueva --dry-run=client -o yaml > configmap-cacerts.yaml

$ kubectl create secret tls <secretName> --key=file.key --cert=file.crt -n <namespace> --dry-run=client -o yaml > secret.yaml
```
