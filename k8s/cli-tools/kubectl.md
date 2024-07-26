# Kube Control

```sh
$ kubectl api-resources
$ kubectl api-versions

$ kubectl explain pod.spec.volumes

$ kubectl get po,rs,deploy,svc,ingress
$ kubectl describe <po,rs,deploy,svc,ingress> <name>

# Resources
$ kubectl -n kube-system get events
$ kubectl top pods

$ kubectl get po -A --selector foo=bar
$ kubectl exec -it <podName> -- bash

$ kubectl cp <podName>:/path/to/container/file /path/to/local/file
$ kubectl cp /path/to/local/file <podName>:/path/to/container/file

$ kubectl scale deploy <deployName> --replicas=3
$ kubectl expose deploy <deployName>
$ kubectl get svc -o wide
$ kubectl get endpoints --watch
$ kubectl describe endpoints <svcName>

$ kubectl rollout status deploy <deployName>
$ kubectl rollout pause deploy <deployName>
$ kubectl rollout resume deploy <deployName>
$ kubectl rollout history deploy <deployName> --revision=2
$ kubectl rollout undo deploy <deployName> --to-revision=1

# Labeling
$ kubectl get po --show-labels
$ kubectl label pods foo color=red
$ kubectl label pods foo color=red --overwrite # overwrite an existing label
$ kubectl label pods foo color- # remove label color

$ kubectl label deploy <deployName> "canary=true"
$ kubectl label deploy <deployName> "canary-"
$ kubectl get deploy -L canary

$ kubectl get po --selector="app=test,ver=2"
$ kubectl get po --selector="app in (alpaca,bandicoot)"
$ kubectl get po --selector="app notin (alpaca,bandicoot)"
$ kubectl get po --selector="app!=alpaca"

$ kubectl get po -l "ver=2,!canary"
$ kubectl get deploy --selector="!canary"

# Debugging
# If do not have a terminal available within your container, you can always attach to the running process
$ kubectl attach -it <podName>
# Similar to kubectl logs but will allow to send input to the running process, assuming that process is set up to read from standard input

# Port forward
$ kubectl port-forward <podName> <sourcePort>:<podPort>

# Proxies the Kubernetes API to our local machine and also takes care of the authentication and authorization bits
$ kubectl proxy --port=8080
$ curl http://127.0.0.1:8080/apis/batch/v1
# Same as
$ kubectl get --raw /apis/batch/v1
```

**RBAC**

Verbs are

- create
- delete
- get
- list
- patch
- update
- watch
- proxy

```bash
$ kubectl auth can-i create pods
$ kubectl auth can-i create pods --subresource=logs # logs or port-forwarding

$ kubectl get clusterroles
$ kubectl get clusterrolebindings

$ kubectl auth reconcile -f some-rbac-config.yaml --dry-run
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

$ kubectl label nodes <nodeName> ssd=true # usefull for DaemonSets with the flag selector.matchLabels
$ kubectl get nodes --selector ssd=true

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
```

**Horizontal Pod Autoscaling**

This feature requires the metric-server already installed.

```bash
$ kubectl autoscale rs <rsName> --min=2 --max=5 --cpu-percent=80
$ kubectl get hpa
```

**ConfigMaps and Secrets**

```bash
$ kubectl get cm
$ kubectl get secrets 

$ kubectl create secret generic <secretName> --from-file=file.crt --from-file=file.key

# --from-file=<fileName>
# load from the file with the secret data key that's the same as the filename

# --from-file=<key>=<fileName>
# load from the file with the secret data key explicitly specified

# --from-file=<directory>
# load all the files in the specified directory where the filename is an acceptable key name

# --from-literal=<key>=<value>
# use the specified key/value pair directly

# Certs
$ openssl x509 -inform der -in file.txt -out file.crt

$ kubectl create configmap-cacerts -n <namespace> --from-file=cacerts=./cacerts-nueva --dry-run=client -o yaml > configmap-cacerts.yaml

$ kubectl create secret tls <secretName> --key=file.key --cert=file.crt -n <namespace> --dry-run=client -o yaml > secret.yaml
```
