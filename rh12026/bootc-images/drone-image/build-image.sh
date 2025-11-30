IMAGE_NAME=quay.io/kenosborn/drone-image
IMAGE_TAG=v1

sudo podman build -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -f Containerfile
