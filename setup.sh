#!/bin/bash

# Exit on error
set -e

echo "=== Kubernetes Distroless vs Alpine Security Demo ==="
echo "This script will setup the demo environment."

# Check for required tools
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed. Aborting."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "docker is required but not installed. Aborting."; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "helm is required but not installed. Aborting."; exit 1; }

# Prompt for registry URL
echo ""
read -p "Enter your container registry URL (e.g., docker.io/username): " REGISTRY_URL

# Prompt for Snyk integration ID
echo ""
read -p "Enter your Snyk integration ID: " SNYK_INTEGRATION_ID

# Setup Kubernetes cluster using kind
echo ""
echo "Setting up Kubernetes cluster using kind..."
kind create cluster --name distroless-demo

# Verify cluster is running
kubectl cluster-info

# Build Docker images
echo ""
echo "Building Docker images..."

# Create temporary build directories
mkdir -p tmp/go-app tmp/node-app tmp/python-app

# Copy application files to tmp directories
cp -r applications/go-app/* tmp/go-app/
cp -r applications/node-app/* tmp/node-app/
cp -r applications/python-app/* tmp/python-app/

# Fix Dockerfile paths
sed "s|../applications/go-app/|./|g" dockerfiles/Dockerfile.go.distroless > tmp/Dockerfile.go.distroless
sed "s|../applications/go-app/|./|g" dockerfiles/Dockerfile.go.alpine > tmp/Dockerfile.go.alpine
sed "s|../applications/node-app/|./|g" dockerfiles/Dockerfile.node.distroless > tmp/Dockerfile.node.distroless
sed "s|../applications/node-app/|./|g" dockerfiles/Dockerfile.node.alpine > tmp/Dockerfile.node.alpine
sed "s|../applications/python-app/|./|g" dockerfiles/Dockerfile.python.distroless > tmp/Dockerfile.python.distroless
sed "s|../applications/python-app/|./|g" dockerfiles/Dockerfile.python.alpine > tmp/Dockerfile.python.alpine

# Build Go images
echo "Building Go images..."
cd tmp/go-app
docker build -t $REGISTRY_URL/go-distroless:latest -f ../Dockerfile.go.distroless .
docker build -t $REGISTRY_URL/go-alpine:latest -f ../Dockerfile.go.alpine .
cd ../..

# Build Node.js images
echo "Building Node.js images..."
cd tmp/node-app
docker build -t $REGISTRY_URL/node-distroless:latest -f ../Dockerfile.node.distroless .
docker build -t $REGISTRY_URL/node-alpine:latest -f ../Dockerfile.node.alpine .
cd ../..

# Build Python images
echo "Building Python images..."
cd tmp/python-app
docker build -t $REGISTRY_URL/python-distroless:latest -f ../Dockerfile.python.distroless .
docker build -t $REGISTRY_URL/python-alpine:latest -f ../Dockerfile.python.alpine .
cd ../..

# Clean up temp directories
rm -rf tmp

# Compare image sizes
echo ""
echo "Image size comparison:"
docker images | grep "$REGISTRY_URL"

# Push images to registry
echo ""
read -p "Do you want to push images to the registry? (y/n): " PUSH_IMAGES
if [ "$PUSH_IMAGES" = "y" ]; then
  echo "Pushing images to registry..."
  docker push $REGISTRY_URL/go-distroless:latest
  docker push $REGISTRY_URL/go-alpine:latest
  docker push $REGISTRY_URL/node-distroless:latest
  docker push $REGISTRY_URL/node-alpine:latest
  docker push $REGISTRY_URL/python-distroless:latest
  docker push $REGISTRY_URL/python-alpine:latest
fi

# Install Snyk Operator
echo ""
echo "Installing Snyk Operator..."

# Create namespace for Snyk
kubectl create namespace snyk-monitor

# Create base64 encoded values for Snyk secret
SNYK_INTEGRATION_ID_B64=$(echo -n "$SNYK_INTEGRATION_ID" | base64)
DOCKERCFG_B64=$(echo -n '{}' | base64)

# Update Snyk Operator YAML with actual values
sed "s/<base64-encoded-integration-id>/$SNYK_INTEGRATION_ID_B64/g" kubernetes/snyk-operator.yaml | \
sed "s/<base64-encoded-dockercfg>/$DOCKERCFG_B64/g" > snyk-operator-updated.yaml

# Apply the updated Snyk Operator YAML
kubectl apply -f snyk-operator-updated.yaml

# Update Kubernetes manifests with registry URL
for file in kubernetes/golang-distroless.yaml kubernetes/golang-alpine.yaml \
           kubernetes/nodejs-distroless.yaml kubernetes/nodejs-alpine.yaml \
           kubernetes/python-distroless.yaml kubernetes/python-alpine.yaml; do
  sed "s|\${REGISTRY_URL}|$REGISTRY_URL|g" $file > ${file%.yaml}-updated.yaml
done

# Apply Kubernetes manifests
echo ""
echo "Deploying applications..."
kubectl apply -f kubernetes/golang-distroless-updated.yaml
kubectl apply -f kubernetes/golang-alpine-updated.yaml
kubectl apply -f kubernetes/nodejs-distroless-updated.yaml
kubectl apply -f kubernetes/nodejs-alpine-updated.yaml
kubectl apply -f kubernetes/python-distroless-updated.yaml
kubectl apply -f kubernetes/python-alpine-updated.yaml

# Create dashboard ConfigMap
echo ""
echo "Creating dashboard..."
kubectl create configmap image-dashboard --from-file=dashboard/index.html
kubectl apply -f kubernetes/dashboard.yaml

# Get dashboard URL
DAHSBOARD_PORT=$(kubectl get svc dashboard -o jsonpath='{.spec.ports[0].nodePort}')
echo ""
echo "Dashboard available at: http://localhost:$DAHSBOARD_PORT"
echo "For minikube, run: minikube service dashboard"

echo ""
echo "Setup complete! The Snyk Operator will start scanning your deployments."
echo "Check your Snyk dashboard for results after a few minutes."

# Clean up generated files
rm snyk-operator-updated.yaml
rm kubernetes/*-updated.yaml