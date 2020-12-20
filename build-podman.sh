#!/bin/bash

set +x
IMAGE_NAME=nginx
OS_RELEASE=${OS_RELEASE:-$(grep VERSION_ID /etc/os-release | cut -d '=' -f 2)}
OS_IMAGE=${OS_IMAGE:-"registry.fedoraproject.org/fedora:${OS_RELEASE}"}
BUILD_ID=${BUILD_ID:-`date +%s`}
BUILD_ARCH=${BUILD_ARCH:-`uname -m`}
PUSHREG=${PUSHREG:-""}

echo sudo podman build --build-arg OS_RELEASE=${OS_RELEASE} --build-arg OS_IMAGE=${OS_IMAGE} -t ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} -f Containerfile
sudo podman build --build-arg OS_RELEASE=${OS_RELEASE} --build-arg OS_IMAGE=${OS_IMAGE} -t ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} -f Containerfile


if [ $? -eq 0 ]; then
  echo sudo  podman tag ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} ${BUILD_ARCH}/${IMAGE_NAME}:latest
  sudo podman tag ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} ${BUILD_ARCH}/${IMAGE_NAME}:latest

  if [ ! -z "${PUSHREG}" ]; then
    echo sudo podman tag ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID}
    sudo podman tag ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID}
    echo sudo podman push ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID}
    sudo podman push ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID}
    echo sudo podman tag ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:latest
    sudo podman tag ${BUILD_ARCH}/${IMAGE_NAME}:${BUILD_ID} ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:latest
    echo sudo podman push ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:latest
    sudo podman push ${PUSHREG}/${BUILD_ARCH}/${IMAGE_NAME}:latest
  fi
fi

