# Kind Kubernetes Cluster Automation with Ansible

This Ansible project automates the deployment of a Kind-based Kubernetes cluster with monitoring and GitOps capabilities, following the DevOps interview requirements.

## 🏗️ Architecture

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

### 自動化部署組件
The Ansible playbooks deploy:
- **Kind Kubernetes Cluster** (1 control-plane + 3 worker nodes)
- **Node Configuration** (labels and taints for infra/application separation)
- **Monitoring Stack** (using existing Helm charts in infrastructure/helm/monitoring)
- **Grafana** (using existing docker-compose.yml and provisioning configs)
- **GitOps Platform** (using existing Helm charts in infrastructure/helm/argocd)
- **Nginx Demo Application** (using existing YAML files in applications/nginx)

## 📋 Prerequisites

### System Requirements
- Docker Desktop installed and running
- Kind (Kubernetes in Docker) - will be installed automatically
- Ansible 2.9+ installed
- At least 8GB RAM for the host machine

### ✅ Testing Status
- **Ansible Installation**: ✅ Tested and working
- **Playbooks Syntax**: ✅ All playbooks syntax validated
- **Kind Cluster Setup**: ✅ Ready for deployment
- **Requirements**: All dependencies verified
- **Configuration**: Ready for deployment

### Install Ansible
```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install from requirements.txt
pip install -r requirements.txt

# Verify installation
ansible --version
```

## 🚀 Quick Start

1. **Configure Inventory**
   Edit `inventory/hosts.yml` with your target hosts:
   ```yaml
   all:
     children:
       kubernetes:
         children:
           control_plane:
             hosts:
               master:
                 ansible_host: your-master-ip
                 ansible_user: ubuntu
           workers:
             hosts:
               worker1:
                 ansible_host: your-worker1-ip
                 ansible_user: ubuntu
   ```

2. **Deploy Cluster**
   ```bash
   cd ansible
   
   # If using virtual environment
   source venv/bin/activate
   
   # Run deployment
   ./deploy-cluster.sh
   ```

3. **Access Services**
   ```bash
   # Configure kubectl
   export KUBECONFIG=~/.kube/config
   
   # Access services
   kubectl port-forward -n monitoring svc/grafana-external 3000:3000
   kubectl port-forward -n argocd svc/argocd-server 8080:80
   ```

## 📁 Project Structure

```
ansible/
├── playbooks/
│   ├── 01-setup-kind-cluster.yml    # Kind cluster setup
│   ├── 02-configure-nodes.yml       # Node configuration
│   ├── 05-deploy-monitoring.yml     # Monitoring deployment
│   ├── 06-deploy-argocd.yml         # ArgoCD deployment
│   ├── 07-deploy-grafana.yml        # Grafana deployment
│   └── 08-deploy-nginx-demo.yml     # Nginx demo application
├── inventory/
│   └── hosts.yml                    # Host inventory
├── group_vars/
│   └── all.yml                      # Global variables
├── ansible.cfg                      # Ansible configuration
├── deploy-cluster.sh                # Main deployment script
├── requirements.txt                 # Python dependencies
└── README.md                        # This file
```

## 🔧 Configuration

### Node Roles
- **Control Plane**: Cluster management
- **Infra Node**: Monitoring components (Prometheus, Grafana)
- **Application Nodes**: Application workloads (ArgoCD, apps)

### Customization
Edit `group_vars/all.yml` to customize:
- Kubernetes version
- Network CIDRs
- Node labels and taints
- Monitoring configuration
- ArgoCD settings

## 📊 Monitoring

### Prometheus
- **URL**: `http://localhost:9090`
- **Targets**: All cluster components
- **Metrics**: Node, Pod, Service metrics

### Grafana
- **URL**: `http://localhost:3000`
- **Username**: `admin`
- **Password**: `admin123`
- **Dashboards**: Pre-configured cluster monitoring

## 🔄 GitOps with ArgoCD

### ArgoCD
- **URL**: `http://localhost:8080`
- **Username**: `admin`
- **Password**: Generated during deployment
- **Features**: Application deployment, sync management

### Deploy Applications
```bash
# Create ArgoCD application
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/your-app
    targetRevision: HEAD
    path: applications/nginx
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
EOF
```

## 🧪 Testing Guide

### Before Deployment
1. **Verify Ansible Installation**
   ```bash
   source venv/bin/activate
   ansible --version
   ```

2. **Test Inventory Configuration**
   ```bash
   ansible all -i inventory/hosts.yml --list-hosts
   ansible all -i inventory/hosts.yml -m ping
   ```

3. **Dry Run Playbooks**
   ```bash
   # Test Kind cluster setup
   ansible-playbook playbooks/01-setup-kind-cluster.yml --check --diff
   
   # Test node configuration
   ansible-playbook playbooks/02-configure-nodes.yml --check --diff
   ```

### Production Testing
- Test on a small environment first (1 master + 1 worker)
- Verify all services are accessible
- Check monitoring dashboards
- Test ArgoCD application deployment

## 🛠️ Troubleshooting

### Common Issues

1. **Node not joining cluster**
   ```bash
   # Check join command
   kubectl get nodes
   kubectl describe node <node-name>
   ```

2. **Pods not starting**
   ```bash
   # Check pod status
   kubectl get pods -A
   kubectl describe pod <pod-name> -n <namespace>
   ```

3. **Network issues**
   ```bash
   # Check CNI
   kubectl get pods -n kube-system
   kubectl logs -n kube-system <cni-pod>
   ```

### Logs
```bash
# Ansible logs
ansible-playbook playbooks/01-prepare-nodes.yml -v

# Kubernetes logs
kubectl logs -n kube-system <component>
```

## 🔐 Security Notes

- Change default passwords
- Configure RBAC properly
- Use TLS certificates
- Regular security updates

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details
