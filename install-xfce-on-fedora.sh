#!/usr/bin/env bash
# install-xfce-fedora.sh
# Script to install XFCE desktop and selected lightweight apps on Fedora

set -euo pipefail

echo "Updating system..."
sudo dnf -y update

echo "Installing XFCE desktop group..."
sudo dnf -y groupinstall "Xfce Desktop"

echo "Installing core XFCE apps..."
sudo dnf -y install \
    xfce4-panel \
    xfce4-session \
    xfce4-settings \
    xfce4-terminal \
    thunar \
    ristretto \
    mousepad \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-notifyd \
    xfce4-power-manager

echo "Installing additional lightweight apps..."
sudo dnf -y install \
    pavucontrol \        # audio control
    galculator \         # calculator
    file-roller \        # archive manager
    xarchiver \          # alternative archive manager
    geany \              # lightweight IDE/editor
    lxappearance \       # theme/appearance tool
    nitrogen \           # wallpaper manager
    neofetch \           # system info
    htop \               # process monitor
    curl wget \          # network utilities

echo "Enabling graphical target..."
sudo systemctl set-default graphical.target

echo "Installation complete! Reboot to start XFCE."

