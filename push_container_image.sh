#!/bin/bash
set -e
CLUSTER_NAME=${1}
IMAGE_NAME=${2}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPOSITORY_NAME='ex-aws-servicediscovery-ecr'
IMAGE_TAG="${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${REPOSITORY_NAME}-${IMAGE_NAME}"

docker build -f Dockerfile.${IMAGE_NAME} -t ${IMAGE_TAG} .
$(aws ecr get-login --region ap-northeast-1 --no-include-email)
docker push ${IMAGE_TAG}
