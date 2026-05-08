# Environments

This project uses different environments to simulate a real Platform Engineering workflow.

---

# Local Environment

## Purpose

Used for:
- Development
- Testing
- Kubernetes lab
- GitOps validation
- Infrastructure experiments

---

## Provisioning

Provider:
- Incus

Scripts:
- `environments/local/incus/create.sh`
- `environments/local/incus/destroy.sh`

---

## Cluster

Kubernetes distribution:
- k3s

Topology:
- 1 master node
- 2 worker nodes

---

## Networking

| Node | IP |
|---|---|
| vm-master | 10.10.10.101 |
| vm-worker-1 | 10.10.10.102 |
| vm-worker-2 | 10.10.10.103 |

---

## Automation Stack

| Component | Purpose |
|---|---|
| Ansible | VM configuration |
| k3s | Kubernetes cluster |
| ArgoCD | GitOps |
| GitHub | Source of truth |

---

## GitOps Structure

Applications:
- `platform/kubernetes/apps`

ArgoCD Applications:
- `platform/kubernetes/argocd`

Infrastructure components:
- `platform/kubernetes/infra`

---

# Production Environment

## Purpose

Production-ready infrastructure environment.

---

## Provisioning

Provider:
- OpenTofu

Possible targets:
- Proxmox
- VMware
- Cloud providers

---

## Goals

- Infrastructure as Code
- Reproducible environments
- GitOps-driven operations
- Environment standardization

---

# Long-Term Goals

- Multi-environment GitOps
- Observability stack
- CI/CD pipelines
- Kubernetes platform standardization
- Infrastructure automation