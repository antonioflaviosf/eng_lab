#!/bin/bash
set -euo pipefail


NODES=("vm-master" "vm-worker-1" "vm-worker-2")
IPS=("10.91.214.10" "10.91.214.11" "10.91.214.12")

PUBKEY=$(cat ~/.ssh/id_rsa.pub)
CPU="4"
MEMORY="4GiB"

echo "[INFO] Creating Incus VMs with static IPs..."

for i in "${!NODES[@]}"; do
  node="${NODES[$i]}"
  ip="${IPS[$i]}"

  if incus list | grep -q "$node"; then
    echo "[WARN] $node already exists, skipping"
  else

    incus launch images:ubuntu/22.04 "$node" --vm \
      --config limits.cpu="$CPU" \
      --config limits.memory="$MEMORY" \
      -c user.user-data="#cloud-config

package_update: true
package_upgrade: true

packages:
  - openssh-server
  - qemu-guest-agent

users:
  - default
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh-authorized-keys:
      - $PUBKEY

runcmd:
  - systemctl enable ssh
  - systemctl restart ssh
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
"

    echo "[OK] $node created"

    echo "[INFO] Waiting VM boot..."
    sleep 10

    # define IP fixo
    incus config device override "$node" eth0 ipv4.address="$ip"

    echo "[OK] $node IP set to $ip"

    incus restart "$node"
  fi
done

echo "[INFO] Install and configuring SSH and keys on all VMs..." 
for node in "${NODES[@]}"; do
  incus exec "$node" -- sudo apt-get update
  incus exec "$node" -- sudo apt-get install -y ssh
  incus exec "$node" -- sudo -u ubuntu -- ssh-keygen \
  -t ed25519 \
  -f /home/ubuntu/.ssh/id_ed25519 \
  -N ""
  incus exec "$node" -- sudo -u ubuntu -- bash -c '
mkdir -p /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
echo "'"$PUBKEY"'" >> /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys
'
  
done

echo "[INFO] All VMs created and configured"

echo '$(PUBKEY)'