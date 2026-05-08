# Architecture Overview

This project simulates a modern Platform Engineering environment using GitOps principles.

---

# Objectives

- Provision local and/or production environments
- Automate infrastructure configuration
- Deploy workloads declaratively
- Centralize cluster management using GitOps
- Keep the same operational model across environments

---

# Architecture Layers

## 1. Provisioning Layer

Responsible for infrastructure creation.

### Local Environment
- Incus virtual machines

### Production Environment
- OpenTofu
- Future targets:
  - Proxmox
  - VMware
  - Cloud providers

---

## 2. Configuration Layer

Responsible for operating system configuration and cluster bootstrap.

### Tooling
- Ansible

### Responsibilities
- SSH access
- Base packages
- Kubernetes installation
- Node preparation

---

## 3. Kubernetes Layer

Responsible for workload orchestration.

### Distribution
- k3s

### Node Roles
- Control Plane
- Workers

---

## 4. GitOps Layer

Responsible for continuous reconciliation between Git and Kubernetes.

### Tooling
- ArgoCD

### Responsibilities
- Monitor Git repositories
- Apply manifests automatically
- Self-healing
- Drift correction

---

# Repository Structure

## config/

Contains automation and configuration assets.

### Examples
- Ansible inventories
- Playbooks
- Roles
- Future configuration assets

---

## environments/

Contains infrastructure provisioning logic separated by environment.

### local/
Incus-based local lab environment.

### prod/
Future Infrastructure as Code environments using OpenTofu.

---

## platform/kubernetes/apps/

Contains business workloads and applications deployed into Kubernetes.

### Examples
- nginx
- zabbix
- glpi

---

## platform/kubernetes/infra/

Contains cluster infrastructure components.

### Future examples
- ingress controllers
- monitoring stack
- cert-manager
- logging stack

---

## platform/kubernetes/argocd/

Contains ArgoCD resources responsible for GitOps orchestration.

### Examples
- root applications
- child applications
- future appsets/projects

---

# GitOps Workflow
```markdown
Git Repository
    ↓
ArgoCD monitors repository
    ↓
Applications are reconciled
    ↓
Kubernetes cluster state is updated
```
---

# Operational Flow

```
Provision
    ↓
Configure
    ↓
Bootstrap Kubernetes
    ↓
Deploy GitOps
    ↓
Deploy Applications
``