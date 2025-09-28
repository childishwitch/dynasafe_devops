# Nginx 示範應用程式

這是用於 ArgoCD GitOps 部署的 Nginx 示範應用程式。

## 檔案說明

- `deployment.yaml` - Nginx Deployment 配置
- `service.yaml` - Nginx Service 配置 (NodePort 30080)
- `configmap.yaml` - 自定義首頁內容
- `argocd-application.yaml` - ArgoCD Application 配置

## 部署方式

### 手動部署
```bash
kubectl apply -f applications/nginx/
```

### ArgoCD 部署
1. 將此目錄推送到 Git Repository
2. 在 ArgoCD 中創建 Application
3. 手動同步部署

## 訪問方式

部署完成後，可通過以下方式訪問：
- **NodePort**: http://localhost:30080
- **Port Forward**: `kubectl port-forward svc/nginx-demo-service 8080:80`

## 配置說明

- **節點選擇**: 部署到 application node
- **資源限制**: CPU 100m, Memory 128Mi
- **健康檢查**: 包含 liveness 和 readiness probe
- **自定義首頁**: 展示 DynaSafe DevOps Demo 資訊
