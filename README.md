```bash
eng-lab/
├── config
│   └── ansible
│       ├── ansible.cfg
│       ├── inventories
│       │   ├── local
│       │   │   └── hosts.yml
│       │   └── prod
│       ├── playbooks
│       │   ├── bootstrap.yml
│       │   └── k3s.yml
│       └── roles
│           └── k3s
│               └── tasks
│                   ├── main.yml
│                   ├── master.yml
│                   └── worker.yml
├── docs
│   ├── architecture.md
│   └── environments.md
├── environments
│   ├── local
│   │   └── incus
│   │       ├── config.yaml
│   │       ├── create.sh
│   │       └── destroy.sh
│   └── prod
│       └── opentofu
│           ├── environments
│           └── modules
├── Makefile
├── platform
│   └── kubernetes
└── README.md

```

---
## ARGOCD 


### Install and setting up the argocd 
```bash
kubectl create ns argocd 
kubectl apply --server-side -k "https://github.com/argoproj/argo-cd/manifests/cluster-install?ref=stable" -n argocd
```

Get Pass
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```