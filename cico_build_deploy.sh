#!/bin/bash

# Show command before executing
set -x

# Exit on error
set -e

# Export needed vars
eval "$(./env-toolkit load -f jenkins-env.json GIT_COMMIT QUAY_USERNAME QUAY_PASSWORD DEVSHIFT_TAG_LEN)"

# We need to disable selinux for now, XXX
/usr/sbin/setenforce 0 || :

# Get all the deps in
yum -y install docker
yum clean all
service docker start

# Build the app

IMAGE="openshiftio-zabbix-status-api"
REGISTRY="quay.io"
TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})

if [ -n "${QUAY_USERNAME}" -a -n "${QUAY_PASSWORD}" ]; then
  docker login -u ${QUAY_USERNAME} -p ${QUAY_PASSWORD} ${REGISTRY}
else
  echo "Could not login, missing credentials for the registry"
  exit 1
fi

if [ "$TARGET" = "rhel" ]; then
  DOCKERFILE="Dockerfile.rhel"
  IMAGE_URL="${REGISTRY}/openshiftio/rhel-${IMAGE}"
else
  DOCKERFILE="Dockerfile.rhel"
  IMAGE_URL="${REGISTRY}/openshiftio/${IMAGE}"
fi

docker build -t ${IMAGE} -f "${DOCKERFILE}" .

docker tag ${IMAGE} ${IMAGE_URL}:$TAG
docker push ${IMAGE_URL}:$TAG

docker tag ${IMAGE} ${IMAGE_URL}:latest
docker push ${IMAGE_URL}:latest
