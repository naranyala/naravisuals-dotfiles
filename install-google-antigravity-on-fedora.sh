#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, pipe failures

REPO_FILE="/etc/yum.repos.d/antigravity.repo"
PACKAGE_NAME="antigravity"

# Check if already installed
if rpm -q "$PACKAGE_NAME" &>/dev/null; then
    echo "✅ $PACKAGE_NAME is already installed."
    exit 0
fi

echo "🔧 Adding Antigravity RPM repository..."

# Add the repository
sudo tee "$REPO_FILE" > /dev/null <<EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

echo "🔄 Refreshing package metadata..."
sudo dnf makecache

echo "📥 Installing $PACKAGE_NAME..."
sudo dnf install -y "$PACKAGE_NAME"

echo "🎉 Antigravity IDE has been successfully installed!"
