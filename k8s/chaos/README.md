# Pure Chaos

We are going to demostrate a simple worflow for chaos engineering.

Before you can feel the pleasure of destroying a sand castle, you have to create one. Let's create a small collection of applications. In a production system, perhaps this would be a replication of microservices, but in this example we will create a deployment of applications that log random messages. Create a namespace for the deployment:

Firt, we are going to install a Registry.

```sh
$ helm repo add twuni https://helm.twun.io && helm repo list
$ helm install registry twuni/docker-registry \
	--version 2.1.0 \
	--namespace kube-system \
	--set service.type=NodePort \
	--set service.nodePort=31500

$ kubectl get service --namespace kube-system
$ export REGISTRY=<RegistryClusterUrl>
$ kubectl get deployments registry-docker-registry --namespace kube-system
$ curl $REGISTRY/v2/_catalog | jq -c
```

Now we can deploy the `random-logger` application.

```sh
$ kubectl create namespace learning-place
# Run the random-logger container in a Pod to start generating continuously random logging events
$ kubectl create deployment random-logger --image=chentex/random-logger -n learning-place
# Scale to 10 Pods
$ kubectl scale deployment/random-logger --replicas=10 -n learning-place
$ kubectl get pods -n learning-place
```

Also let's build our chaos container and deploy it as a CronJob.

```sh
$ export IMAGE=$REGISTRY/chaos:0.1.0
$ docker image build -t $IMAGE .
$ docker image push $IMAGE
$ curl $REGISTRY/v2/_catalog | jq

$ kubectl create cronjob chaos-runner --image=$IMAGE --schedule='*/1 * * * *'
$ kubectl get cronjobs
```

At the beginning of the next minute on the clock, the CronJob will create a new Pod. Every minute a new Pod will create and run the chaos logic. Kubernetes automatically purges the older Job Pods. Getting the logs from all the Jobs is a bit tricky, but there is a common client tool called Stern that collates and displays logs from related Pods.

```sh
$ stern chaos-runner --container-state terminated --since 2m --timestamps
```

The `random-logger` application is running in the namespace `learning-place`. The current logic for the chaotic Pod deletion requires a namespace to be annotated with `chaos=yes`.

```sh
# Assign the random-logger Pods as chaos targets by annotating the learning-place namespace
$ kubectl annotate namespace learning-place chaos=yes
$ kubectl describe namespace learning-place
```

The next time chaos Job runs it will see this annotation and the interesting work will be reported. Keep watching for a new Job Pod to appear.

```sh
$ kubectl get pods
# And keep watching the Pod lifecycle status of the random-logger Pods
$ watch kubectl get pods -n learning-place

$ stern chaos-runner --container-state terminated --since 2m --timestamps
```

You will soon be seeing the Pods terminating while the Deployment controller is dutifully trying to maintain the declared scale level of 10 Pods. For real applications, if scaled correctly, all this chaos and resilience will be happening behind the scenes in the cluster while your users experience no downtime or delays.

You could modify the Python code a bit more and go crazy with other Kubernetes API calls to create clever forms of havoc.

## References

[Principles of Chaos](http://principlesofchaos.org/)
