FROM python:3.12.2-slim

ENV GID=1000 \
    UID=1000 \
    USER=mlflow \
    WORKDIR_PATH=/app

WORKDIR $WORKDIR_PATH

USER root

COPY mlflow/requirements.txt .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt && \
    chown -R $UID:$GID $WORKDIR_PATH

COPY mlflow/entrypoint.sh .

ENTRYPOINT ["bash", "entrypoint.sh"]
