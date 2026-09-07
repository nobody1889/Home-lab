#!/bin/bash
set -e

#cd "$(dirname "${BASH_SOURCE[0]}")/.."

IMAGE_NAME="${IMAGE_NAME:-debian-k3s-golden}"
DEBIAN_CODENAME="${DEBIAN_CODENAME:-trixie}"
DISK="output-${IMAGE_NAME}/${IMAGE_NAME}"

echo '=== Creating metadata ==='
mkdir -p /tmp/incus-image

cat > /tmp/incus-image/metadata.yaml <<EOF
architecture: x86_64
creation_date: $(date +%s)
properties:
  description: "Debian golden image with k3s (disabled)"
  os: Debian
  release: ${DEBIAN_CODENAME}
  variant: cloud
  serial: $(date +%Y%m%d_%H%M)
EOF

tar -C /tmp/incus-image -zcf /tmp/incus-image/metadata.tar.gz metadata.yaml

echo '=== Importing into Incus ==='
incus image delete "${IMAGE_NAME}" 2>/dev/null || true
incus image import /tmp/incus-image/metadata.tar.gz "${DISK}" --alias "${IMAGE_NAME}" --reuse

echo '=== Cleaning temporary files ==='
rm -rf /tmp/incus-image

echo "=== Done! Image ${IMAGE_NAME} is ready ==="
incus image list | grep "${IMAGE_NAME}"