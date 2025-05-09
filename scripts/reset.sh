#!/bin/bash

echo "Executing Script"
sleep 2

echo "Gathering ArgoCD information..."
ARGOCD_URL=$(oc get route openshift-gitops-server -n openshift-gitops -o go-template --template '{{ .spec.host }}')
ARGOCD_USERNAME=admin
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster -n openshift-gitops -o go-template='{{ index .data "admin.password" | base64decode }}')

echo "Logging in to ArgoCD..."
argocd login "$ARGOCD_URL" --username "$ARGOCD_USERNAME" --password "$ARGOCD_PASSWORD" --grpc-web --skip-test-tls

echo "Turning off auto-sync on parent app..."
#oc patch application.argoproj.io/student-services -n openshift-gitops --type=json -p '[{"op": "remove", "path": "/spec/syncPolicy/automated"}]'

echo "Deleting student virtual machines..."
#argocd app delete openshift-gitops/registry-auth --cascade --yes --grpc-web --wait
#argocd app delete openshift-gitops/student-virtual-machines --cascade --yes --grpc-web --wait
#argocd app delete openshift-gitops/example-store-devices --cascade --yes --grpc-web --wait
#argocd app delete openshift-gitops/build-bootc-images --cascade --yes --grpc-web --wait

#echo "Cleaning up existing image resources..."
#oc delete ImageStreamTag rhel9-bootc-edgemanager-base:1.0.0 rhel9-bootc-edgemanager-pos-prod:1.0.0 -n student-services
#oc delete DataVolume rhel9-bootc-edgemanager-base-1.0.0 rhel9-bootc-edgemanager-pos-prod-1.0.0 -n student-services

#echo "Turning auto-sync back on..."
#oc patch application.argoproj.io/student-services -n openshift-gitops --type=json -p '[{"op": "add", "path": "/spec/syncPolicy/automated", "value": {}}]'

#echo "Forcing immediate sync..."
#argocd app sync openshift-gitops/student-services

echo "Script Complete"
