## [Request Routing](https://istio.io/latest/docs/tasks/traffic-management/request-routing/)

Route requests dynamically to multiple versions of a microservice.

The Istio Bookinfo sample consists of four separate microservices, each with multiple versions. Three different versions of one of the microservices, reviews, have been deployed and are running concurrently. To illustrate the problem this causes, access the Bookinfo app’s /productpage in a browser and refresh several times. You’ll notice that sometimes the book review output contains star ratings and other times it does not. This is because without an explicit default service version to route to, Istio routes requests to all available versions in a round-robin fashion.

We will apply rules that route all traffic to v1 (version 1) of the microservices. Later, we will apply a rule to route traffic based on the value of an HTTP request header.

```sh
# Route to one version only
$ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
$ kubectl get virtualservices -o yaml # the rule routes the traffic just to the v1 service
$ kubectl get destinationrules -o yaml

# Enable user-based routing based on HTTP headers
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
$ kubectl get virtualservice reviews -o yaml

# Delete config
$ kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```
