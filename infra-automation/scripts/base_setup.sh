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
    bash-completion \
    build-essential
