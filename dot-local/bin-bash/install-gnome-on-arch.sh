#!/bin/bash

# Update system
sudo pacman -Syu --noconfirm

# Install Xorg (display server)
sudo pacman -S --noconfirm xorg xorg-xinit

# Install GNOME desktop (base + extras)
sudo pacman -S --noconfirm gnome gnome-extra

# Disable other login managers if installed
sudo systemctl disable lightdm.service 2>/dev/null || true
sudo systemctl disable sddm.service 2>/dev/null || true
sudo systemctl disable lxdm.service 2>/dev/null || true

# Enable GDM (GNOME Display Manager)
sudo systemctl enable gdm.service
sudo systemctl set-default graphical.target
sudo systemctl start gdm.service

# Install lightweight, useful apps
sudo pacman -S --noconfirm \
    firefox \
    vlc \
    neofetch \
    git \
    base-devel \
    htop \
    curl \
    wget \
    nano \
    vim \
    file-roller \
    eog \
    evince

# Install yay (AUR helper) as normal user
cd ~
if [ ! -d yay ]; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    # Run makepkg as normal user, not root
    makepkg -si --noconfirm
fi

# Example AUR apps (via yay)
yay -S --noconfirm google-chrome visual-studio-code-bin

echo "✅ GNOME desktop, lightweight apps, and GDM installed successfully!"

