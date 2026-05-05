#!/bin/bash
set -e

NODES=("vm-master" "vm-worker-1" "vm-worker-2")
IPS=("10.91.214.10" "10.91.214.11" "10.91.214.12")

PUBKEY=$(cat ~/.ssh/id_rsa.pub)

echo "[INFO] Creating Incus VMs with static IPs..."

for i in "${!NODES[@]}"; do
  node="${NODES[$i]}"
  ip="${IPS[$i]}"

  if incus list | grep -q "$node"; then
    echo "[WARN] $node already exists, skipping"
  else
    incus launch images:ubuntu/22.04 "$node" --vm \
      -c user.user-data="#cloud-config
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
    ssh-authorized-keys:
      - $PUBKEY
package_update: true
packages:
  - qemu-guest-agent"

    echo "[OK] $node created"

    # aguarda VM inicializar
    sleep 5

    # define IP fixo
    incus config device override "$node" eth0 ipv4.address="$ip"
    echo "[OK] $node IP set to $ip"

    incus restart "$node"
  fi
done

echo "[INFO] Instances created"