
```bash
markdownplatform-engineering-lab/
├── README.md
├── docs/
│   ├── architecture.md
│   └── environments.md
│
├── environments/
│   ├── local/
│   │   └── incus/
│   │       ├── create.sh
│   │       ├── destroy.sh
│   │       └── config.yaml
│   │
│   └── prod/
│       └── opentofu/
│           ├── modules/
│           └── environments/
│
├── config/
│   └── ansible/
│       ├── inventories/
│       │   ├── local/
│       │   └── prod/
│       ├── roles/
│       └── playbooks/
│
├── platform/
│   └── kubernetes/
│
└── Makefile
```
