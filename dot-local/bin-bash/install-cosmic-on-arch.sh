#!/bin/bash

# Exit on error
set -e

echo "🔧 Updating system..."
sudo pacman -Syu --noconfirm

echo "📦 Installing yay (AUR helper)..."
if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

echo "🌌 Installing COSMIC desktop components..."
yay -S cosmic-epoch cosmic-comp cosmic-edit cosmic-files cosmic-icons cosmic-panel cosmic-settings cosmic-term cosmic-text cosmic-workspaces cosmic-applibrary cosmic-launcher cosmic-randr cosmic-session cosmic-greeter --noconfirm

echo "🧼 Removing other desktop environments (optional)..."
read -p "Do you want to remove GNOME, KDE, or other DEs? (y/N): " remove_de
if [[ "$remove_de" == "y" || "$remove_de" == "Y" ]]; then
    sudo pacman -Rns gnome gnome-extra plasma kde-applications xfce4 xfce4-goodies --noconfirm || true
fi

echo "🖥️ Setting COSMIC as default session..."
sudo mkdir -p /usr/share/xsessions
cat <<EOF | sudo tee /usr/share/xsessions/cosmic.desktop
[Desktop Entry]
Name=COSMIC
Comment=System76 COSMIC Desktop
Exec=cosmic-session
Type=Application
EOF

echo "🚀 Enabling COSMIC greeter (if using GDM or other DM)..."
# Example for GDM
sudo systemctl enable gdm.service

echo "✅ COSMIC installation complete. Reboot to start using COSMIC."

