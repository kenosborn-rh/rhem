#!/bin/bash

# Script to test quay.io login using ~/.pull-secret.json
# Author: Ken Osborn
# Creation Date: 28-Jul-25

PULL_SECRET="${PULL_SECRET:-$HOME/.pull-secret.json}"

if [ ! -f "$PULL_SECRET" ]; then
  echo "Error: Pull secret not found at $PULL_SECRET"
  exit 1
fi

echo "Extracting quay.io credentials from $PULL_SECRET..."

REGISTRY_USER=$(jq -r '.auths["quay.io"].auth' "$PULL_SECRET" | base64 -d | cut -d: -f1)
REGISTRY_PASS=$(jq -r '.auths["quay.io"].auth' "$PULL_SECRET" | base64 -d | cut -d: -f2)

if [ -z "$REGISTRY_USER" ] || [ -z "$REGISTRY_PASS" ]; then
  echo "Error: Could not extract quay.io credentials from $PULL_SECRET"
  exit 1
fi

echo "Testing sudo podman login to quay.io as ${REGISTRY_USER}..."
echo "$REGISTRY_PASS" | sudo podman login quay.io --username "$REGISTRY_USER" --password-stdin

if [ $? -eq 0 ]; then
  echo "✅ Login successful with pull secret."
else
  echo "❌ Login failed. Check credentials in $PULL_SECRET."
  exit 1
fi

