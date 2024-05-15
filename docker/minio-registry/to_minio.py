from datetime import datetime, timedelta
import logging
import os
from minio import Minio
from minio.error import ResponseError
from dotenv import load_dotenv
from pathlib import Path

env_path = Path("environment/minio.env")
load_dotenv(dotenv_path=env_path)

_MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY")
_MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY")
_DOCKER_BUCKET = os.getenv("DOCKER_BUCKET")
_PYTHON_BUCKET = os.getenv("PYTHON_BUCKET")

_PYTHON_PACKAGE = "Hello_Universe-0.0.1.tar.gz"
_PATH_TO_PACKAGE = "package/dist/"

minioClient = Minio(
    "172.20.0.2:9000", 
    access_key=_MINIO_ACCESS_KEY, 
    secret_key=_MINIO_SECRET_KEY, 
    secure=False
    )

if not minioClient.bucket_exists(_PYTHON_BUCKET):
    minioClient.make_bucket(_PYTHON_BUCKET)
    print("Bucket " + _PYTHON_BUCKET + " created\n")
else:
    print("Bucket " + _PYTHON_BUCKET + " already exists\n")

minioClient.fput_object(
    bucket_name=_PYTHON_BUCKET, 
    object_name=_PYTHON_PACKAGE, 
    file_path=_PATH_TO_PACKAGE + _PYTHON_PACKAGE
    )

objects = minioClient.list_objects(bucket_name=_PYTHON_BUCKET)

for object in objects:
    print(object)