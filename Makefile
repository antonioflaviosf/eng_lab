local-up:
	@echo "[INFO] Starting local environment..."
	bash environments/local/incus/create.sh

local-down:
	@echo "[INFO] Destroying environment..."
	bash environments/local/incus/destroy.sh

ansible:
	ansible-playbook config/ansible/playbooks/bootstrap.yml