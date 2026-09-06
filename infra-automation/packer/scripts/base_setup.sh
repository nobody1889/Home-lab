#!/bin/bash
set -e

apt-get update
apt-get upgrade -y

apt-get -y install \
  curl wget gnupg2 ca-certificates \
  apt-transport-https \
  qemu-guest-agent cloud-init cloud-guest-utils \
  sudo openssh-server unattended-upgrades

systemctl enable qemu-guest-agent
systemctl enable ssh

echo "✅ base setup complete"