#!/bin/bash

IMAGE_NAME="hgsc_subtypes"
IMAGE_TAG="2023-03-01"

if [[ ${IMAGE_TAG} = "latest" ]]; then
	docker build --platform linux/amd64 -t hgsc_subtypes:latest .
fi

docker rm --force ${IMAGE_NAME}
docker run --name ${IMAGE_NAME} --platform linux/amd64 -it -w /app -v $PWD:/app ${IMAGE_NAME}:${IMAGE_TAG} /bin/bash
