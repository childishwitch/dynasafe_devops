#!/bin/bash

# Configure Kind cluster nodes with labels and taints
# This script is called by Ansible playbook

echo "🔧 Configuring Kind cluster nodes..."

# Control plane node
echo "  - Configuring control plane node..."
kubectl label nodes dynasafe-cluster-control-plane node-role.kubernetes.io/control-plane=true --overwrite
kubectl taint nodes dynasafe-cluster-control-plane node-role.kubernetes.io/control-plane:NoSchedule --overwrite

# Infra node
echo "  - Configuring infra node..."
kubectl label nodes dynasafe-cluster-worker node-role=infra --overwrite
kubectl taint nodes dynasafe-cluster-worker node-role=infra:NoSchedule --overwrite

# Application nodes
echo "  - Configuring application nodes..."
kubectl label nodes dynasafe-cluster-worker2 node-role=application --overwrite
kubectl taint nodes dynasafe-cluster-worker2 node-role=application:NoSchedule --overwrite

kubectl label nodes dynasafe-cluster-worker3 node-role=application --overwrite
kubectl taint nodes dynasafe-cluster-worker3 node-role=application:NoSchedule --overwrite

echo "✅ Node configuration completed!"
echo ""
echo "📋 Node status:"
kubectl get nodes --show-labels
