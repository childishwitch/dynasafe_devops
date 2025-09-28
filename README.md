# DevOps 面試作業 - Kubernetes 監控與部署平台

## 作業概述

本專案使用 kind 架設 Kubernetes 叢集，並整合 Prometheus、Grafana 監控系統以及 ArgoCD 進行 GitOps 部署。

## 架構設計

### 叢集配置
- **Control Plane**: 1個節點
- **Worker Nodes**: 3個節點
  - **Infra Node**: 1個節點（運行 Prometheus、kube-state-metrics）
  - **Application Nodes**: 2個節點（運行 ArgoCD、應用程式）

### 監控架構
- **Prometheus**: 部署在 infra node，收集所有節點的監控數據
- **Node Exporter**: 部署在所有節點
- **kube-state-metrics**: 部署在 infra node
- **Grafana**: 部署在叢集外（Docker），連接 Prometheus 作為數據源

### GitOps 架構
- **ArgoCD**: 部署在 application node
- **Nginx**: 作為示範應用程式，通過 ArgoCD 進行部署

## 專案結構

```
dynasafe_devops/
├── README.md                 # 專案說明文件
├── kind-config.yaml          # kind 叢集配置
├── monitoring/               # 監控系統配置
│   ├── prometheus/           # Prometheus 配置
│   ├── grafana/              # Grafana 配置
│   └── node-exporter/        # Node Exporter 配置
├── argocd/                   # ArgoCD 配置
├── applications/             # 應用程式配置
│   └── nginx/                # Nginx 示範應用
└── docs/                     # 文檔和截圖
    ├── architecture.md       # 架構說明
    └── screenshots/          # 螢幕截圖
```

## 環境需求

### 軟體版本
- **Docker Desktop**: 4.47.0+ (用於運行 kind 和 Grafana)
- **kind**: v0.30.0+ (Kubernetes 叢集管理)
- **kubectl**: v1.34.1+ (Kubernetes 命令行工具)
- **Kubernetes**: v1.30+ (透過 kind 部署)
- **Prometheus**: v2.50+ (監控數據收集)
- **Grafana**: v11.0+ (監控儀表板)
- **ArgoCD**: v2.10+ (GitOps 部署)

### 快速開始

1. **安裝必要工具**
   ```bash
   brew install kind kubectl
   # 並安裝 Docker Desktop
   ```

2. **部署系統**
   ```bash
   # 詳細步驟請參考 docs/architecture.md
   kind create cluster --config kind-config.yaml --name dynasafe-cluster
   ```

3. **訪問服務**
   - Grafana: http://localhost:3000
   - ArgoCD: 通過 kubectl port-forward 訪問

## 監控儀表板

### 1. Cluster 效能監控儀表板
- 叢集整體資源使用情況
- 節點狀態和健康度
- Pod 分佈和狀態

### 2. USE 角度監控儀表板
- **Utilization**: CPU、記憶體、網路、磁碟使用率
- **Saturation**: 佇列長度、等待時間
- **Errors**: 錯誤率、失敗次數

## 文檔

- [架構圖](docs/architecture.md) - 系統架構說明
- [監控儀表板截圖](docs/screenshots/) - 監控介面截圖

## 授權

MIT License
