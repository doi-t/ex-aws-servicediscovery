#!/bin/bash
set -ex
CLUSTER_NAME=${1}
IMAGE_NAME=${2}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPOSITORY_NAME='ex-aws-servicediscovery'
IMAGE_TAG="${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${REPOSITORY_NAME}-${IMAGE_NAME}"

if [ ${IMAGE_NAME} = "example-worker" ]; then
    EXAMPLE_DIR=$(echo ${EXAMPLE_CODE} | cut -f1 -d/)
    CHAPTER=$(echo ${EXAMPLE_CODE} | cut -f2 -d/)
    EXAMPLE=$(echo ${EXAMPLE_CODE} | cut -f3 -d/)
    docker build -f Dockerfile.${IMAGE_NAME} \
        --build-arg example_dir=${EXAMPLE_DIR}\
        --build-arg chapter=${CHAPTER}\
        --build-arg example=${EXAMPLE}\
        -t ${IMAGE_TAG} .
else
    docker build -f Dockerfile.${IMAGE_NAME} -t ${IMAGE_TAG} .
fi
$(aws ecr get-login --region ap-northeast-1 --no-include-email)
docker push ${IMAGE_TAG}
