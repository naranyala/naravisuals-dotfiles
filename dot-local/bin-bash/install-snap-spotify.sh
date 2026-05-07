#!/usr/bin/env bash
# install_spotify.sh
# Bash script to install Spotify via Snap on Fedora or Debian/Ubuntu

set -euo pipefail

echo "=== Detecting package manager ==="
if command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
elif command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt"
else
    echo "Error: Supported package manager not found (dnf or apt-get required)."
    exit 1
fi
echo "Detected package manager: $PKG_MGR"

echo "=== Updating system packages ==="
if [ "$PKG_MGR" = "dnf" ]; then
    sudo dnf -y update
else
    sudo apt-get update -y
    sudo apt-get upgrade -y
fi

echo "=== Installing Snap support ==="
if [ "$PKG_MGR" = "dnf" ]; then
    sudo dnf -y install snapd
    sudo ln -s /var/lib/snapd/snap /snap || true
else
    sudo apt-get install -y snapd
fi

echo "=== Enabling snapd socket ==="
sudo systemctl enable --now snapd.socket || true

echo "=== Installing Spotify via Snap ==="
sudo snap install spotify

echo "=== Installation complete! ==="
echo "You can now launch Spotify from your app menu or by running: spotify"

