#!/bin/bash
# ArgoCD Setup Script for Ostad Capstone Project

set -e

NAMESPACE="argocd"
APP_NAME="ostad-capstone-production"

echo "Setting up ArgoCD for Production Deployment..."

# Step 1: Install ArgoCD (if not already installed)
echo "Step 1: Checking ArgoCD installation..."
if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
    echo "Installing ArgoCD..."
    kubectl create namespace ${NAMESPACE}
    kubectl apply -n ${NAMESPACE} -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    echo "Waiting for ArgoCD to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n ${NAMESPACE}
else
    echo "ArgoCD is already installed"
fi

# Step 2: Get ArgoCD admin password
echo "Step 2: Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n ${NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Admin Password: ${ARGOCD_PASSWORD}"

# Step 3: Port forward ArgoCD server (run in background)
echo "Step 3: Setting up port forwarding..."
kubectl port-forward svc/argocd-server -n ${NAMESPACE} 8080:443 &
PORT_FORWARD_PID=$!
echo "ArgoCD UI available at: https://localhost:8080"
echo "Username: admin"
echo "Password: ${ARGOCD_PASSWORD}"

# Step 4: Wait for port forward to be ready
sleep 5

# Step 5: Install ArgoCD CLI (if not already installed)
echo "Step 5: Installing ArgoCD CLI..."
if ! command -v argocd &> /dev/null; then
    echo "Installing ArgoCD CLI..."
    curl -sSL -o /tmp/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
    rm /tmp/argocd-linux-amd64
else
    echo "ArgoCD CLI is already installed"
fi

# Step 6: Login to ArgoCD
echo "Step 6: Logging into ArgoCD..."
argocd login localhost:8080 --username admin --password ${ARGOCD_PASSWORD} --insecure

# Step 7: Create the application
echo "Step 7: Creating ArgoCD application..."
kubectl apply -f argocd/application.yaml

echo "ArgoCD setup completed!"
echo ""
echo "Next steps:"
echo "1. Access ArgoCD UI at: https://localhost:8080"
echo "2. Login with username 'admin' and password: ${ARGOCD_PASSWORD}"
echo "3. Monitor the application deployment in the UI"
echo "4. The application will automatically sync when changes are pushed to the main branch"
echo ""
echo "To stop port forwarding, run: kill ${PORT_FORWARD_PID}"

