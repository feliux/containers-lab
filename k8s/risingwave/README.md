# RisingWave

RisingWave is a Postgres-compatible SQL database engineered to offer the simplest and most cost-effective approach for processing, analyzing, and managing real-time event streaming data.

**This deployment uses PostgreSQL and Minio bundle as Stores. Take a look to [Bundled etcd/PostgreSQL/MinIO as Stores](https://github.com/risingwavelabs/helm-charts/blob/main/docs/CONFIGURATION.md#bundled-etcdpostgresqlminio-as-stores) for further information**

```sh
# Install Risingwave
$ helm repo add risingwavelabs https://risingwavelabs.github.io/helm-charts/ --force-update
$ helm repo update
$ kubectl create namespace risingwave

# TLS setup
$ openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout tls.key -out tls.crt
$ kubectl create secret tls tls-secret-risingwave --cert=tls.crt --key=tls.key
# psql -p 4567 -d dev -U root --set=sslmode=verify-full

$ helm install -n risingwave --create-namespace --set wait=true -f values.yaml <RisingwaveReleaseName> risingwavelabs/risingwave
# $ helm install -n risingwave --create-namespace --set wait=true -f values.yaml risingtest risingwavelabs/risingwave
# helm install -n risingwave --create-namespace --set wait=true --set image.tag=<version_number> <RisingwaveReleaseName> -f values.yaml risingwavelabs/risingwave

$ kubectl port-forward svc/<RisingwaveReleaseName> 4567:svc
# $ kubectl port-forward svc/risingtest 4567:svc
```

**Client connections**

```sh
# PostgreSQL
$ psql -h localhost -p 4567 -d dev -U root
\d

# Go with dummy data
$ cd cmd
$ go run allInOne.go
```

**Kinesis to Iceberg example**

Requirements:

- AWS Kinesis broker. See [localstack](../localstack/) to deploy a local AWS APIs.
- Iceberg table already created

```sh
$ cd cmd
$ go run kinesisToIceberg.go
```

## References

[RisingWave](https://docs.risingwave.com/docs/current/intro/)

[RisingWave configuration](https://github.com/risingwavelabs/helm-charts/blob/main/docs/CONFIGURATION.md#customize-meta-store)

[RisingWave examples](https://github.com/risingwavelabs/helm-charts/tree/main/examples)

[Ingest from Kinesis](https://github.com/risingwavelabs/risingwave-docs/blob/main/versioned_docs/version-1.4/ingest/ingest-from-kinesis.md)
