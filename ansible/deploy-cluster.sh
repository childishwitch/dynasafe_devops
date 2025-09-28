#!/bin/bash

# Kubernetes Cluster Deployment Script using Ansible
# This script deploys a complete Kubernetes cluster with monitoring and GitOps

set -e

echo "🚀 Starting Kubernetes cluster deployment with Ansible..."

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible is not installed. Please install Ansible first."
    echo "   Ubuntu/Debian: sudo apt install ansible"
    echo "   macOS: brew install ansible"
    exit 1
fi

# Check if inventory file exists
if [ ! -f "inventory/hosts.yml" ]; then
    echo "❌ Inventory file not found. Please create inventory/hosts.yml"
    exit 1
fi

echo "📋 Running Ansible playbooks..."

# Step 1: Prepare nodes
echo "🔧 Step 1: Preparing nodes..."
ansible-playbook playbooks/01-prepare-nodes.yml

# Step 2: Initialize cluster
echo "🏗️  Step 2: Initializing Kubernetes cluster..."
ansible-playbook playbooks/02-init-cluster.yml

# Step 3: Join worker nodes
echo "🔗 Step 3: Joining worker nodes..."
ansible-playbook playbooks/03-join-workers.yml

# Step 4: Configure nodes
echo "🏷️  Step 4: Configuring node labels and taints..."
ansible-playbook playbooks/04-configure-nodes.yml

# Step 5: Deploy monitoring
echo "📊 Step 5: Deploying monitoring stack..."
ansible-playbook playbooks/05-deploy-monitoring.yml

# Step 6: Deploy ArgoCD
echo "🔄 Step 6: Deploying ArgoCD..."
ansible-playbook playbooks/06-deploy-argocd.yml

echo "✅ Kubernetes cluster deployment completed!"
echo ""
echo "🌐 Access Information:"
echo "   - Kubernetes Dashboard: kubectl proxy"
echo "   - Prometheus: kubectl port-forward -n monitoring svc/monitoring-prometheus-server 9090:80"
echo "   - Grafana: kubectl port-forward -n monitoring svc/grafana-external 3000:3000"
echo "   - ArgoCD: kubectl port-forward -n argocd svc/argocd-server 8080:80"
echo ""
echo "🔑 ArgoCD Credentials:"
echo "   - Username: admin"
echo "   - Password: Check the playbook output above"
echo ""
echo "📚 Next Steps:"
echo "   1. Configure kubectl context"
echo "   2. Access monitoring dashboards"
echo "   3. Deploy applications via ArgoCD"
