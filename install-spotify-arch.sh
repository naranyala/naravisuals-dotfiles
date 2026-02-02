#!/usr/bin/env bash
# install_spotify_arch.sh
# Bash script to install Spotify via Snap on Arch Linux
# Includes error handling and systemd integration

set -euo pipefail

echo "=== Detecting package manager ==="
if command -v pacman >/dev/null 2>&1; then
    PKG_MGR="pacman"
else
    echo "Error: Arch Linux requires pacman."
    exit 1
fi
echo "Detected package manager: $PKG_MGR"

echo "=== Updating system packages ==="
sudo pacman -Syu --noconfirm

echo "=== Installing Snap support ==="
sudo pacman -S --noconfirm snapd || {
    echo "❌ Failed to install snapd"
    exit 1
}

echo "=== Enabling snapd socket ==="
sudo systemctl enable --now snapd.socket || true

echo "=== Creating /snap symlink (if missing) ==="
sudo ln -s /var/lib/snapd/snap /snap 2>/dev/null || true

echo "=== Installing Spotify via Snap ==="
sudo snap install spotify || {
    echo "❌ Failed to install Spotify via Snap"
    exit 1
}

echo "=== Installation complete! ==="
echo "You can now launch Spotify from your app menu or by running: spotify"

