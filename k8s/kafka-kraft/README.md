# Kafka (with KRaft)

Kafka is a distributed system that implements the basic features of an ideal publish-subscribe system. Each host in the Kafka cluster runs a server called a broker that stores messages sent to the topics and serves consumer requests. Kafka currently relies on ZooKeeper to track the state of brokers in the Kafka cluster and maintain a list of Kafka topics and messages.

We will be using an early access and perhaps future implementation of Kafka that uses **KRaft**. Instead of relying on ZooKeeper, the metadata management is implemented in core Kafka as a collection of quorum controllers. Like ZooKeeper, these are based on the Raft consensus algorithm, so the implementation is reliable and resilient, and it promises to distill Kafka's performance and security. The KRaft configuration is also ideal for quick development situations.

KRaft is the consensus protocol that was introduced to remove Apache Kafka’s dependency on ZooKeeper for metadata management. This greatly simplifies Kafka’s architecture by consolidating responsibility for metadata into Kafka itself, rather than splitting it between two different systems: ZooKeeper and Kafka. KRaft mode makes use of a new quorum controller service in Kafka that replaces the previous controller and makes use of an event-based variant of the Raft consensus protocol.

## Usage

1. Install a registry and build the image.

```sh
$ helm repo add twuni https://helm.twun.io && helm repo list
$ helm install registry twuni/docker-registry \
    --version 2.1.0 \
    --namespace kube-system \
    --set service.type=NodePort \
    --set service.nodePort=31500
$ kubectl get service --namespace kube-system
$ kubectl get deployments registry-docker-registry --namespace kube-system

$ export REGISTRY=<urlToRegistry>
$ curl $REGISTRY/v2/_catalog | jq -c

$ docker build -t $REGISTRY/kafka-kraft .
$ docker push $REGISTRY/kafka-kraft
```

2. Deploy Kafka

```sh
# One of the manifests is a PersistentVolume declaration to store the Kafka data.
# For that persistence, create a local directory
$ mkdir /mnt/kafka

$ envsubst < kafka.yaml | kubectl apply -f -
$ kubectl config set-context --current --namespace=kafka-kraft
$ kubectl get services,statefulsets,pods,pv,pvc
$ kubectl get services,statefulsets,pods | grep -z 'Running\|3/3\|kafka-svc\|9092'
```

3. Check topics

You can use kcat to produce, consume, and list topics and partition information for Kafka. Described as “netcat for Kafka,” it is a Swiss army knife of tools for inspecting and creating data in Kafka. In general, kcat has the following features:

- As a command-line tool, it is fast and lightweight; statically linked, it is no more than 150 KB.
- In producer mode (-P), kcat reads messages from stdin, delimited with a configurable delimiter (-D; defaults to newline), and produces them to the provided Kafka cluster (-b), topic (-t), and partition (-p).
- In consumer mode (-C), kcat reads messages from a topic and partition and prints them to stdout using the configured message delimiter.
- It features a metadata list mode (-L) to display the current state of the Kafka cluster and its topics and partitions.

```sh
$ kubectl apply -f kafka-cat.yaml
$ kubectl get pods -l app=kcat
# Now we need two terminals
# Producer
1$ kubectl exec --stdin --tty deploy/kafka-cat -- sh
1$ kafkacat -P -b kafka-svc:9092 -t 'message_type.dataset_name.hear-ye'
# Consumer
2$ kubectl exec --stdin --tty deploy/kafka-cat -- sh
2$ kafkacat -C -b kafka-svc:9092 -t 'message_type.dataset_name.hear-ye'

# Inspect the topic metadata
1$ kafkacat -L -b kafka-svc:9092
```

## References

[kraft](https://github.com/apache/kafka/tree/trunk/config/kraft)

[KRaft described by Confluent](https://developer.confluent.io/learn/kraft/)

[KRaft described by IBM](https://developer.ibm.com/tutorials/kafka-in-kubernetes/)

[kcat](https://github.com/edenhill/kcat)
