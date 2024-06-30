# Chaoskube

Deploy chaoskube helm chart for sabotage yourself.

```sh
$ helm repo add chaoskube https://linki.github.io/chaoskube && helm repo list
$ helm install chaoskube chaoskube/chaoskube \
	--version=0.3.0 \
	--namespace chaoskube \
	--create-namespace \
	--values chaoskube-values.yaml

$ kubectl get -n chaoskube deployments
$ kubectl rollout -n chaoskube status deployment chaoskube

$ POD=$(kubectl -n chaoskube get pods -l='app.kubernetes.io/instance=chaoskube' --output=jsonpath='{.items[0].metadata.name}')
$ kubectl -n chaoskube logs -f $POD
```

## References

[Principles of Chaos Engineering](https://principlesofchaos.org/)

[chaoskube](https://github.com/linki/chaoskube)
