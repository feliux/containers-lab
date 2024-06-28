# RabbitMQ

Deploy RabbitMQ on k8s.

```sh
$ helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo list
$ VERSION=14.4.4
$ helm install my-rabbit bitnami/rabbitmq \
    --version $VERSION \
    --namespace rabbit RabbitMQ docs\
    --create-namespace \
    -f rabbit-values.yaml

$ watch kubectl get services,statefulsets,pods --namespace rabbit
```

## References

[RabbitMQ docs](https://www.rabbitmq.com/docs)

[RabbitMQ helm chart](https://artifacthub.io/packages/helm/bitnami/rabbitmq)
