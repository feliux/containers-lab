# Istio

```sh
# Install the Istio operator using its installer
# $ export ISTIO_VERSION=1.13.3
$ export ISTIO_VERSION=1.22.0
$ curl -L https://istio.io/downloadIstio | sh -
$ export PATH="$PATH:/$PWD/istio-${ISTIO_VERSION}/bin"
$ istioctl version

# Initialize Istio on Kubernetes. This will start the operator
$ istioctl install --set profile=demo -y
$ kubectl get deployments,services -n istio-system
```

The `deployment.apps/istiod` deployment is the primary control plane component for Istio.

There are a few profiles to choose from based on the list of Istio features you want to enable. For this example with [Bookinfo](https://github.com/istio/istio/tree/master/samples/bookinfo), the demo profile is ideal.

```sh
# A deeper installation check is done by downloading the existing configurations
# https://istio.io/latest/docs/setup/additional-setup/config-profiles/
$ istioctl manifest generate --set profile=demo > $HOME/istio-generated-manifest.yaml
# See if the declarations match the reality of what is running
$ istioctl verify-install -f $HOME/istio-generated-manifest.yaml
```

**Istio integrations**

As a supplement, a collection of supplemental integrations is offered for the Istio control plane. Install them now, and we'll explore each one of them near the end of this lab.

The integrations are based on just the major and minor numbers of the SemVer version of Istio. So, extract the integrations version for the installations in this step.

```sh
$ SEMVER_REGEX='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
$ INTEGRATIONS_VERSION=$(echo $ISTIO_VERSION | sed -e "s#$SEMVER_REGEX#\1#").$(echo $ISTIO_VERSION | sed -e "s#$SEMVER_REGEX#\2#") && echo $INTEGRATIONS_VERSION

# Prometheus
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/prometheus.yaml

# Grafana
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/grafana.yaml

# Jaeger and OpenTelemetry
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/jaeger.yaml

# Istio Dashboard: Kiali
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-$INTEGRATIONS_VERSION/samples/addons/kiali.yaml
```

Now that all of these integrations have been added to Istio, they will continuously collect and monitor the information provided by Istio and all the Envoy proxies.

Prior to the Bookinfo install, add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy the Bookinfo application into the default namespace.

```sh
$ kubectl label namespace default istio-injection=enabled
```

There are other [methods to install the Envoy sidecars](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/), but this technique works well as a pre-installation step for a specific namespace.

**Start Bookinfo Application**

```sh
$ kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/platform/kube/bookinfo.yaml
$ watch kubectl get deployments,pods,services
# Envoy proxy sidecars have been injected next to each microservice and surreptitiously intercept all inbound and outbound Pod traffic
$ kubectl get pods -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |  tr -s '[[:space:]]' '\n'
```

This YAML file contains all the declarative manifests for the deployments, pods, and services that define the application. There is nothing in the YAML or within the application containers that exhibit knowledge or requirements for Istio to be present. The mesh is always independent from your application configuration and logic.

**Istio Networking**

Now that the Bookinfo services are up and running, we'll open a few forms of access to the application. Some of the service access techniques are private to the cluster, but we'll progress outward and open a public ingress path.

- Private, Internal Access. Once running, the application's product page can be accessed internally to the cluster. You can access a service through the ClusterIP by invoking curl from within one of the application Pods.

```sh
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') \
    -c ratings \
    -- curl productpage:9080/productpage | grep -o "<title>.*</title>" && echo
```

You will see <title>Simple Bookstore App</title>. This call is just through the standard Kubernetes network and is not related to the Istio mesh.

- Mesh Gateway. When you have a collection of services that participate within the bounds of a mesh, then an entrance into that mesh would be defined with a Gateway. An Istio Gateway is used to define the ingress into the mesh. To access the Bookinfo application through the mesh, you'll make the following declaration.

```sh
$ less istio-$ISTIO_VERSION/samples/bookinfo/networking/bookinfo-gateway.yaml | tee
```

Notice there is a Gateway and a VirtualServices defined to open traffic to the product page. In this example the Gateway opens access to the product page service. Before you apply this Gateway, let's attempt to access the product page through the istio_ingressgateway to see it fail.

To access the Gateway, a URL is formulated. Determine the ingress IP and ports and set the INGRESS_HOST and INGRESS_PORT variables for accessing the gateway.

```sh
$ export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}') && echo $INGRESS_HOST

$ export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}') && echo $INGRESS_PORT
# Formulate the URL
$ export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT && echo $GATEWAY_URL
```

With this URL, but without the Gateway defined for access to the mesh, this will return nothing.

```sh
$ curl http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>"
```

Define the ingress gateway for the application:

```sh
$ kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/bookinfo-gateway.yaml
# Confirm the gateway has been created
$ kubectl get gateway
# Confirm the app is now accessible through the mesh Gateway
$ curl http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>"
```

Again, you will see the "Simple Bookstore App".

This host address is local to the control-plane node where Bash is running. Next, we'll access the app from a public URL.

- Ingress Service Connection to the Mesh Gateway. For public access the cloud systems load balancer needs to know where to send traffic. At this point access to the application from the public URL will not work.

The istio-ingressgateway is a Pod with a Service of the type LoadBalancer that accepts this traffic. Currently the external ip is stuck at pending which means a bridge is missing between the load balancer and ingress gateway service.

```sh
$ kubectl get service istio-ingressgateway -n istio-system
```

Notice the EXTERNAL-IP reports pending.

The IP where the istio-ingressgateway is exposed is the control-plane node.

```sh
$ kubectl cluster-info | grep master
```

To connect this bridge, add those host IP as the externalIP to the istio-ingressgateway Service using the patch command.

```sh
$ kubectl patch service -n istio-system istio-ingressgateway -p '{"spec": {"type": "LoadBalancer", "externalIPs":["[[HOST_IP]]"]}}'
$ kubectl get service istio-ingressgateway -n istio-system
# The full application web interface is now available
```

**Apply Default Destination Rules**

Before you can use Istio to control the Bookinfo version routing, the destination rules need to define the available versions, called subsets. Create the default destination rules for the Bookinfo services.

```sh
$ kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/destination-rule-all.yaml
# View the destination rules
$ kubectl get destinationrules
```

There are rules for each service. For example, the rules for seeing the different review pages are this.

```sh
$ kubectl get destinationrules reviews -o yaml | grep -B2 -A20 "host: reviews"
# With the networking complete, Istio will report no issues
$ istioctl analyze
```

**Traffic Management**

Now that you have Istio and a sample application running let's explore what we can do with it. One of the main features of Istio is traffic management. As a Microservice architectures grow, so too grows the need for more advanced control of service-to-service communications.

**User Based Testing/Request Routing**

Traffic can be controlled and routed based on information in the HTTP request headers. Routing decisions can be made based on the presence of data such as user agent strings, key/values, IP addresses, or cookies.

This next example will send all traffic for the user jason to the reviews:v2, meaning that user will only see the black stars. A declaration in the VirtualServer defines this rule.

```sh
$ less istio-$ISTIO_VERSION/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml | tee
```

Similarly to deploying Kubernetes configuration, routing rules can be applied using istioctl.

```sh
$ kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
```

Visit the Bookinfo url to visit the product page. On the top-right sign in as user jason.

**Traffic Shaping for Canary Releases**

The ability to split traffic for testing and rolling out changes is important. This allows for A/B variation testing or deploying canary releases.

The rule below ensures that 50% of the traffic goes to reviews:v1 (no stars), or reviews:v3 (red stars).

```sh
$ less istio-$ISTIO_VERSION/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml | tee
$ kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml
```

Logout of user Jason otherwise the above configuration will take priority. The weighting is not round robin, multiple requests may go to the same service, but over multiple calls the statistics eventually work out.

**New Releases**

Given the above approach, if the canary release were successful then we'd want to move 100% of the traffic to reviews.

```sh
$ less istio-$ISTIO_VERSION/samples/bookinfo/networking/virtual-service-reviews-v3.yaml | tee
```

This can be done by updating the route with new weighting and rules.

```sh
$ kubectl apply -f istio-$ISTIO_VERSION/samples/bookinfo/networking/virtual-service-reviews-v3.yaml
```

**IstioCtl Inspection**

The istioctl tool has commands for inspection.

```sh
# List all the envoy sidecars
$ istioctl proxy-status
# The istioctl describe and analyze commands provide ways for you to investigate the mesh rules and configurations
$ istioctl analyze --help
```

However, let's get to some of the dashboards for more inspections.

```sh
$ kubectl apply -f dashboards.yaml
# Send requests to the application:
while true; do
  curl -s "<BookinfoClusterUrl>/productpage" > /dev/null
  echo -n .;
  sleep 0.2
done
```

## References

[Istio Architecture](https://istio.io/latest/docs/ops/deployment/architecture/)

[Isitio Release Announcements](https://istio.io/latest/news/releases/)

[Installation Configuration Profiles](https://istio.io/latest/docs/setup/additional-setup/config-profiles/)
