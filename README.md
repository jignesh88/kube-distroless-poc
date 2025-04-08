# Kubernetes Demo: Distroless vs Alpine Images with Snyk

This repository contains a demonstration showcasing the size and security differences between distroless images and regular/Alpine images for Golang, Node.js, and Python applications using Snyk for security scanning.

## What are Distroless Images?

Distroless images contain only your application and its runtime dependencies. They do not contain package managers, shells, or any other programs you would expect to find in a standard Linux distribution. This has several advantages:

- **Smaller image sizes**: Without unnecessary tools, distroless images are often significantly smaller
- **Improved security posture**: Fewer components mean fewer potential vulnerabilities
- **Reduced attack surface**: No shell access limits an attacker's options if they gain access

## Demo Overview

This demo includes:

1. Sample applications in three languages:
   - Golang HTTP server
   - Node.js Express server
   - Python Flask server

2. Dockerfile variants for each application:
   - Distroless version
   - Alpine/regular version

3. Kubernetes deployment manifests

4. Snyk Operator for security scanning

5. Visualization dashboard for comparing results

## Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl installed and configured
- Helm installed
- Docker installed
- Snyk account (free tier available at snyk.io)

## Repository Structure

```
.
├── README.md            # This file
├── setup.sh             # Automated setup script
├── applications/        # Sample application code
│   ├── go-app/          # Golang application
│   ├── node-app/        # Node.js application
│   └── python-app/      # Python application
├── dockerfiles/         # Dockerfile variants
│   ├── Dockerfile.*.distroless  # Distroless versions
│   └── Dockerfile.*.alpine      # Alpine versions
├── kubernetes/          # Kubernetes manifests
│   ├── snyk-operator.yaml
│   ├── *-distroless.yaml
│   ├── *-alpine.yaml
│   └── dashboard.yaml
└── dashboard/           # Visualization dashboard
    └── index.html
```

## Quick Start

The easiest way to set up the demo is to use the provided setup script:

```bash
# Clone the repository
git clone https://github.com/jignesh88/kube-distroless-poc.git
cd kube-distroless-poc

# Make the setup script executable
chmod +x setup.sh

# Run the setup script
./setup.sh
```

The script will:
1. Create a Kubernetes cluster using kind
2. Build all Docker images
3. Install the Snyk Operator
4. Deploy all applications
5. Set up the dashboard

## Manual Setup

If you prefer to set up the demo manually, follow these steps:

### 1. Create a Kubernetes Cluster

```bash
# Start a local Kubernetes cluster using kind
kind create cluster --name distroless-demo

# Verify the cluster is running
kubectl cluster-info
```

### 2. Build Docker Images

```bash
# Build Golang images
docker build -t yourusername/go-distroless:latest -f dockerfiles/Dockerfile.go.distroless applications/go-app/
docker build -t yourusername/go-alpine:latest -f dockerfiles/Dockerfile.go.alpine applications/go-app/

# Build Node.js images
docker build -t yourusername/node-distroless:latest -f dockerfiles/Dockerfile.node.distroless applications/node-app/
docker build -t yourusername/node-alpine:latest -f dockerfiles/Dockerfile.node.alpine applications/node-app/

# Build Python images
docker build -t yourusername/python-distroless:latest -f dockerfiles/Dockerfile.python.distroless applications/python-app/
docker build -t yourusername/python-alpine:latest -f dockerfiles/Dockerfile.python.alpine applications/python-app/

# Push images to your registry
docker push yourusername/go-distroless:latest
# ... and so on for all images
```

### 3. Install Snyk Operator

```bash
# Create namespace for Snyk
kubectl create namespace snyk-monitor

# Install Snyk Operator
helm repo add snyk https://snyk.github.io/kubernetes-monitor
helm repo update

helm install snyk-monitor snyk/kubernetes-monitor \
  --namespace snyk-monitor \
  --set clusterName="distroless-demo" \
  --set integrationApi=https://kubernetes-upstream.snyk.io \
  --set integrationId=<your-snyk-integration-id>
```

### 4. Deploy Applications

```bash
# Update image references in YAML files first

# Apply Kubernetes manifests
kubectl apply -f kubernetes/golang-distroless.yaml
kubectl apply -f kubernetes/golang-alpine.yaml
kubectl apply -f kubernetes/nodejs-distroless.yaml
kubectl apply -f kubernetes/nodejs-alpine.yaml
kubectl apply -f kubernetes/python-distroless.yaml
kubectl apply -f kubernetes/python-alpine.yaml

# Verify deployments
kubectl get pods
```

### 5. Deploy Dashboard

```bash
# Create ConfigMap with dashboard HTML
kubectl create configmap image-dashboard --from-file=dashboard/index.html

# Deploy dashboard
kubectl apply -f kubernetes/dashboard.yaml

# Access the dashboard
kubectl port-forward svc/dashboard 8080:80
```

## Expected Results

### Size Comparison

The distroless images are significantly smaller than their Alpine counterparts:

| Language | Distroless Size | Alpine Size |
|----------|----------------|-------------|
| Go       | ~7MB          | ~15MB       |
| Node.js  | ~120MB        | ~180MB      |
| Python   | ~130MB        | ~220MB      |

### Security Comparison

The Snyk scan typically shows:

1. **Fewer vulnerabilities** in distroless images
2. **Lower severity** vulnerabilities overall
3. **Smaller attack surface** due to the absence of package managers, shells, etc.

## Cleanup

```bash
# Delete applications
kubectl delete -f kubernetes/golang-distroless.yaml
kubectl delete -f kubernetes/golang-alpine.yaml
kubectl delete -f kubernetes/nodejs-distroless.yaml
kubectl delete -f kubernetes/nodejs-alpine.yaml
kubectl delete -f kubernetes/python-distroless.yaml
kubectl delete -f kubernetes/python-alpine.yaml
kubectl delete -f kubernetes/dashboard.yaml

# Uninstall Snyk Operator
helm uninstall snyk-monitor -n snyk-monitor

# Delete the namespace
kubectl delete namespace snyk-monitor

# Delete the cluster
kind delete cluster --name distroless-demo
```

## Conclusion

This demo highlights the advantages of distroless images over Alpine/regular images:

1. **Size Benefits**:
   - Distroless images are significantly smaller (up to 50% reduction)
   - Especially beneficial for Golang applications (~7MB vs ~15MB)

2. **Security Benefits**:
   - Fewer vulnerabilities in Snyk scans
   - Reduced attack surface (no shell, package manager, etc.)
   - Follows the principle of least privilege

3. **Practical Implications**:
   - Faster deployment times
   - Lower bandwidth usage
   - Better resource utilization
   - Improved security posture

Distroless images are ideal for production environments where security is a priority, while Alpine images may be more suitable for development or when debugging capabilities are needed.

## License

MIT