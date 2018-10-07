#!/bin/bash
set -e
CLUSTER_NAME=${1}
SERVICE_NAME=${2}

echo "TODO: Figure out the way to update a container."
# aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --force-new-deployment
