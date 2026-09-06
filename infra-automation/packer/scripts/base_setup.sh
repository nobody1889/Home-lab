#!/bin/bash
set -e

apt-get update
apt-get upgrade -y

apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    jq \
    ca-certificates \
    apt-transport-https software-properties-common \
    qemu-guest-agent cloud-init cloud-guest-utils \
    sudo openssh-server unattended-upgrades

systemctl enable qemu-guest-agent
systemctl enable ssh
systemctl enable cloud-init