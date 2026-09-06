#!/bin/bash

set -e

mkdir -p /opt

curl -sfL https://get.k3s.io > /opt/k3s-install.sh

chmod +x /opt/k3s-install.sh

# Verify
ls -lh /opt/k3s-install.sh

echo "✅ K3s installer cached (will be executed by Ansible)"