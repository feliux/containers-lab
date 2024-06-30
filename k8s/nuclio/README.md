# Nuclio

Nuclio is an open source serverless platform which allows developers to focus on building and running auto-scaling applications without worrying about managing servers.

- The fastest platform running up to 400,000 function invocations per second.
- Enables simple debugging, regression and a multi-versioned CI/CD pipeline.
- Supports a variety of open or cloud-specific event and data sources with common APIs.
- Is portable across low-power devices, laptops, on-premises and multi-cloud deployments.

You can use this example to experiment with many more features available in Nuclio such as:

- Pluggable triggers such as HTTP, Kafka, MQTT, RabbitMQ, Kinesis, and more.
- Stream processing.
- Connecting to volumes.
- Develop functions in different languages.
- Scaling.
- Function versioning and deployment model.

```sh
# Install registry
$ helm repo add twuni https://helm.twun.io && helm repo list
$ helm install registry twuni/docker-registry \
    --version 2.1.0 \
    --namespace kube-system \
    --set service.type=NodePort \
    --set service.nodePort=31500
$ export REGISTRY=<RegistryClusterUrl>
$ curl $REGISTRY/v2/_catalog | jq -c

# Install nuclio
$ helm repo add nuclio https://nuclio.github.io/nuclio/charts && helm repo list
# $ VERSION=0.12.10
$ VERSION=0.19.3
$ helm install nuclio nuclio/nuclio \
    --version=$VERSION \
    --create-namespace \
    --namespace=nuclio \
    --set dashboard.nodePort=31000
$ kubectl --namespace=nuclio get deployments,pods,services,crds

# Install the cli
$ NUCLIO_VERSION=$(kubectl get -n nuclio deployments.apps nuclio-controller -o=jsonpath='{.spec.template.metadata.annotations}' | jq '."nuclio.io/version"' | sed 's/^"\(.*\)"$/\1/' | cut -d- -f1) && echo $NUCLIO_VERSION
$ curl -L https://github.com/nuclio/nuclio/releases/download/$NUCLIO_VERSION/nuctl-$NUCLIO_VERSION-linux-amd64 -o /usr/local/bin/nuctl && chmod +x /usr/local/bin/nuctl

$ nuctl version && nuctl --help
$ nuctl deploy --help
```

**Deploy a function**

```sh
$ export HELLO_SRC=https://raw.githubusercontent.com/nuclio/nuclio/development/hack/examples/golang/helloworld/helloworld.go

$ curl $HELLO_SRC | pygmentize
$ kubectl create ns helloworld
# $ nuctl deploy helloworld --path $HELLO_SRC --registry $REGISTRY --http-trigger-service-type=NodePort -n helloworld

# check rbac for deploying in helloworld namespace
# by the moment lets deploy on nuclio namespace
$ nuctl deploy helloworld --path $HELLO_SRC --registry $REGISTRY --http-trigger-service-type=NodePort -n nuclio
```

Notice the engine will take care of the details to compile the Go app, packaging it in a container image, and serve it on Kubernetes. Underneath this process it still involves container images, but you are relinquished from those details. The container image will appear in the registry.

```sh
$ curl $REGISTRY/v2/_catalog | jq
$ kubectl get services,pods -l nuclio.io/function-name=helloworld -n nuclio # -n helloworld
$ nuctl get functions -n nuclio # -n helloworld
# Invoke
$ nuctl invoke helloworld -n nuclio | grep -z Hello
# or
$ curl <ClusterUrl:Port> \
    -H "Content-Type":["text/plain"] \
    -H "X-Nuclio-Log-Level":["info"] \ 
    -H "X-Nuclio-Target":["helloworld"]
# the ClusterUrl:Port can be viewed on nuclio dashboard
```

## References

[Nuclio github](https://github.com/nuclio/nuclio)

[Nuclio helm chart](https://artifacthub.io/packages/helm/nuclio/nuclio)

[Nuclio examples](https://github.com/nuclio/nuclio/tree/development/hack/examples)
