# LocalStack

```sh
$ helm repo add localstack-repo https://helm.localstack.cloud
$ helm upgrade -n localstack --create-namespace --install localstack localstack-repo/localstack -f values.yaml

# Get the application URL by running these commands
$ export NODE_PORT=$(kubectl get --namespace "localstack" -o jsonpath="{.spec.ports[0].nodePort}" services localstack)
$ export NODE_IP=$(kubectl get nodes --namespace "localstack" -o jsonpath="{.items[0].status.addresses[0].address}")
$ echo http://$NODE_IP:$NODE_PORT

# Install awslocal cli
$ python -m venv .env
$ source .env/bin/activate
$ pip install -r requirements.txt
```
## Examples

**lambda**

```sh
$ export NODE_PORT=$(k get --namespace "localstack" -o jsonpath="{.spec.ports[0].nodePort}" services localstack)
$ export NODE_IP=$(k get nodes --namespace "localstack" -o jsonpath="{.items[0].status.addresses[0].address}")

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT lambda create-function \
    --function-name ProcessKinesisRecords \
    --zip-file file://function.zip \
    --handler index.handler \
    --runtime nodejs18.x \
    --role arn:aws:iam::000000000000:role/lambda-kinesis-role

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT lambda wait function-active-v2 --function-name ProcessKinesisRecords

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT lambda invoke \
    --function-name ProcessKinesisRecords \
    --payload file://input.txt outputfile.txt --debug

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis create-stream \
	--stream-name lambda-stream \
	--shard-count 1

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis describe-stream \
	--stream-name lambda-stream

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT lambda create-event-source-mapping \
    --function-name ProcessKinesisRecords \
    --event-source arn:aws:kinesis:us-east-1:000000000000:stream/lambda-stream \
    --batch-size 100 \
    --starting-position LATEST

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis put-record \
    --stream-name lambda-stream \
    --partition-key 1 \
    --data "Hello, world."

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT logs describe-log-streams \
    --log-group-name /aws/lambda/ProcessKinesisRecords

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT logs get-log-events \
    --log-group-name '/aws/lambda/ProcessKinesisRecords' --log-stream-name '2024/09/05/[$LATEST]d9c8884b4286d41954014ebb5cffc215'
```

**kinesis**

```sh
$ export NODE_PORT=$(k get --namespace "localstack" -o jsonpath="{.spec.ports[0].nodePort}" services localstack)
$ export NODE_IP=$(k get nodes --namespace "localstack" -o jsonpath="{.items[0].status.addresses[0].address}")

# Each shard provides 1 MB/sec of write and 2 MB/sec of read throughput
$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis create-stream \
	--stream-name my-kinesis-stream \
	--shard-count 1

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis describe-stream \
	--stream-name my-kinesis-stream

$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis put-record \
	--generate-cli-skeleton

# Put record from json
$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis put-record \
	--stream-name my-kinesis-stream \
	--partition-key 1 \
	--cli-input-json file://test.json

# OR
$ awslocal --endpoint-url=http://$NODE_IP:$NODE_PORT kinesis put-record \
	--stream-name my-kinesis-stream \
	--partition-key 1 \
	--data file://test.json
```

## References

[LocalStack documentation](https://docs.localstack.cloud/overview/)

[LocalStack Github](https://github.com/localstack/helm-charts/tree/main/charts/localstack)

[LocalStack DockerHub](https://hub.docker.com/r/localstack/localstack)
