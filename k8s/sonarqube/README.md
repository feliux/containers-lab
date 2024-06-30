# SonarQube

Deploy SonarQube on k8s.

```sh
$ helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube && helm repo list

# https://github.com/SonarSource/helm-chart-sonarqube/releases
$ VERSION=10.5.1 # Error: INSTALLATION FAILED: chart requires kubeVersion: >= 1.24.0-0 which is incompatible with Kubernetes v1.23.4
$ VERSION=8.0.4
$ helm install my-sonarqube sonarqube/sonarqube \
    --version $VERSION \
    --namespace sonarqube \
    --create-namespace \
    --values sonarqube-values.yaml

$ watch kubectl get statefulset,pods,services --namespace sonarqube
```

## References

[Sonarqube helm chart](https://github.com/SonarSource/helm-chart-sonarqube)
