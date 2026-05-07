#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Installing Unity Hub dependencies..."
sudo dnf install -y --skip-unavailable \
    openssl \
    openssl-libs \
    openssl1.1 \
    GConf2 \
    mono-complete \
    gcc-c++ make

echo "[INFO] Adding Unity Hub repository..."
sudo sh -c 'echo -e "[unityhub]
name=Unity Hub
baseurl=https://hub.unity3d.com/linux/repos/rpm/stable
enabled=1
gpgcheck=1
gpgkey=https://hub.unity3d.com/linux/repos/rpm/stable/repodata/repomd.xml.key
repo_gpgcheck=1" > /etc/yum.repos.d/unityhub.repo'

echo "[INFO] Updating package lists..."
sudo dnf check-update || true

echo "[INFO] Installing Unity Hub..."
sudo dnf install -y unityhub

echo "[INFO] Unity Hub installation complete."
echo "Launch with: unityhub"

