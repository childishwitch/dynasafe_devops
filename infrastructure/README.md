# 系統架構與部署指南

## 架構概述

本專案實現了一個完整的 Kubernetes 監控與 GitOps 部署平台，包含以下組件：

### 叢集架構
- **Control Plane**: 1個節點，負責叢集管理
- **Infra Node**: 1個節點，運行監控系統（Prometheus、kube-state-metrics）
- **Application Nodes**: 2個節點，運行應用程式和 ArgoCD

### 監控架構
- **Prometheus**: 部署在 infra node，收集監控數據
- **Node Exporter**: 部署在所有節點，收集節點指標
- **kube-state-metrics**: 部署在 infra node，收集 Kubernetes 狀態
- **Grafana**: 部署在叢集外（Docker），提供監控儀表板

### GitOps 架構
- **ArgoCD**: 部署在 application node，實現 GitOps 部署
- **Nginx**: 示範應用程式，通過 ArgoCD 管理

## 目錄結構

```
infrastructure/
├── README.md                    # 此說明文件
└── helm/                       # Helm Charts
    ├── monitoring/              # 監控系統 Helm Chart
    └── argocd/                 # ArgoCD Helm Chart
```

## 部署步驟

### 1. 環境準備

#### 安裝必要工具
```bash
# 安裝 kind 和 kubectl
brew install kind kubectl

# 安裝 Docker Desktop (從官網下載)
# https://www.docker.com/products/docker-desktop/
```

#### 驗證環境
```bash
# 檢查 Docker 是否運行
docker --version
docker info

# 檢查 kind 和 kubectl
kind --version
kubectl version --client
```

### 2. 創建 Kubernetes 叢集

#### 創建 kind 叢集
```bash
kind create cluster --config kind-config.yaml --name dynasafe-cluster
```

#### 等待叢集就緒
```bash
kubectl wait --for=condition=Ready nodes --all --timeout=300s
```

#### 配置節點污點

使用腳本配置節點標籤和污點：

```bash
# 執行節點配置腳本
chmod +x scripts/configure-nodes.sh
./scripts/configure-nodes.sh
```

**腳本功能：**
- 配置 Control Plane 節點標籤
- 配置 Infra 節點標籤和污點（NoSchedule）
- 配置 Application 節點標籤和污點（NoSchedule）
- 顯示節點狀態和污點配置

#### 驗證叢集狀態
```bash
# 查看節點狀態
kubectl get nodes -o wide

# 查看節點污點配置
kubectl describe nodes | grep -A 5 "Taints:"
```

### 3. 部署監控系統

#### 安裝 Helm
```bash
# 安裝 Helm
brew install helm

# 添加 Prometheus Helm 倉庫
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

#### 部署監控系統
```bash
# 創建監控命名空間
kubectl create namespace monitoring

# 部署監控系統 (Prometheus + kube-state-metrics + Node Exporter)
helm install monitoring ./helm/monitoring -n monitoring

# 檢查部署狀態
kubectl get pods -n monitoring
```

#### 部署 Grafana
```bash
# 在叢集外運行 Grafana
docker run -d --name grafana -p 3000:3000 grafana/grafana:latest

# 配置 Prometheus 作為數據源
# 訪問 http://localhost:3000 進行配置
```

### 4. 部署 ArgoCD

#### 安裝 ArgoCD
```bash
# 添加 ArgoCD Helm 倉庫
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 創建 ArgoCD 命名空間
kubectl create namespace argocd

# 部署 ArgoCD
helm install argocd ./infrastructure/helm/argocd -n argocd

# 等待 ArgoCD 就緒
kubectl wait --for=condition=Available deployment/argocd-server -n argocd --timeout=300s
```

#### 獲取 ArgoCD 管理員密碼
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 5. 部署示範應用程式

#### 創建 Nginx 應用程式
```bash
# 創建應用程式配置
# 詳細配置請參考 applications/nginx/ 目錄
```

#### 通過 ArgoCD 部署
```bash
# 在 ArgoCD UI 中創建應用程式
# 或使用 CLI 創建
argocd app create nginx-demo \
  --repo https://github.com/your-repo/dynasafe_devops \
  --path applications/nginx \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

## 部署策略

### 基礎設施管理
- **叢集管理**: 使用 kind 創建 Kubernetes 叢集
- **節點配置**: 使用腳本配置節點標籤和污點
- **監控系統**: 使用 Helm 部署（Prometheus、Grafana、Node Exporter）
- **原因**: 這些組件是 ArgoCD 運行的前提條件

### 應用程式管理
- **ArgoCD**: 管理所有業務應用程式
- **Nginx**: 作為示範應用程式，通過 ArgoCD 部署
- **其他應用**: 未來可通過 ArgoCD 統一管理

### 未來改進：Infrastructure as Code

#### 使用 CDK 管理基礎設施
- 使用 CDK8s 定義監控系統
- 自動化 Prometheus、Grafana 的部署
- 實現可重複的基礎設施管理

#### 使用 ArgoCD 管理應用程式
- 所有業務應用程式通過 ArgoCD 管理
- 實現真正的 GitOps 工作流程
- 統一的應用程式生命週期管理

## 監控儀表板

### 1. Cluster 效能監控儀表板
- 叢集整體資源使用情況
- 節點狀態和健康度
- Pod 分佈和狀態
- 命名空間資源使用

### 2. USE 角度監控儀表板
- **Utilization**: CPU、記憶體、網路、磁碟使用率
- **Saturation**: 佇列長度、等待時間、資源競爭
- **Errors**: 錯誤率、失敗次數、異常事件

## 故障排除

### 常見問題
1. **Docker 未運行**: 確保 Docker Desktop 已啟動
2. **kind 叢集創建失敗**: 檢查 Docker 狀態和磁碟空間
3. **節點污點配置錯誤**: 使用 `kubectl describe nodes` 檢查污點
4. **Prometheus 無法收集數據**: 檢查 Node Exporter 和 kube-state-metrics 狀態

### 清理環境
```bash
# 刪除 kind 叢集
kind delete cluster --name dynasafe-cluster

# 停止 Grafana 容器
docker stop grafana && docker rm grafana
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
