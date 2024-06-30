## [Fault Injection](https://istio.io/latest/docs/tasks/traffic-management/fault-injection/)

Inject faults to test the resiliency of your application.

```sh
$ kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml
$ kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
$ kubectl get virtualservices -o yaml
```

With the above configuration, this is how requests flow:

- productpage → reviews:v2 → ratings (only for user jason)
- productpage → reviews:v1 (for everyone else)

**Injecting an HTTP Delay Fault**

To test the Bookinfo application microservices for resiliency, inject a 7s delay between the reviews:v2 and ratings microservices for user jason. This test will uncover a bug that was intentionally introduced into the Bookinfo app.

Note that the reviews:v2 service has a 10s hard-coded connection timeout for calls to the ratings service. Even with the 7s delay that you introduced, you still expect the end-to-end flow to continue without any errors.

```sh
$ kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml
$ kubectl get virtualservice ratings -o yaml
```

Notice the new `spec.http.faut` section. Allow several seconds for the new rule to propagate to all pods.

**Testing the Delay Configuration**

On the /productpage web page, log in as user jason. You expect the Bookinfo home page to load without errors in approximately 7 seconds. However, there is a problem: the Reviews section displays an error message: "Sorry, product reviews are currently unavailable for this book".

View the web page response times:

1. Open the Developer Tools menu in your web browser.
2. Open the Network tab.
3. Reload the /productpage web page. You will see that the page actually loads in about 6 seconds.

**Understanding What Happened**

You’ve found a bug. There are hard-coded timeouts in the microservices that have caused the reviews service to fail.

As expected, the 7s delay you introduced doesn’t affect the reviews service because the timeout between the reviews and ratings service is hard-coded at 10s. However, there is also a hard-coded timeout between the productpage and the reviews service, coded as 3s + 1 retry for 6s total. As a result, the productpage call to reviews times out prematurely and throws an error after 6s.

Bugs like this can occur in typical enterprise applications where different teams develop different microservices independently. Istio’s fault injection rules help you identify such anomalies without impacting end users.

Notice that the fault injection test is restricted to when the logged in user is jason. If you login as any other user, you will not experience any delays.

**Fixing the Bug**

You would normally fix the problem by:

1. Either increasing the productpage to reviews service timeout or decreasing the reviews to ratings timeout.
2. Stopping and restarting the fixed microservice.
3. Confirming that the /productpage returns its response without any errors. However, you already have a fix running in v3 of the reviews service. The reviews:v3 service reduces the reviews to ratings timeout from 10s to 2.5s so that it is compatible with (less than) the timeout of the downstream productpage requests.

If you migrate all traffic to reviews:v3 as described in the traffic shifting task, you can then try to change the delay rule to any amount less than 2.5s, for example 2s, and confirm that the end-to-end flow continues without any errors.

**Injecting an HTTP Abort Fault**

Another way to test microservice resiliency is to introduce an HTTP abort fault.

In this case, you expect the page to load immediately and display the Ratings service is currently unavailable message.

```sh
# Create a fault injection rule to send an HTTP abort for user jason
$ kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml
$ kubectl get virtualservice ratings -o yaml
```

**Testing the Abort Configuration**

1. Open the Bookinfo web application in your browser.
2. On the /productpage, log in as user jason. If the rule propagated successfully to all pods, the page loads immediately and the "Ratings service is currently unavailable" message appears.
3. If you log out from user jason or open the Bookinfo application in an anonymous window (or in another browser), you will see that /productpage still calls reviews:v1 (which does not call ratings at all) for everybody but jason. Therefore, you will not see any error message.

```sh
# Delete config
$ kubectl delete -f samples/bookinfo/networking/virtual-service-all-v1.yaml
```
