# Minikube

Deploy a minikube cluster.

```sh
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
$ sudo install minikube-linux-amd64 $PWD/minikube && rm minikube-linux-amd64

# Create cluster
$ minikube start

$ minikube kubectl -- get po -A
$ alias mkctl="minikube kubectl --"
$ mkctl get po -A

# Start the dashboard
$ minikube dashboard

# Pausa
$ minikube pause
# Unpause
$ minikube unpause
# Halt
$ minikube stop
# Change the default memory limit (requires a restart)
$ minikube config set memory 9001

# Addons
$ minikube addons list
$ minikube addons enable <name>
$ minikube addons disable <name>
# For addons that expose a browser endpoint, you can quickly open them with
$ minikube addons open <name>

# Exposing apps
$ mkctl create deploy nginx --image=nginx
$ mkctl expose deploy nginx --port=8080 --type=NodePort
$ mkctl get svc
$ minikube service nginx --url

# Delete
$ minikube delete --all
```

## References

[minikube](https://minikube.sigs.k8s.io/docs/)

[minikube github](https://github.com/kubernetes/minikube)
