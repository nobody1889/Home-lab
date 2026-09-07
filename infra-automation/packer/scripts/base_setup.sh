#!/bin/bash
set -e

apt-get update
apt-get upgrade -y

apt-get -y install \
  curl wget gnupg2 ca-certificates \
  apt-transport-https \
  qemu-guest-agent cloud-init cloud-guest-utils \
  sudo openssh-server unattended-upgrades \
  incus-agent

# Enable and start the agents
systemctl enable --now qemu-guest-agent
systemctl enable --now incus-agent || systemctl enable --now lxd-agent || true
systemctl enable --now ssh

systemctl daemon-reload

echo "✅ base setup complete"