#!/usr/bin/env bash
# Minimal Cinnamon Desktop Environment with essentials (Fedora)

set -euo pipefail

echo "Updating system..."
sudo dnf -y update

FEDORA_VERSION=$(rpm -E %fedora)
echo "Detected Fedora version: $FEDORA_VERSION"

echo "Installing Cinnamon core..."
if [[ $FEDORA_VERSION -ge 41 ]]; then
  sudo dnf -y group install "cinnamon-desktop"
else
  sudo dnf -y group install "cinnamon-desktop-environment"
fi

echo "Installing essential utilities..."
sudo dnf -y install \
  cinnamon \
  cinnamon-control-center \
  cinnamon-screensaver \
  nemo \
  nemo-fileroller \
  gnome-terminal \
  gedit \
  network-manager-applet \
  system-config-printer \
  xorg-x11-drv-libinput \
  pavucontrol \
  evince \
  file-roller \
  gnome-disk-utility \
  simple-scan \
  vlc \
  ristretto \
  htop \
  curl \
  wget \
  nano

echo "Setting graphical target as default..."
sudo systemctl set-default graphical.target

echo "Done! Reboot and select Cinnamon at login."
