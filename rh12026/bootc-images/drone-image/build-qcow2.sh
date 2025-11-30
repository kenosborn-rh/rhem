#!/usr/bin/env bash

IMAGE_NAME=quay.io/kenosborn/drone-image

mkdir ./output
sudo podman run --rm -it \
    --privileged \
    --security-opt label=type:unconfined_t \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    -v ./output:/output \
    registry.redhat.io/rhel9/bootc-image-builder:latest \
    --type qcow2 \
    ${IMAGE_NAME}:v1
