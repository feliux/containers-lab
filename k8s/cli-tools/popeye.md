# Popeye

Popeye is a utility that scans live Kubernetes clusters and reports potential issues with deployed resources and configurations. As Kubernetes landscapes grows, it is becoming a challenge for a human to track the slew of manifests and policies that orchestrate a cluster. Popeye scans your cluster based on what's deployed and not what's sitting on disk. By linting your cluster, it detects misconfigurations, stale resources and assists you to ensure that best practices are in place, thus preventing future headaches. It aims at reducing the cognitive overload one faces when operating a Kubernetes cluster in the wild. Furthermore, if your cluster employs a metric-server, it reports potential resources over/under allocations and attempts to warn you should your cluster run out of capacity.

Popeye is a readonly tool, it does not alter any of your Kubernetes resources in any way.

```sh
$ go install github.com/derailed/popeye@latest

$ popeye -h

$ popeye -n <namespace>
# Save report to html
$ popeye --save --out html --output-file report.html
```

## References

[Popeye: Kubernetes Live Cluster Linter](https://popeyecli.io/)

[Popeye github](https://github.com/derailed/popeye)
