#!/bin/bash

IMAGE_NAME="rlab"
IMAGE_VERSION=$(cat version)
CONTAINER_NAME="rlab"

docker rm -f $CONTAINER_NAME && docker rmi $IMAGE_NAME:$IMAGE_VERSION

docker build -f "Dockerfile" -t $IMAGE_NAME:$IMAGE_VERSION .

docker run --rm -d --name $CONTAINER_NAME $IMAGE_NAME:$IMAGE_VERSION
