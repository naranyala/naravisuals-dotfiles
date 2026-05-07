#!/bin/bash
# Simple installer for Plank dock on Debian-based systems

set -e  # Exit on error

echo "=== Updating package list ==="
sudo apt update

echo "=== Installing Plank ==="
sudo apt install -y plank

echo "=== Setting up autostart ==="
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/plank.desktop" <<EOL
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank
Comment=Simple dock for Linux
EOL

echo "=== Launching Plank ==="
plank &

echo "=== Done! Plank is installed, running, and set to start at login. ==="

