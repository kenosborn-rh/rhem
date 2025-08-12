#!/bin/bash

# Usage: ./build.sh <REGISTRY_URL> <IMAGE_NAME> <IMAGE_TAG> [--build] [--push] [--disk iso|qcow2]

set -e

REGISTRY_URL=$1
IMAGE_NAME=$2
IMAGE_TAG=$3
shift 3

BUILD_FLAG=false
PUSH_FLAG=false
DISK_TYPE=""

# --- Parse flags ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build)
      BUILD_FLAG=true
      ;;
    --push)
      PUSH_FLAG=true
      ;;
    --disk)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "❌ Missing disk type. Usage: --disk iso|qcow2"
        exit 1
      fi
      if [[ "$2" != "iso" && "$2" != "qcow2" ]]; then
        echo "❌ Invalid disk type '$2'. Use iso or qcow2."
        exit 1
      fi
      DISK_TYPE="$2"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 <REGISTRY_URL> <IMAGE_NAME> <IMAGE_TAG> [--build] [--push] [--disk iso|qcow2]"
      exit 1
      ;;
  esac
  shift
done

FULL_IMAGE="${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}"

# --- Check prerequisites ---
if [ ! -f "config.yaml" ]; then
  echo "❌ config.yaml missing."
  echo "Run: flightctl certificate request --signer=enrollment --expiration=365d --output=embedded > config.yaml"
  exit 1
fi

if $BUILD_FLAG && [ ! -f "Containerfile" ]; then
  echo "❌ Containerfile missing."
  exit 1
fi

# --- Build container image (optional) ---
if $BUILD_FLAG; then
  echo "Building container image: ${FULL_IMAGE}"
  sudo podman build -t "${FULL_IMAGE}" -f Containerfile
  echo "✅ Container image built successfully."
else
  echo "⏩ Skipping container image build (no --build flag provided)."
fi

# --- Push container image (optional) ---
if $PUSH_FLAG; then
  echo "Extracting quay.io credentials from $HOME/.pull-secret.json"
  REGISTRY_USER=$(jq -r '.auths["quay.io"].auth' "$HOME/.pull-secret.json" | base64 -d | cut -d: -f1)
  REGISTRY_PASS=$(jq -r '.auths["quay.io"].auth' "$HOME/.pull-secret.json" | base64 -d | cut -d: -f2)

  if [ -z "$REGISTRY_USER" ] || [ -z "$REGISTRY_PASS" ]; then
    echo "❌ Failed to extract quay.io credentials from $HOME/.pull-secret.json"
    exit 1
  fi

  echo "Logging into ${REGISTRY_URL} as ${REGISTRY_USER}"
  echo "$REGISTRY_PASS" | sudo podman login --username "$REGISTRY_USER" --password-stdin "$REGISTRY_URL"

  echo "Pushing image: ${FULL_IMAGE}"
  sudo podman push "${FULL_IMAGE}"
  echo "✅ Image pushed successfully!"
else
  echo "⏩ Skipping push (no --push flag provided)."
fi

# --- Build disk image (optional) ---
if [ -n "$DISK_TYPE" ]; then
  if [ -d "./output" ]; then
    echo "❌ output folder is already present; please decide if you need to archive the existing content there then remove it before re-running the script."
    exit 1
  fi

  mkdir ./output

  if [ "$DISK_TYPE" == "iso" ]; then
    if [ ! -f "config.toml" ]; then
      echo "❌ config.toml missing. Required to build ISO disk image."
      exit 1
    fi
    echo "Building ISO disk image for ${FULL_IMAGE}"
    sudo podman run --rm -it \
      --privileged \
      --security-opt label=type:unconfined_t \
      -v /var/lib/containers/storage:/var/lib/containers/storage \
      -v "$(pwd)/config.toml:/config.toml" \
      -v ./output:/output \
      registry.redhat.io/rhel9/bootc-image-builder:latest \
      --type iso \
      "${FULL_IMAGE}"
    echo "✅ ISO image built in ./output"
  fi

  if [ "$DISK_TYPE" == "qcow2" ]; then
    echo "Building qcow2 disk image for ${FULL_IMAGE}"
    sudo podman run --rm -it \
      --privileged \
      --security-opt label=type:unconfined_t \
      -v /var/lib/containers/storage:/var/lib/containers/storage \
      -v ./output:/output \
      registry.redhat.io/rhel9/bootc-image-builder:latest \
      --type qcow2 \
      "${FULL_IMAGE}"
    echo "✅ qcow2 image built in ./output"
  fi
else
  echo "⏩ Skipping disk image build (no --disk flag provided)."
fi

