#!/bin/bash

set -euo pipefail

REPO_FILE="/etc/yum.repos.d/vscodium.repo"
PACKAGE_NAME="codium"

# Check if already installed
if rpm -q "$PACKAGE_NAME" &>/dev/null; then
    echo "✅ VSCodium is already installed."
    exit 0
fi

echo "🔧 Adding VSCodium RPM repository..."

sudo tee "$REPO_FILE" > /dev/null <<'EOF'
[gitlab.com_paulcarroty_vscodium_repo]
name=gitlab.com_paulcarroty_vscodium_repo
baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg
metadata_expire=1h
EOF

echo "🔄 Refreshing package metadata..."
sudo dnf makecache --refresh

echo "📥 Installing VSCodium..."
sudo dnf install -y codium

echo "🎉 VSCodium has been successfully installed!"
