#!/bin/bash
# Install Ark, p7zip, and PeaZip on Fedora Linux

set -e

echo "Updating system..."
sudo dnf -y update

echo "Installing Ark and p7zip..."
sudo dnf -y install ark p7zip p7zip-plugins

echo "Installing PeaZip via Flatpak..."
# Ensure Flatpak is installed
sudo dnf -y install flatpak

# Add Flathub repo if not already added
if ! flatpak remote-list | grep -q flathub; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

# Install PeaZip
flatpak install -y flathub io.github.peazip.PeaZip

echo "All packages installed successfully!"

