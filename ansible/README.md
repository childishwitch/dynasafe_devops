# Kubernetes Cluster Automation with Ansible

This Ansible project automates the complete deployment of a Kubernetes cluster with monitoring and GitOps capabilities.

## 🏗️ Architecture

The Ansible playbooks deploy:
- **Kubernetes Cluster** (1 control-plane + 3 worker nodes)
- **Node Configuration** (labels and taints)
- **Monitoring Stack** (Prometheus + Grafana)
- **GitOps Platform** (ArgoCD)

## 📋 Prerequisites

### System Requirements
- Ubuntu 20.04+ or similar Linux distribution
- At least 4GB RAM per node
- Docker installed
- Ansible 2.9+ installed

### Install Ansible
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# macOS
brew install ansible

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
│   ├── 01-prepare-nodes.yml      # Node preparation
│   ├── 02-init-cluster.yml       # Cluster initialization
│   ├── 03-join-workers.yml       # Worker node joining
│   ├── 04-configure-nodes.yml    # Node configuration
│   ├── 05-deploy-monitoring.yml  # Monitoring deployment
│   └── 06-deploy-argocd.yml      # ArgoCD deployment
├── inventory/
│   └── hosts.yml                 # Host inventory
├── group_vars/
│   └── all.yml                   # Global variables
├── ansible.cfg                   # Ansible configuration
├── deploy-cluster.sh             # Main deployment script
└── README.md                     # This file
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
