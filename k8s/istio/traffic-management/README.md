# Istio traffic management

Here we will explore seven traffic management features with the Istio service mesh.

```sh
$ export ISTIO_VERSION=1.22.0
$ ./start-istio.sh
$ ./start-bookinfo.sh
```

### [Request Routing](./request-routing.md)

Route requests dynamically to multiple versions of a microservice.

### [Fault Injection](./fault-injection.md)

Inject faults to test the resiliency of your application.

### [Traffic Shifting](./traffic-shifting.md)

Migrate traffic from one version of a microservice to another (OSI Layer 7). For example, you might migrate traffic from an older version to a new version.

### [TCP Traffic Shifting](./tcp-traffic-shifting.md)

Migrate TCP traffic from one version of a microservice to another (OSI Layer 5). For example, you might migrate TCP traffic from an older version to a new version.

### [Request Timeouts](./request-timeouts.md)

Request service timeouts to services.

### [Circuit Breaking](./circuit-breaking.md)

Configure circuit breaking for connections, requests, and outlier detection.

### [Mirroring](./mirroring.md)

Send a single request to multiple services.
