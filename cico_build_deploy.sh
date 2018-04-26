#!/bin/bash

# Show command before executing
set -x

# Exit on error
set -e

# Export needed vars
for var in GIT_COMMIT DEVSHIFT_USERNAME DEVSHIFT_PASSWORD DEVSHIFT_TAG_LEN; do
  export $(grep ${var} jenkins-env | xargs)
done
export BUILD_TIMESTAMP=`date -u +%Y-%m-%dT%H:%M:%S`+00:00

# We need to disable selinux for now, XXX
/usr/sbin/setenforce 0 || :

# Get all the deps in
yum -y install docker
yum clean all
service docker start

# Build the app

IMAGE="zabbix-status-api"
REGISTRY="push.registry.devshift.net"
TAG=$(echo $GIT_COMMIT | cut -c1-${DEVSHIFT_TAG_LEN})

if [ -n "${DEVSHIFT_USERNAME}" -a -n "${DEVSHIFT_PASSWORD}" ]; then
  docker login -u ${DEVSHIFT_USERNAME} -p ${DEVSHIFT_PASSWORD} ${REGISTRY}
else
  echo "Could not login, missing credentials for the registry"
fi

if [ "$TARGET" = "rhel" ]; then
  DOCKERFILE="Dockerfile.rhel"
  IMAGE_URL="${REGISTRY}/osio-prod/openshiftio/${IMAGE}"
else
  DOCKERFILE="Dockerfile.rhel"
  IMAGE_URL="${REGISTRY}/openshiftio/${IMAGE}"
fi

docker build -t ${IMAGE} -f "${DOCKERFILE}" .

docker tag ${IMAGE} ${IMAGE_URL}:$TAG
docker push ${IMAGE_URL}:$TAG

docker tag ${IMAGE} ${IMAGE_URL}:latest
docker push ${IMAGE_URL}:latest
