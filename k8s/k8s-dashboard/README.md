# K8s Dashboard

Install the k8s dashboard helm chart.

```sh
$ helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ && helm repo list
$ VERSION=7.4.0
$ helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
    --version=$VERSION \
    --namespace kubernetes-dashboard \
    --create-namespace \
    --values dash-values.yaml
# Get the dashboard token
$ ./k8s-dash-token.sh
```

## Refenreces

[K8s dashboard helm](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard)
