#!/usr/bin/env bash
# Fedora KDE Plasma + mixed apps setup
# Includes KDE, GNOME, XFCE utilities and extras

set -e

echo "Updating system..."
sudo dnf -y update

echo "Installing KDE Plasma Desktop..."
sudo dnf -y install @kde-desktop-environment --skip-unavailable

### KDE Apps ###
echo "Installing KDE apps..."
sudo dnf -y install --skip-unavailable \
    konsole \
    dolphin \
    kate \
    okular \
    gwenview \
    kcalc \
    ark \
    spectacle \
    korganizer \
    k3b

### GNOME Apps ###
echo "Installing GNOME apps..."
sudo dnf -y install --skip-unavailable \
    gedit \
    evince \
    eog \
    gnome-calculator \
    file-roller \
    gnome-screenshot \
    gnome-system-monitor \
    baobab

### XFCE Apps ###
echo "Installing XFCE apps..."
sudo dnf -y install --skip-unavailable \
    mousepad \
    ristretto \
    xfce4-terminal \
    xfce4-taskmanager \
    xfce4-screenshooter \
    thunar \
    parole

### Cross-desktop Extras ###
echo "Installing cross-desktop extras..."
sudo dnf -y install --skip-unavailable \
    vlc \
    htop \
    neofetch \
    firefox

echo "Enabling SDDM (KDE login manager)..."
sudo systemctl disable gdm || true
sudo dnf -y install sddm
sudo systemctl enable sddm --force

echo "All done! Reboot to start KDE Plasma."

