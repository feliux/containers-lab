# Kafka

Kafka is a distributed system that implements the basic features of an ideal publish-subscribe system. Each host in the Kafka cluster runs a server called a broker that stores messages sent to the topics and serves consumer requests. Kafka currently relies on ZooKeeper to track the state of brokers in the Kafka cluster and maintain a list of Kafka topics and messages.

**Note: actual [kafka.yaml](./kafka.yaml) is configured for PLAINTEXT (no TLS, no SASL)**

## Usage

```sh
# Deprecated
# $ helm repo add bitnami https://charts.bitnami.com/bitnami
# $ helm install my-release bitnami/kafka \
#     --version 20.0.5 \
#     --set persistence.enabled=false \
#     --set zookeeper.persistence.enabled=false

# Updated
$ REGISTRY_NAME=registry-1.docker.io
$ REPOSITORY_NAME=bitnamicharts
$ helm install my-release-kafka oci://$REGISTRY_NAME/$REPOSITORY_NAME/kafka -f kafka.yaml
```

To create a pod that you can use as a Kafka client run the following commands (Remove the client.properties line if needed).

```sh
$ kubectl run my-release-kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.8.0-debian-12-r3 --namespace default --command -- sleep infinity
$ kubectl cp --namespace default /path/to/client.properties my-release-kafka-client:/tmp/client.properties # If a custom client.properties needed
$ kubectl exec --tty -i my-release-kafka-client --namespace default -- bash

# PRODUCER
$ kafka-console-producer.sh \
    --broker-list my-release-kafka-controller-0.my-release-kafka-controller-headless.default.svc.cluster.local:9092,my-release-kafka-controller-1.my-release-kafka-controller-headless.default.svc.cluster.local:9092,my-release-kafka-controller-2.my-release-kafka-controller-headless.default.svc.cluster.local:9092 \
    --topic foo \
    --producer.config /tmp/client.properties

# CONSUMER
$ kafka-console-consumer.sh \
    --bootstrap-server my-release-kafka.default.svc.cluster.local:9092 \
    --topic foo \
    --from-beginning \
    --consumer.config /tmp/client.properties
```

**Kcat**

You can use kcat to produce, consume, and list topics and partition information for Kafka. Described as “netcat for Kafka,” it is a Swiss army knife of tools for inspecting and creating data in Kafka. In general, kcat has the following features:

- As a command-line tool, it is fast and lightweight; statically linked, it is no more than 150 KB.
- In producer mode (-P), kcat reads messages from stdin, delimited with a configurable delimiter (-D; defaults to newline), and produces them to the provided Kafka cluster (-b), topic (-t), and partition (-p).
- In consumer mode (-C), kcat reads messages from a topic and partition and prints them to stdout using the configured message delimiter.
- It features a metadata list mode (-L) to display the current state of the Kafka cluster and its topics and partitions.

```sh
# We need two terminals
# Producer
1$ kubectl exec --stdin --tty deploy/kafka-cat -- sh
1$ kafkacat -P -b my-release-kafka:9092 -t 'message_type.dataset_name.hear-ye'
# Consumer
2$ kubectl exec --stdin --tty deploy/kafka-cat -- sh
2$ kafkacat -C -b my-release-kafka:9092 -t 'message_type.dataset_name.hear-ye'

# Inspect the topic metadata
1$ kafkacat -L -b my-release-kafka:9092
```

## TLS

Check the [kafka-generate-ssl.sh](./kafka-generate-ssl.sh) and [kafka-create-certs.sh](./kafka-create-certs.sh) for configuring TLS. Then set up your custom values on [kafka.yaml](./kafka.yaml).

**SASL AUTH**

The CLIENT listener for Kafka client connections from within your cluster maybe have been configured with the SASL authentication. To connect a client to your Kafka, you need to create the `client.properties` configuration files with the content below.

```
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-256
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="youruser" \
    password="$(kubectl get secret my-release-kafka-user-passwords --namespace default -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d , -f 1)";
```

## References

[Strimzi Kafka Operator](https://artifacthub.io/packages/olm/community-operators/strimzi-kafka-operator)

[Bitnami Kafka Helm Chart](https://artifacthub.io/packages/helm/bitnami/kafka)

[Bitnami Kafka Helm Chart github](https://github.com/bitnami/charts/tree/main/bitnami/kafka/#installing-the-chart)

**go clients**

[kafka-go](https://github.com/segmentio/kafka-go)

[kafka-go samples](https://medium.com/@bbeatrice.leung/quick-introduction-to-using-golang-for-kafka-3979e6b6b1aa)

[franz-go](https://github.com/twmb/franz-go)

[confluent-kafka-go](https://github.com/confluentinc/confluent-kafka-go)
