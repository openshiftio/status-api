#!/bin/bash

# Show command before executing
set -x

# Exit on error
set -e

# Export needed vars
for var in GIT_COMMIT; do
  export $(grep ${var} jenkins-env | xargs)
done
export BUILD_TIMESTAMP=`date -u +%Y-%m-%dT%H:%M:%S`+00:00

# We need to disable selinux for now, XXX
/usr/sbin/setenforce 0

# Get all the deps in
yum -y install docker
yum clean all
service docker start

# Build the app

IMAGE="zabbix-status-api"
REPOSITORY="registry.devshift.net/openshiftio/"

docker build -t ${IMAGE} -f Dockerfile .

TAG=$(echo $GIT_COMMIT | cut -c1-6)

docker tag ${IMAGE} ${REPOSITORY}/${IMAGE}:$TAG && \
docker push ${REPOSITORY}/${IMAGE}:$TAG && \
docker tag ${IMAGE} ${REPOSITORY}/${IMAGE}:latest && \
docker push ${REPOSITORY}/${IMAGE}:latest
if [ $? -eq 0 ]; then
  echo 'CICO: image pushed, ready to update deployed app'
  exit 0
else
  echo 'CICO: Image push to registry failed'
  exit 2
fi
