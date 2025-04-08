# Kubernetes Demo: Distroless vs Alpine Images with Snyk

This demo showcases the size and security differences between distroless images and regular/Alpine images for Golang, Node.js, and Python applications using Snyk for security scanning.

## Overview

We'll compare:
- Distroless images vs Alpine/regular images
- Image sizes
- Security vulnerabilities detected by Snyk
- Overall security posture

## Prerequisites

- Kubernetes cluster (minikube, kind, or cloud provider)
- kubectl installed and configured
- Helm installed
- Docker installed
- Snyk account (free tier available at snyk.io)

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

Follow the instructions in each directory to set up the demo.