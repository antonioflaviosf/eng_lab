.PHONY: help local-up local-down local-bootstrap local-k8s

help:
	@echo "Available commands:"
	@echo ""
	@echo "  make local-up          - Create local environment"
	@echo "  make local-down        - Destroy local environment"
	@echo "  make local-bootstrap   - Bootstrap servers with Ansible"
	@echo "  make local-k8s         - Install Kubernetes cluster"
	@echo ""

local-up:
	@echo "[INFO] Starting local environment..."
	bash environments/local/incus/create.sh

local-down:
	@echo "[INFO] Destroying environment..."
	bash environments/local/incus/destroy.sh

local-bootstrap:
	ansible-playbook -i config/ansible/inventories/local/hosts.yml \
	config/ansible/playbooks/bootstrap.yml

local-k8s:
	@echo "[INFO] Starting local Kubernetes cluster..."
	ansible-playbook -i config/ansible/inventories/local/hosts.yml \
	config/ansible/playbooks/k3s.yml