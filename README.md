# Kubernetes Distroless vs Alpine Images Demo with Snyk

This repository contains a demonstration showcasing the size and security differences between distroless images and regular/Alpine images for Golang, Node.js, and Python applications using Snyk for security scanning.

## Overview

This demo compares:
- Distroless images vs Alpine/regular images
- Image sizes
- Security vulnerabilities detected by Snyk
- Overall security posture

## Repository Structure

```
.
├── README.md
├── applications/
│   ├── go-app/
│   │   └── main.go
│   ├── node-app/
│   │   ├── index.js
│   │   └── package.json
│   └── python-app/
│       ├── app.py
│       └── requirements.txt
├── dockerfiles/
│   ├── Dockerfile.go.distroless
│   ├── Dockerfile.go.alpine
│   ├── Dockerfile.node.distroless
│   ├── Dockerfile.node.alpine
│   ├── Dockerfile.python.distroless
│   └── Dockerfile.python.alpine
├── kubernetes/
│   ├── snyk-operator.yaml
│   ├── golang-distroless.yaml
│   ├── golang-alpine.yaml
│   ├── nodejs-distroless.yaml
│   ├── nodejs-alpine.yaml
│   ├── python-distroless.yaml
│   ├── python-alpine.yaml
│   └── dashboard.yaml
└── dashboard/
    └── index.html
```

## Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl installed and configured
- Helm installed
- Docker installed
- Snyk account (free tier available at snyk.io)

## Usage

1. Clone this repository
2. Follow the instructions in the documentation to set up your Kubernetes cluster
3. Install the Snyk Operator
4. Build and deploy the sample applications
5. Analyze the results with Snyk

For detailed instructions, see the full documentation.

## Benefits of Distroless Images

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

## License

MIT