#!/bin/bash

# Node configuration script
# This script configures node labels and taints

set -e

echo "🏷️  Configuring node labels and taints..."

# 配置 Control Plane 節點
echo "Configuring control plane: dynasafe-cluster-control-plane"
kubectl label nodes dynasafe-cluster-control-plane node-role=control-plane --overwrite

# 配置 Infra 節點
echo "Configuring infra node: dynasafe-cluster-worker"
kubectl label nodes dynasafe-cluster-worker node-role=infra --overwrite
kubectl taint nodes dynasafe-cluster-worker node-role=infra:NoSchedule --overwrite

# 配置 Application 節點
echo "Configuring application node: dynasafe-cluster-worker2"
kubectl label nodes dynasafe-cluster-worker2 node-role=application --overwrite
kubectl taint nodes dynasafe-cluster-worker2 node-role=application:NoSchedule --overwrite

echo "Configuring application node: dynasafe-cluster-worker3"
kubectl label nodes dynasafe-cluster-worker3 node-role=application --overwrite
kubectl taint nodes dynasafe-cluster-worker3 node-role=application:NoSchedule --overwrite

echo "✅ Node configuration completed!"

# 顯示節點狀態
echo "📊 Node status:"
kubectl get nodes -o wide

echo "🏷️  Node taints:"
kubectl describe nodes | grep -A 5 "Taints:"
