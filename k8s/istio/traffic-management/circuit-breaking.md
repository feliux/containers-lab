## [Circuit Breaking](https://istio.io/latest/docs/tasks/traffic-management/circuit-breaking/).

Configure circuit breaking for connections, requests, and outlier detection.

Circuit breaking is an important pattern for creating resilient microservice applications. Circuit breaking allows you to write applications that limit the impact of failures, latency spikes, and other undesirable effects of network peculiarities.

**Start the httpbin Sample**

```sh
$ kubectl apply -f samples/httpbin/httpbin.yaml
```

Since the Envoy proxy sidecar injection is already configured, the httpbin pod will be started with the Istio proxy. Without automatic injections, you have to manually inject the sidecar before deploying the httpbin application.

```sh
# kubectl apply -f <(istioctl kube-inject -f samples/httpbin/httpbin.yaml)
```

**Configuring the Circuit Breaker**

Create a destination rule to apply circuit breaking settings when calling the httpbin service. If you installed/configured Istio with mutual TLS authentication enabled, you must add a TLS traffic policy mode: ISTIO_MUTUAL to the DestinationRule before applying it. Otherwise, requests will generate 503 errors as described here.

```sh
$ kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: httpbin
spec:
  host: httpbin
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
    outlierDetection:
      consecutiveErrors: 1
      interval: 1s
      baseEjectionTime: 3m
      maxEjectionPercent: 100
EOF

# Verify that the destination rule was created correctly
$ kubectl get destinationrule httpbin -o yaml | { mapfile -tn 3 a; printf "%s\n" "${a[@]}" ...; tail -n +$(kubectl get destinationrule httpbin -o yaml | grep -n "^spec:" | cut -f1 -d:); }
# The applied rules are seen at the end of the DestinationRule manifest
```

**Adding a Client**

Create a client to send traffic to the httpbin service. The client is a simple load-testing client called fortio. fortio lets you control the number of connections, concurrency, and delays for outgoing HTTP calls. You will use this client to “trip” the circuit breaker policies you set in the DestinationRule.

Inject the fortio client with the Istio sidecar proxy so that network interactions are governed by Istio.

```sh
$ kubectl apply -f samples/httpbin/sample-client/fortio-deploy.yaml
# Without automatic sidecar injection, the fortio client would be started like this
# kubectl apply -f <(istioctl kube-inject -f samples/httpbin/sample-client/fortio-deploy.yaml)
```

Log in to the client pod and use the fortio tool to call httpbin. Pass in curl to indicate that you just want to make one call.

```sh
$ FORTIO_POD=$(kubectl get pods -lapp=fortio -o 'jsonpath={.items[0].metadata.name}') && echo "FORTIO_POD=$FORTIO_POD"
$ kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio curl -quiet http://httpbin:8000/get
```

You can see the request succeeded (200 OK). Now, it’s time to break something.

**Tripping the Circuit Breaker**

In the `DestinationRule` settings, you specified `maxConnections: 1` and `http1MaxPendingRequests: 1`. These rules indicate that if you exceed more than one connection and request concurrently, you should see some failures when the istio-proxy opens the circuit for further requests and connections.

```sh
# Call the service with two concurrent connections (-c 2) and send 20 requests (-n 20)
$ kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get
```

It’s interesting to see that almost all requests made it through! The istio-proxy does allow for some leeway.

```
Code 200 : 18 (90.0 %)
Code 503 : 2 (10.0 %)
```

Your actual numbers will vary. Bring the number of concurrent connections up to 3.

```sh
$ kubectl exec "$FORTIO_POD" -c fortio -- /usr/bin/fortio load -c 3 -qps 0 -n 30 -loglevel Warning http://httpbin:8000/get
```

Your results will vary based on the cluster performance. Query the istio-proxy stats to see more.

```sh
$ kubectl exec "$FORTIO_POD" -c istio-proxy -- pilot-agent request GET stats | grep httpbin | grep pending
```

You can see some value greater than zero for the `upstream_rq_pending_overflow` value, which means that number of calls so far have been flagged for circuit breaking.

```sh
# Delete config
$ kubectl delete destinationrule httpbin
# Shut down the httpbin service and client:
$ kubectl delete deploy httpbin fortio-deploy
$ kubectl delete svc httpbin fortio
```
