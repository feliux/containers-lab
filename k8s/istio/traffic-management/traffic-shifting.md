### [Traffic Shifting](https://istio.io/latest/docs/tasks/traffic-management/traffic-shifting/)

Migrate traffic from one version of a microservice to another (OSI Layer 7). For example, you might migrate traffic from an older version to a new version.

In Istio, you accomplish this goal by configuring a sequence of rules that route a percentage of traffic to one service or another. So we will send 50% of traffic to reviews:v1 and 50% to reviews:v3. Then, we will complete the migration by sending 100% of traffic to reviews:v3.

**Apply Weight-Based Routing**

If you haven’t already applied destination rules, follow the instructions in Apply Default Destination Rules. To get started, run this command to route all traffic to the v1 version of each microservice.

```sh
$ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```

Open the Bookinfo /productpage in your browser. Notice that the reviews part of the page displays with no rating stars, no matter how many times you refresh. This is because you configured Istio to route all traffic for the reviews service to the version reviews:v1, and this version of the service does not access the star ratings service.

Transfer 50% of the traffic from reviews:v1 to reviews:v3 with the following command:

```sh
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
$ kubectl get virtualservice reviews -o yaml
```

Refresh the /productpage in your browser and you now see red-colored star ratings approximately 50% of the time. This is because the v3 version of reviews accesses the star ratings service, but the v1 version does not.

Assuming you decide that the reviews:v3 microservice is stable, you can route 100% of the traffic to reviews:v3 by applying this virtual service.

```sh
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-v3.yaml

# Delete config
$ kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```

### [TCP Traffic Shifting](https://istio.io/latest/docs/tasks/traffic-management/tcp-traffic-shifting/)

Migrate TCP traffic from one version of a microservice to another (OSI Layer 5). For example, you might migrate TCP traffic from an older version to a new version.

In Istio, you accomplish this goal by configuring a sequence of rules that route a percentage of TCP traffic to one service or another. In this task, you will send 100% of the TCP traffic to tcp-echo:v1. Then, you will route 20% of the TCP traffic to tcp-echo:v2 using Istio’s weighted routing feature.

To get started, create a namespace for testing TCP traffic shifting and label it to enable automatic sidecar injection.

```sh
$ kubectl create namespace istio-io-tcp-traffic-shifting
$ kubectl label namespace istio-io-tcp-traffic-shifting istio-injection=enabled

# Deploy the sleep sample app into that namespace to use as a test source for sending requests
$ kubectl apply -f samples/sleep/sleep.yaml -n istio-io-tcp-traffic-shifting
# Deploy the v1 and v2 versions of the tcp-echo microservice
$ kubectl apply -f samples/tcp-echo/tcp-echo-services.yaml -n istio-io-tcp-traffic-shifting

# Get the ingress host and port so you can route traffic to the tcp-echo service
$ INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.externalIPs[0]}') && echo "INGRESS_HOST=$INGRESS_HOST"
$ TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}') && echo "TCP_INGRESS_PORT=$TCP_INGRESS_PORT"

# Route all TCP traffic to the v1 version of the tcp-echo microservice
$ kubectl apply -f samples/tcp-echo/tcp-echo-all-v1.yaml -n istio-io-tcp-traffic-shifting
# Confirm that the tcp-echo service is up and running by sending some TCP traffic from the sleep client
$ for i in {1..20}; do \
kubectl exec "$(kubectl get pod -l app=sleep -n istio-io-tcp-traffic-shifting -o jsonpath={.items..metadata.name})" \
-c sleep -n istio-io-tcp-traffic-shifting -- sh -c "(date; sleep 1) | nc $INGRESS_HOST $TCP_INGRESS_PORT"; \
done
```

You'll notice that all the timestamps have a prefix of one, which means that all traffic was routed to the v1 version of the tcp-echo service.

Transfer 20% of the traffic from tcp-echo:v1 to tcp-echo:v2 with the following command.

```sh
$ kubectl apply -f samples/tcp-echo/tcp-echo-20-v2.yaml -n istio-io-tcp-traffic-shifting
# Confirm that the rule was replaced
$ kubectl get virtualservice tcp-echo -o yaml -n istio-io-tcp-traffic-shifting | { mapfile -tn 3 a; printf "%s\n" "${a[@]}" ...; tail -n +$(kubectl get virtualservice tcp-echo -o yaml -n istio-io-tcp-traffic-shifting | grep -n "^spec:" | cut -f1 -d:); }

# Send some more TCP traffic to the tcp-echo microservice
$ for i in {1..20}; do \
kubectl exec "$(kubectl get pod -l app=sleep -n istio-io-tcp-traffic-shifting -o jsonpath={.items..metadata.name})" \
-c sleep -n istio-io-tcp-traffic-shifting -- sh -c "(date; sleep 1) | nc $INGRESS_HOST $TCP_INGRESS_PORT"; \
done
```

You'll now notice that about 20% of the timestamps have a prefix of two, which means that 80% of the TCP traffic was routed to the v1 version of the tcp-echo service, while 20% was routed to v2.

**Understanding What Happened**

You partially migrated TCP traffic from an old to new version of the tcp-echo service using Istio’s weighted routing feature. Note that this is very different than doing version migration using the deployment features of container orchestration platforms, which use instance scaling to manage the traffic.

With Istio, you can allow the two versions of the tcp-echo service to scale up and down independently, without affecting the traffic distribution between them.

```sh
# Delete config
$ kubectl delete -f samples/tcp-echo/tcp-echo-all-v1.yaml -n istio-io-tcp-traffic-shifting
$ kubectl delete -f samples/tcp-echo/tcp-echo-services.yaml -n istio-io-tcp-traffic-shifting
$ kubectl delete -f samples/sleep/sleep.yaml -n istio-io-tcp-traffic-shifting
$ kubectl delete namespace istio-io-tcp-traffic-shifting
```
