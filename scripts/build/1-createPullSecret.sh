#!/bin/bash

# Script to create ~/.pull-secret.json for quay.io
# Author: Ken Osborn
# Creation Date: 28-Jul-25

PULL_SECRET="$HOME/.pull-secret.json"

read -p "Enter your quay.io username: " REGISTRY_USER
read -s -p "Enter your quay.io password/token: " REGISTRY_PASS
echo

# Generate base64 auth string without newlines
AUTH_STRING=$(echo -n "${REGISTRY_USER}:${REGISTRY_PASS}" | base64 -w0)

# Write pull secret
cat > "$PULL_SECRET" <<EOF
{
  "auths": {
    "quay.io": {
      "auth": "${AUTH_STRING}"
    }
  }
}
EOF

chmod 600 "$PULL_SECRET"

# Validate JSON
if ! jq empty "$PULL_SECRET" >/dev/null 2>&1; then
  echo "❌ Error: Generated $PULL_SECRET is not valid JSON"
  exit 1
fi

echo "✅ Pull secret created and validated at $PULL_SECRET"

