#!/bin/bash
# Script to install Cinnamon Desktop with custom configuration on Fedora (dnf5)

set -e

echo "=== Updating system packages ==="
sudo dnf5 upgrade -y

echo "=== Installing Cinnamon Desktop Environment ==="
# In dnf5, use @groupname instead of groupinstall
sudo dnf5 install -y @cinnamon-desktop-environment

echo "=== Installing additional useful packages ==="
sudo dnf5 install -y \
    cinnamon-screensaver \
    cinnamon-translations \
    gnome-terminal \
    network-manager-applet \
    xorg-x11-server-Xorg \
    lightdm lightdm-gtk \
    vim git curl wget gnome-system-monitor

echo "=== Setting graphical target as default ==="
sudo systemctl set-default graphical.target

echo "=== Switching display manager to LightDM ==="
# Disable GDM if active
sudo systemctl disable gdm || true

# Remove old symlink if it exists
if [ -L /etc/systemd/system/display-manager.service ]; then
    echo "Removing existing display-manager symlink..."
    sudo rm /etc/systemd/system/display-manager.service
fi

# Enable LightDM (creates new symlink)
sudo systemctl enable lightdm

echo "=== Applying custom Cinnamon configuration ==="

# Create config directories if not present
mkdir -p ~/.config/cinnamon ~/.themes ~/.icons

# Example: set Cinnamon panel layout
gsettings set org.cinnamon panels-enabled "['1:panel1']"
gsettings set org.cinnamon panel-launchers "['firefox.desktop', 'org.gnome.Terminal.desktop']"

# Example: set favorite apps
gsettings set org.cinnamon favorite-apps "['firefox.desktop', 'org.gnome.Terminal.desktop', 'nemo.desktop']"

# Example: set theme and icons
gsettings set org.cinnamon.desktop.interface gtk-theme "Adwaita-dark"
gsettings set org.cinnamon.desktop.interface icon-theme "Papirus"
gsettings set org.cinnamon.desktop.interface cursor-theme "Breeze"

# Example: set background wallpaper
gsettings set org.cinnamon.desktop.background picture-uri "file:///usr/share/backgrounds/fedora/default.jpg"

# Example: configure screensaver timeout
gsettings set org.cinnamon.desktop.session idle-delay 600

echo "=== Installation and configuration complete! ==="
echo "Reboot your system to start Cinnamon with your custom setup."

