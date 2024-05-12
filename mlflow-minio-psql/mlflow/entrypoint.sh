#!/usr/bin/env bash

set -e

mlflow server \
	--host ${MLFLOW_HOST} \
    --port ${MLFLOW_PORT} \
    --backend-store-uri ${MLFLOW_BACKEND_STORE_URI} \
    --artifacts-destination ${MLFLOW_ARTIFACTS_DESTINATION} \
    --workers ${MLFLOW_WORKERS} \
    --app-name ${MLFLOW_APP_NAME} \
    --expose-prometheus ${PROMETHEUS_FOLDER}
