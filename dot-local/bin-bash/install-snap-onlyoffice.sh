#!/bin/bash

set -euo pipefail

echo "📦 Installing snapd from AUR..."

# Check for required tools
if ! command -v git &> /dev/null || ! command -v makepkg &> /dev/null; then
    echo "❌ 'git' and 'makepkg' are required. Please install base-devel and git first."
    exit 1
fi

# Create a temporary working directory
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

cd "$WORKDIR"

# Clone and install snapd
if git clone https://aur.archlinux.org/snapd.git; then
    cd snapd
    makepkg -si --noconfirm
else
    echo "❌ Failed to clone snapd from AUR."
    exit 1
fi

# Enable and start snapd.socket
echo "🔧 Enabling snapd.socket..."
sudo systemctl enable --now snapd.socket

# Create symlink if needed
if [ ! -e /snap ]; then
    echo "🔗 Creating /snap symlink..."
    sudo ln -s /var/lib/snapd/snap /snap
fi

echo "⏳ Waiting for snapd to initialize..."
sleep 5

# Install OnlyOffice Desktop Editors
echo "🚀 Installing OnlyOffice Desktop Editors via Snap..."
if sudo snap install onlyoffice-desktopeditors; then
    echo "✅ Installation complete! You can now launch OnlyOffice from your application menu."
else
    echo "❌ Failed to install OnlyOffice. Please check snapd status and try again."
    exit 1
fi

