#!/bin/bash

set -e

# download the main script to handle all download for us as get_docker.sh

curl -fsSL https://get.docker.com -o get_docker.sh

sh get_docker.sh

# Enable Docker to start on boot
systemctl enable docker

# Start Docker 
systemctl start docker

# Verify
docker --version

echo "✅ Docker installed successfully"
