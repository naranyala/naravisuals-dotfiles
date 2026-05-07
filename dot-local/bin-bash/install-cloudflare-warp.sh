#!/bin/bash
# Cloudflare WARP installation script for Fedora Linux

set -e

echo ">>> Removing old Cloudflare GPG key (if exists)..."
sudo rpm -e 'gpg-pubkey' || true

echo ">>> Importing Cloudflare GPG key..."
sudo rpm --import https://pkg.cloudflareclient.com/pubkey.gpg

echo ">>> Adding Cloudflare WARP repository..."
curl -fsSL https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo

echo ">>> Updating package metadata..."
sudo dnf update -y

echo ">>> Installing Cloudflare WARP..."
sudo dnf install -y cloudflare-warp

echo ">>> Installation complete!"
echo "You can now run 'warp-cli register' and 'warp-cli connect' to start using WARP."

