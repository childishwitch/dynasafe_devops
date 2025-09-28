# 基礎設施配置

此目錄包含 Kubernetes 叢集的基礎設施配置檔案。

## 目錄結構

```
infrastructure/
├── README.md                    # 此說明文件
├── node-config.yaml            # 節點配置 YAML
└── helm/                       # Helm Chart
    └── node-config/
        ├── Chart.yaml          # Helm Chart 定義
        ├── values.yaml         # 配置值
        └── templates/
            └── node-config.yaml # 節點配置模板
```

## 使用方法

### 方法 1: 直接使用 kubectl

```bash
# 使用腳本配置節點
chmod +x ../../scripts/configure-nodes.sh
./configure-nodes.sh
```

### 方法 2: 使用 Helm

```bash
# 安裝 Helm Chart
helm install node-config ./helm/node-config

# 檢查 Job 狀態
kubectl get jobs -n kube-system

# 查看 Job 日誌
kubectl logs -n kube-system job/node-config-job
```

### 方法 3: 手動配置

```bash
# 配置 infra 節點
kubectl label nodes dynasafe-cluster-worker node-role=infra --overwrite
kubectl taint nodes dynasafe-cluster-worker node-role=infra:NoSchedule --overwrite

# 配置 application 節點
kubectl label nodes dynasafe-cluster-worker2 node-role=application --overwrite
kubectl taint nodes dynasafe-cluster-worker2 node-role=application:NoSchedule --overwrite

kubectl label nodes dynasafe-cluster-worker3 node-role=application --overwrite
kubectl taint nodes dynasafe-cluster-worker3 node-role=application:NoSchedule --overwrite
```

## 驗證配置

```bash
# 查看節點狀態
kubectl get nodes -o wide

# 查看節點標籤
kubectl get nodes --show-labels

# 查看節點污點
kubectl describe nodes | grep -A 5 "Taints:"
```

## 節點角色說明

- **control-plane**: 控制平面節點，運行 Kubernetes API Server
- **infra**: 基礎設施節點，運行監控系統（Prometheus、Grafana）
- **application**: 應用程式節點，運行業務應用程式和 ArgoCD
