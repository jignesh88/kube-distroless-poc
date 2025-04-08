#!/bin/bash

# Exit on error
set -e

echo "=== Cleaning up Kubernetes Distroless vs Alpine Security Demo ==="

echo "Deleting all deployed applications..."
kubectl delete -f kubernetes/golang-distroless-updated.yaml 2>/dev/null || true
kubectl delete -f kubernetes/golang-alpine-updated.yaml 2>/dev/null || true
kubectl delete -f kubernetes/nodejs-distroless-updated.yaml 2>/dev/null || true
kubectl delete -f kubernetes/nodejs-alpine-updated.yaml 2>/dev/null || true
kubectl delete -f kubernetes/python-distroless-updated.yaml 2>/dev/null || true
kubectl delete -f kubernetes/python-alpine-updated.yaml 2>/dev/null || true
kubectl delete -f kubernetes/dashboard.yaml 2>/dev/null || true
kubectl delete configmap image-dashboard 2>/dev/null || true

echo "Uninstalling Snyk Operator..."
kubectl delete -f snyk-operator-updated.yaml 2>/dev/null || true

echo "Deleting Snyk namespace..."
kubectl delete namespace snyk-monitor 2>/dev/null || true

echo "Removing temporary files..."
rm -f snyk-operator-updated.yaml 2>/dev/null || true
rm -f kubernetes/*-updated.yaml 2>/dev/null || true

echo "Would you like to delete the Kubernetes cluster? (y/n)"
read -p "> " DELETE_CLUSTER

if [ "$DELETE_CLUSTER" = "y" ]; then
  echo "Deleting the Kubernetes cluster..."
  kind delete cluster --name distroless-demo
  echo "Cluster deleted."
fi

echo "Cleanup complete!"
