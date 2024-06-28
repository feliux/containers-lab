# Kafka

Kafka is a distributed system that implements the basic features of an ideal publish-subscribe system. Each host in the Kafka cluster runs a server called a broker that stores messages sent to the topics and serves consumer requests. Kafka currently relies on ZooKeeper to track the state of brokers in the Kafka cluster and maintain a list of Kafka topics and messages.

## Usage

```sh
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-release bitnami/kafka \
    --version 20.0.5 \
    --set persistence.enabled=false \
    --set zookeeper.persistence.enabled=false
```

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

## References

[Strimzi Kafka Operator](https://artifacthub.io/packages/olm/community-operators/strimzi-kafka-operator)
