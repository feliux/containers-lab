# Mlflow server

Deploy Mlflow server with Minio and PostgreSQL backend.

## Usage

1. Deploy `docker-compose up -d`
2. Go Minio webUI `localhost:9001` and create the bucket `bucket-models`
3. Test uploading a pickle file

```sh
$ cd src
$ python -m venv .env
$ source .env/bin/activate
$ pip install -r requirements.txt
$ python train.py
$ python load.py
```

### Extra commands

```bash
# start server
$ mlflow server --host 127.0.0.1 --port 8080
# with sqlite and local artifacts
$ mlflow server --host 127.0.0.1 --port 8080 --backend-store-uri sqlite:///mlflow.db
# with sqlite and artifacts stored on s3
$ mlflow server --host 127.0.0.1 --port 8080 --backend-store-uri sqlite:///mlflow.db --artifacts-destination s3://<bucket>/<path>
# host 0.0.0.0 for docker and k8s
$ mlflow server --host 0.0.0.0 --port 8080 --artifacts-destination s3://<bucket>/<path> --expose-prometheus --workers 1
```

## Referenes

[MLflow Common setups](https://mlflow.org/docs/latest/tracking.html#common-setups)

[MLflow Authentication](https://mlflow.org/docs/latest/auth/index.html)

[Mlflow CLI](https://mlflow.org/docs/latest/cli.html)

[Artifact Stores](https://mlflow.org/docs/latest/tracking/artifacts-stores.html#artifact-stores)

[Backend Stores](https://mlflow.org/docs/latest/tracking/backend-stores.html)

[SQLAlchemy Databases engines](https://docs.sqlalchemy.org/en/20/core/engines.html#database-urls)
