# Platform Engineering Lab

This project simulates a modern Platform Engineering environment using GitOps principles.

The objective is to build a reusable and declarative platform capable of provisioning infrastructure, configuring systems, deploying workloads and managing applications through GitOps workflows.

---

# Objectives

- Provision local and production environments
- Automate infrastructure configuration
- Deploy Kubernetes workloads declaratively
- Manage applications using GitOps
- Keep the same operational model across environments

---

# Architecture Workflow

```text
Provision → Configure → Orchestrate → GitOps
```

```text
Incus/OpenTofu
        ↓
Ansible
        ↓
Kubernetes (k3s)
        ↓
ArgoCD
```

---

# Repository Structure

```bash
eng-lab/
├── config/
├── docs/
├── environments/
├── platform/
├── Makefile
└── README.md
```

---

# Directory Overview

## config/

Contains configuration management resources.

### Current usage
- Ansible inventories
- Playbooks
- Roles
- Ansible configuration

### Future usage
- Network configuration
- Automation scripts
- Shared configuration files

---

## docs/

Project documentation.

Contains:
- architecture documentation
- environment documentation
- networking references
- operational notes

---

## environments/

Infrastructure provisioning layer.

### local/
Uses Incus virtual machines for local labs and testing.

### prod/
Reserved for OpenTofu-based production provisioning.

---

## platform/

Contains platform resources and Kubernetes manifests.

### kubernetes/apps/
Application manifests:
- Deployments
- Services
- Ingresses
- Namespaces

### kubernetes/argocd/
GitOps management manifests:
- ArgoCD Applications
- App of Apps structure

### kubernetes/infra/
Reserved for shared cluster infrastructure:
- ingress controllers
- cert-manager
- monitoring stack
- logging stack

---

# Local Environment

## Provision local VMs

```bash
make local-up
```

This command:
- creates Incus VMs
- configures networking
- configures cloud-init
- injects SSH keys

---

# Destroy environment

```bash
make local-down
```

---

# Ansible

## Bootstrap nodes

```bash
ansible-playbook -i config/ansible/inventories/local/hosts.yml \
config/ansible/playbooks/bootstrap.yml
```

---

## Install k3s cluster

```bash
ansible-playbook -i config/ansible/inventories/local/hosts.yml \
config/ansible/playbooks/k3s.yml
```

---

# Kubernetes

Validate cluster:

```bash
kubectl get nodes
```

---

# ArgoCD

## Install ArgoCD

```bash
kubectl create namespace argocd

kubectl apply --server-side -k \
"https://github.com/argoproj/argo-cd/manifests/cluster-install?ref=stable" \
-n argocd
```

---

## Get admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d; echo
```

---

## Temporary local access

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access:
```text
https://localhost:8080
```

---

# GitOps Structure

```text
ArgoCD
   ↓
Applications
   ↓
Kubernetes manifests
```

Example:

```text
root-app
   ↓
nginx-app
   ↓
apps/nginx/
```

---

# Current Features

- Incus-based local lab
- Ansible automation
- k3s cluster deployment
- ArgoCD GitOps
- App of Apps structure
- Declarative Kubernetes applications

---

# Future Improvements

- OpenTofu provisioning
- Multi-environment overlays
- Helm support
- Monitoring stack
- Logging stack
- CI/CD pipelines
- Secret management
- Observability
- Platform APIs

---

# Status

🚧 Project under active development.