# 系統架構圖

## 整體架構

```mermaid
graph TB
    subgraph "Host Machine"
        subgraph "Docker"
            Grafana[Grafana<br/>Port: 3000]
        end
        
        subgraph "Kind Cluster"
            subgraph "Control Plane"
                CP[Control Plane Node<br/>dynasafe-cluster-control-plane]
            end
            
            subgraph "Infra Node"
                IN[Infra Node<br/>dynasafe-cluster-worker]
                Prometheus[Prometheus<br/>Port: 30090]
                KSM[kube-state-metrics]
            end
            
            subgraph "Application Nodes"
                AN1[Application Node 1<br/>dynasafe-cluster-worker2]
                AN2[Application Node 2<br/>dynasafe-cluster-worker3]
                
                subgraph "ArgoCD Components"
                    AC[ArgoCD Controller]
                    AS[ArgoCD Server]
                    AR[ArgoCD Repo Server]
                end
                
                subgraph "Nginx Demo App"
                    Nginx1[Nginx Pod 1]
                    Nginx2[Nginx Pod 2]
                    NginxSvc[Nginx Service<br/>NodePort: 30080]
                end
            end
            
            subgraph "All Nodes"
                NE[Node Exporter<br/>DaemonSet]
            end
        end
    end
    
    subgraph "External"
        GitHub[GitHub Repository<br/>childishwitch/dynasafe_devops]
    end
    
    %% Connections
    Grafana --> Prometheus
    Prometheus --> KSM
    Prometheus --> NE
    NE --> IN
    NE --> AN1
    NE --> AN2
    
    ArgoCD --> GitHub
    ArgoCD --> Nginx1
    ArgoCD --> Nginx2
    
    NginxSvc --> Nginx1
    NginxSvc --> Nginx2
    
    %% Styling
    classDef controlPlane fill:#e1f5fe
    classDef infraNode fill:#f3e5f5
    classDef appNode fill:#e8f5e8
    classDef external fill:#fff3e0
    classDef monitoring fill:#ffebee
    
    class CP controlPlane
    class IN,Prometheus,KSM infraNode
    class AN1,AN2,AC,AS,AR,Nginx1,Nginx2,NginxSvc appNode
    class GitHub external
    class Grafana monitoring
```

## 監控架構

```mermaid
graph LR
    subgraph "Data Collection"
        NE[Node Exporter<br/>All Nodes]
        KSM[kube-state-metrics<br/>Infra Node]
    end
    
    subgraph "Data Storage"
        Prometheus[Prometheus<br/>Infra Node]
    end
    
    subgraph "Visualization"
        Grafana[Grafana<br/>Docker Host]
    end
    
    subgraph "Dashboards"
        CD[Cluster Performance<br/>Dashboard]
        UD[USE Metrics<br/>Dashboard]
    end
    
    NE --> Prometheus
    KSM --> Prometheus
    Prometheus --> Grafana
    Grafana --> CD
    Grafana --> UD
```

## GitOps 架構

```mermaid
graph LR
    subgraph "Developer"
        Dev[Developer]
    end
    
    subgraph "Git Repository"
        GitHub[GitHub<br/>childishwitch/dynasafe_devops]
    end
    
    subgraph "Kubernetes Cluster"
        ArgoCD[ArgoCD<br/>Application Node]
        K8s[Kubernetes<br/>Resources]
    end
    
    subgraph "Applications"
        Nginx[Nginx Demo App]
    end
    
    Dev --> GitHub
    GitHub --> ArgoCD
    ArgoCD --> K8s
    K8s --> Nginx
    
    %% Manual Sync
    ArgoCD -.->|Manual Sync| K8s
```

## 節點配置

```mermaid
graph TB
    subgraph "Kind Cluster - 4 Nodes"
        subgraph "Control Plane"
            CP[Control Plane Node<br/>Labels: node-role=control-plane<br/>Taints: node-role.kubernetes.io/control-plane:NoSchedule]
        end
        
        subgraph "Infra Node"
            IN[Infra Node<br/>Labels: node-role=infra<br/>Taints: node-role=infra:NoSchedule<br/>Components: Prometheus, kube-state-metrics]
        end
        
        subgraph "Application Node 1"
            AN1[Application Node 1<br/>Labels: node-role=application<br/>Taints: node-role=application:NoSchedule<br/>Components: ArgoCD Controller, Nginx Pods]
        end
        
        subgraph "Application Node 2"
            AN2[Application Node 2<br/>Labels: node-role=application<br/>Taints: node-role=application:NoSchedule<br/>Components: ArgoCD Server, Nginx Pods]
        end
    end
    
    subgraph "All Nodes"
        NE[Node Exporter<br/>DaemonSet on all nodes]
    end
    
    NE --> CP
    NE --> IN
    NE --> AN1
    NE --> AN2
```

## 配置檔案清單

### Kubernetes 配置檔
- `kind-config.yaml` - Kind 叢集配置
- `scripts/configure-nodes.sh` - 節點標籤和污點配置腳本

### Helm Charts
- `infrastructure/helm/monitoring/` - 監控系統 Helm Chart
  - `Chart.yaml` - Chart 定義
  - `values.yaml` - 監控系統配置值
- `infrastructure/helm/argocd/` - ArgoCD Helm Chart
  - `Chart.yaml` - Chart 定義
  - `values.yaml` - ArgoCD 配置值

### 應用程式配置
- `applications/nginx/deployment.yaml` - Nginx Deployment
- `applications/nginx/service.yaml` - Nginx Service
- `applications/nginx/configmap.yaml` - Nginx 配置
- `applications/nginx/argocd-application.yaml` - ArgoCD Application

### 監控配置
- `docker-compose.yml` - Grafana Docker 配置
- `grafana/provisioning/` - Grafana 自動配置
  - `datasources/prometheus.yml` - Prometheus 數據源
  - `dashboards/` - 監控儀表板配置

## 監控儀表板截圖

### Grafana 儀表板
- `docs/screenshots/grafana_dashboards_cluster.png` - Cluster 效能監控
- `docs/screenshots/grafana_dashboards_use.png` - USE 角度監控

### 系統截圖
- `docs/screenshots/argocd.png` - ArgoCD 管理介面
- `docs/screenshots/nginx.png` - Nginx 示範應用程式
