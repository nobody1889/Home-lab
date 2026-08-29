#!/bin/bash
set -e

apt update
apt upgrade -y

apt install -y git curl wget tar btop htop vim jq ca-certification 
