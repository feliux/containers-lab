# API server

Deploy a simple API server in Kubernetes based in Golang and JavaScript.

## Usage

Our backend is a Golang webserver with 3 replicas. Only resturns the time and hostname as

~~~
{"time":"2021-04-01T14:36:20.219161521Z","hostname":"backend-k8s-golang-7d7b485f97-qswhb"}
~~~

First we have to build our Docker images in order to not pull the image from a public registry (kubernetes manifest has the option `imagePullPolicy: IfNotPresent`)

```sh
$ cd backend
$ docker build -t k8s-golang:v1 -f Dockerfile .

$ cd frontend
$ docker build -t k8s-js:v1 -f Dockerfile .
```

Now we have the Docker images in our Docker runtime but not in minikube. Minikube uses separate docker daemon and that is why, even though the image exists in our machine, it is still missing inside minikube. So we have to send the image to minikube by

```sh
$ docker save k8s-golang:v1 | (eval $(minikube docker-env) && docker load)
$ docker save k8s-js:v1 | (eval $(minikube docker-env) && docker load)
```

This command will save the image as tar archive, then loads the image in minikube by itself. Finally we can deploy our services

```sh
$ kubectl apply -f backend/backend.yaml
$ kubectl apply -f frontend/frontend.yaml
```

## Test

Test your API inside the cluster

```sh
$ kubectl run --rm -ti --generator=run-pod/v1 podtest3 --image=nginx:alpine -- sh
$ curl <ClusterIP/service_name>:80
```

Test your API outside the cluster

```sh
$ minikube service frontend-k8s-js # Copy the URL
$ curl <URL>
```
