# Manual RHEM install procedure on OpenShift
## Description
Procedure to remove an existing ACM Operator installation of RHEM then install desired version of RHEM (not utilizing the ACM Operator)

## Remove RHEM
1. Disable any upper-level orchestration if present (e.g. ArgoCD: acm-rhem app | disable auto-sync)

2. Remove the RHEM installation from the ACM Operator
```
oc patch multiclusterhubs.operator.open-cluster-management.io multiclusterhub -n open-cluster-management --type json --patch '[{"op": "remove", "path":"/spec/overrides/components"}]'
```
3. Wait for the ConsolePlugin to refresh

<img src="./images/web-console-refresh.png" alt="alt text" width="75%">

4. Annotate the Multi Cluster Hub to pause so it does not attempt to reconcile RHEM (e.g. remove it)
```
oc annotate mce multiclusterengine pause=true --overwrite
```

```
oc annotate -n open-cluster-management `oc get mch -oname -n open-cluster-management | head -n1` mch-pause=true --overwrite=true
```
5. Confirm that MCH is in Phase: Paused

<img src="./images/mch-paused.png" alt="alt text" width="75%">

## Install Desired [version](https://quay.io/repository/flightctl/flightctl-api) of RHEM

Note: storageClassName will need to be set to requisite value for installed to env; here, we use our common OCP on AWS storageClassName

```
helm upgrade --install --version=0.8.1 \
  --namespace flightctl --create-namespace flightctl oci://quay.io/flightctl/charts/flightctl \
  --values - <<EOF
global:
  target: "acm"
  storageClassName: "ocs-external-storagecluster-ceph-rbd"
  auth:
    insecureSkipTlsVerify: true
db:
  storage:
    size: "20Gi"
EOF
```

6. Wait for the ConsolePlugin to refresh

<img src="./images/web-console-refresh.png" alt="alt text" width="75%">

7. Confirm Edge Manager avilability

<img src="./images/edge-management.png" alt="alt text" width="75%">

## Uninstall

1. Issue helm command
```
helm uninstall flightctl --namespace flightctl
```

```
oc delete namespace flightctl
```



Scratch (latest - test, not released - version)
```
helm upgrade --install --version=0.9.0-main-221-gbd706dd7 \
  --namespace flightctl --create-namespace flightctl oci://quay.io/flightctl/charts/flightctl \
  --values - <<EOF
global:
  target: "acm"
  storageClassName: "ocs-external-storagecluster-ceph-rbd"
  auth:
    insecureSkipTlsVerify: true
db:
  storage:
    size: "20Gi"
EOF
```

```
#!/bin/bash

MCH_NAME="multiclusterhub"
MCH_NAMESPACE="open-cluster-management"
COMPONENT_NAME="edge-manager-preview"

# Step 1: Get the entire MCH resource to avoid multiple calls
MCH_JSON=$(oc get multiclusterhub "$MCH_NAME" -n "$MCH_NAMESPACE" -o json)

if [[ -z "$MCH_JSON" ]]; then
  echo "❌ Failed to get MultiClusterHub resource '$MCH_NAME' in namespace '$MCH_NAMESPACE'. Exiting."
  exit 1
fi

# Step 2: Find the component's index and its 'enabled' status in one go
COMPONENT_DATA=$(echo "$MCH_JSON" | jq -r --arg name "$COMPONENT_NAME" '
    .spec.overrides.components | to_entries 
    | map(select(.value.name == $name)) 
    | .[0] 
    | "\(.key) \(.value.enabled // "null")"')

# Read the found index and status into separate variables
read -r INDEX CURRENT_ENABLED <<< "$COMPONENT_DATA"

# Step 3: Evaluate and act
if [[ "$CURRENT_ENABLED" == "false" ]]; then
  echo "✅ '$COMPONENT_NAME' is already disabled. No action taken."

elif [[ "$CURRENT_ENABLED" == "true" ]]; then
  echo "⚙️ Disabling '$COMPONENT_NAME' at index $INDEX..."
  # Use a precise JSON patch to replace the value at the correct index
  oc patch multiclusterhub "$MCH_NAME" -n "$MCH_NAMESPACE" --type='json' \
    -p="[{'op': 'replace', 'path': '/spec/overrides/components/$INDEX/enabled', 'value': false}]" \
    && echo "✅ Patch applied successfully."

elif [[ -z "$INDEX" || "$CURRENT_ENABLED" == "null" ]]; then
  echo "⚠️ '$COMPONENT_NAME' was not found in the component override list. Nothing was changed."
  
else
  echo "❌ Unexpected state for '$COMPONENT_NAME'. Index: '$INDEX', Enabled: '$CURRENT_ENABLED'"
fi

# to get state of enabled components
oc get multiclusterhub multiclusterhub -n open-cluster-management -o json | jq '.spec.overrides.components[] | {name, enabled}'
```

oc patch multiclusterhubs.operator.open-cluster-management.io multiclusterhub \
  -n open-cluster-management \
  --type json \
  --patch '[{"op": "add", "path":"/spec/overrides/components/-", "value": {"name":"edge-manager-preview","enabled": true}}]'


flightctl login https://api.apps.cluster-bl2vp.dynamic.redhatworkshops.io --username admin --password 8kP4kLpLToS3 --insecure-skip-tls-verify

Delete:
wget -q http://content.example.com/rhde/oci/microshift-containers.tar.gz
tar xzf microshift-containers.tar.gz
ls microshift-containers/
lvms4  openshift-release-dev
wget -q http://content.example.com/rhde/oci/app-containers.tar.gz
tar xzf app-containers.tar.gz
 ls app-containers
extra-images-list.txt  flozanorht  rhel9  ubi9