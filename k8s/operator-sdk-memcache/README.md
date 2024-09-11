# Operator SDK

This guide is based on the operator-sdk [tutorial](https://sdk.operatorframework.io/docs/building-operators/golang/tutorial/).

The [Operator](https://sdk.operatorframework.io/docs/overview/) will manage a memcached cluster. A custom resource called `Memcached` will be created. The manifest will be used to control the size of the memcached cluster using a standard Kubernetes declarative manifest. [Memcached](https://github.com/memcached/memcached) is a high-performance, multithreaded, event-based key/value cache store intended to be used in a distributed system. The Operator SDK provides a framework to implement an Operator using Ansible, Helm, or Go. This lab covers the basics of implementing using Go.

Here, you will learn how to:

- Modify, build, and test code with an Operator SDK skeleton project
- Create a new CRD named Memcached using Go structs and automation
- Create a controller for observing and managing the Memcached custom resources
- Control the Memcached group using a declarative manifest and associated controller

The Operator SDK will package the controller into a container image. This image will be pushed and pulled from a container image registry. It's helpful to have a container registry during the build, push, and deploy phases. There is no need to shuttle private images over the internet. Instead, we keep all this pushing and pulling in a local registry

```bash
# Install registry
$ helm repo add twuni https://helm.twun.io && helm repo list
$ helm install registry twuni/docker-registry \
    --version 2.1.0 \
    --namespace kube-system \
    --set service.type=NodePort \
    --set service.nodePort=31500
$ export REGISTRY=303b855bb48a4ec4becbaeba3f0fb4fe-2886773765-31500-kira03.environments.katacoda.com
$ kubectl get deployments registry-docker-registry --namespace kube-system
$ curl $REGISTRY/v2/_catalog | jq -c
```

For getting started with the Operator SDK, a command-line tool appropriately named `operator-sdk` is supplied. The SDK documentation offers a variety of installation choices.

```bash
# The Operator SDK is very sensitive to the correct Go version, so whenever you install operator-sdk, but sure to have the correct version of Go installed.
$ VERSION=1.22.2
$ ARCH=$(case $(uname -m) in x86_64) echo -n amd64 ;; aarch64) echo -n arm64 ;; *) echo -n $(uname -m) ;; esac)
$ OS=$(uname | awk '{print tolower($0)}')
$ OPERATOR_SDK_DL_URL=https://github.com/operator-framework/operator-sdk/releases/download/v${VERSION}
$ curl -LO ${OPERATOR_SDK_DL_URL}/operator-sdk_${OS}_${ARCH}
$ chmod +x operator-sdk_${OS}_${ARCH} && sudo mv operator-sdk_${OS}_${ARCH} /usr/local/bin/operator-sdk
$ operator-sdk version | grep -z $VERSION
$ operator-sdk
```

The first step is to populate a source code directory that becomes the source repository for your new Operator.

```bash
$ mkdir -p memcached-operator && cd $_
$ operator-sdk init --domain example.com --repo github.com/example/memcached-operator
$ tree
```

The above `init` command created just the core files for the controller, but the project does not have all the content yet. Next, we need to declare a resource `Kind` that the controller will manage. In this example, the resource will be called Memcached. With this new resource, you'll control the cluster using a manifest with kind: Memcached. The following create command will create the CRD, API, and corresponding Go source containing the important `Reconcile` function where you can write code to manage memcached.

```bash
$ operator-sdk create api --group cache --version v1alpha1 --kind Memcached --resource --controller
```

The create adds a few new files and directories, such as `api/`

**Build and Containerize Operator**

With the source code generated along with the Memcached API, the basic Operator source code is now complete. You can build the controller and deploy it:

```bash
$ make docker-build docker-push IMG="$REGISTRY/memcached-operator:basic"
$ curl $REGISTRY/v2/_catalog | jq -c
```

While waiting for the build, explore the source files `api/v1alpha1/memcached_types.go` and `config/crd/bases/cache.example.com_memcacheds.yaml`

**Direct Deployment**

The Operator SDK generates a make script with helpful commands to assist with your development workflow. Use the deploy command to deploy your new Operator to Kubernetes.

```bash
$ make deploy IMG="$REGISTRY/memcached-operator:basic"
$ kubectl get CustomResourceDefinitions
$ kubectl get deployments,pods --namespace memcached-operator-system
```

Above, you ran the command operator-sdk create api to create the source code API. You can see the code in `api/v1alpha1/memcached_types.go`. This code is referenced by operator-sdk to automatically generate the `CustomResourceDefinition` YAML manifests in the crd directory. This same source code is also used to generate a sample manifest for defining a Memcached cluster.

```bash
$ less config/samples/cache_v1alpha1_memcached.yaml
```

There are special annotations in the comment blocks in the Go code that operator-sdk uses to generate the YAML manifests. You only need to modify the code and the YAML will be updated for you.

```bash
$ kubectl apply -f config/samples/cache_v1alpha1_memcached.yaml
$ kubectl get memcacheds
# However, this is just the declaration; the controller source code has no logic to actually start the memcached brokers in Pods.
$ kubectl get pods
# We'll be updating the Operator, so let's uninstall this current one
$ make undeploy
```

Our controller will allow you to manage the replication of memcached nodes. The Memcached controller has no notion yet of this replication declaration, so we'll add the ability to define a size parameter to the manifest. The controller Go code will read this size declaration and ensure the replication of memcached nodes matches the size request.

**Understanding Kubernetes APIs**

For an in-depth explanation of Kubernetes APIs and the group-version-kind model, check out these [kubebuilder docs](https://book.kubebuilder.io/cronjob-tutorial/gvks.html). In general, it’s recommended to have one controller responsible for managing each API created for the project to properly follow the design goals set by controller-runtime.

**Define the API**

To begin, we will represent our API by adding to the Memcached spec section a `MemcachedSpec.Size` field to set the quantity of memcached instances to be deployed.

Also, we'll add a `MemcachedStatus.Nodes` field to store the state of the Pod names that represent each memcached node.

Below are three code snippets that you must copy and paste to replace the three matching structs in the file `api/v1alpha1/memcached_types.go`. Be careful to match the name of the struct in the snippet to the three corresponding struct names in the Go source. The last `MemcachedList` in the source will not be modified.

This Go source defines the Memcached resource, and these Go type definitions describe the Size and Nodes fields in the Memcached Custom Resource (CR).

```go
// MemcachedSpec defines the desired state of Memcached
type MemcachedSpec struct {
    //+kubebuilder:validation:Minimum=0
    // Size is the size of the memcached deployment
    Size int32 `json:"size"`
}
```

When the Operator is running and has started the requested Pods, the status is reported back into the objects status. This struct defines the schema for the status and adds the Nodes field. Copy this struct to update the `memcached_types.go` code.

```go
// MemcachedStatus defines the observed state of Memcached
type MemcachedStatus struct {
    // Nodes are the names of the memcached pods
    Nodes []string `json:"nodes"`
}
```

**Define the Sections for the Resource**

Add the `+kubebuilder:subresource:status` marker to add a status subresource to the CRD manifest so that the controller can update the CR status without changing the rest of the CR object. Copy this struct to update the `memcached_types.go` code.

```go
// Memcached is the Schema for the memcacheds API
//+kubebuilder:object:root=true
//+kubebuilder:subresource:status
type Memcached struct {
    metav1.TypeMeta   `json:",inline"`
    metav1.ObjectMeta `json:"metadata,omitempty"`
    Spec   MemcachedSpec   `json:"spec,omitempty"`
    Status MemcachedStatus `json:"status,omitempty"`
}
```

After modifying the `*_types.go` file, always run the following generate to update the generated code for that resource type.

```bash
$ make generate
```

The above makefile target will invoke the controller-gen utility to update the `api/v1alpha1/zz_generated.deepcopy.go` file to ensure our API’s Go type definitions implement the `runtime.Object` interface that all `Kind` types must implement.

**Generating CRD Manifests**

Once the API is defined with spec/status fields and CRD validation markers, the CRD manifests can be generated and updated with the following command.

```bash
$ make manifests
```

This makefile target will invoke controller-gen to generate the CRD manifests at `config/crd/bases/cache.example.com_memcacheds.yaml`. Notice that in this CRD, the size declaration matches the instructions in the Go code.

**OpenAPI Validation**

OpenAPI validation defined in a CRD ensures CRs are validated based on a set of declarative rules. All CRDs should have validation. See the OpenAPI validation doc for details.

**Implement Controller**

The coded solution for the controller is a bit more involved, so a solution has already been coded for you.

```bash
$ cp memcached_controller.go ./memcached-operator/controllers/
```

After copying in this solution for the controller code, use the IDE to look near line 100 and see how the `Spec.size` value is read from the specification and applied to the `Spec.Replicas` for the Deployment of memcached. The Kubernetes client API gives you functions to programmatically control Kubernetes resources, including your custom resources such as `Kind: Memcached`.

Also, find the `Reconcile` function near line 60. This is the heart of the controller, and it's the essence of what makes Kubernetes a state machine.

A deeper dissection of this same controller code is explained in the [documentation](https://sdk.operatorframework.io/docs/building-operators/golang/tutorial/#implement-the-controller).

**Make Controller and Run Operator**

For the Operator, all that remains is to rebuild the updated Operator, push its image to the container image registry, then deploy it to Kubernetes. The following command will rebuild and push the updated Operator container image to the private registry.

```bash
make docker-build docker-push IMG="$REGISTRY/memcached-operator:v0.0.1"
```

Run the following to deploy the Operator. This will also install the RBAC manifests from `config/rbac`. These roles give permission to the controller to manipulate Kubernetes objects, such as creating and updating the Deployment for memcached.

```bash
make deploy IMG="$REGISTRY/memcached-operator:v0.0.1"
```

By default, a new namespace is created with name `<project-name>-system`, e.g. `memcached-operator-system`, and is the target for the Operator deployment.

```bash
$ kubectl get namespaces | grep -z memcached-operator-system
$ kubectl get deployment,pod -n memcached-operator-system | grep -z 'Running'
```

**Create Memcached Custom Resource**

Update the sample Memcached CR manifest at `config/samples/cache_v1alpha1_memcached.yaml` and ensure "Add field here" in the last line of the spec section is changed to the following.

```yaml
apiVersion: cache.example.com/v1alpha1
kind: Memcached
metadata:
  name: memcached-sample
spec:
  size: 3
```

Then apply the changes.

```bash
$ kubectl apply -f config/samples/cache_v1alpha1_memcached.yaml
$ kubectl get deployment
$ kubectl get pods
$ kubectl get memcached/memcached-sample -o yaml | grep -z "memcached-sample-\|status:"
```
