#!/usr/bin/env bash
# gnome-install.sh - Install GNOME desktop with essential applications on Arch Linux
# Usage: sudo ./gnome-install.sh

set -euo pipefail  # Fail on errors, undefined vars, or pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root (use sudo).${NC}"
    exit 1
fi

# Check for active pacman process
if pidof -q pacman; then
    echo -e "${RED}Error: Pacman is currently running. Please wait for it to finish.${NC}"
    exit 1
fi

# Confirmation prompt
echo -e "${YELLOW}=== GNOME Desktop Installation Script ===${NC}"
echo -e "${YELLOW}This will install:${NC}"
echo "  • GNOME core + extras (including apps, themes, and utilities)"
echo "  • GDM display manager"
echo "  • Essential applications (Firefox, LibreOffice, VLC, etc.)"
echo "  • Flatpak + Flathub support"
echo ""
read -p "Proceed with installation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installation cancelled.${NC}"
    exit 0
fi

# Function for colored status messages
status() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# 1. Full system update (critical for Arch)
echo -e "\n${YELLOW}>>> Step 1: Updating system${NC}"
pacman -Syu --noconfirm || error "System update failed"

# 2. Install GNOME core + extras
echo -e "\n${YELLOW}>>> Step 2: Installing GNOME desktop${NC}"
pacman -S --needed --noconfirm \
    gnome gnome-extra gdm \
    gvfs gvfs-smb gvfs-mtp gvfs-nfs gvfs-afc \
    xdg-desktop-portal-gtk \
    pipewire pipewire-pulse pipewire-alsa wireplumber \
    bluez bluez-utils \
    networkmanager network-manager-applet \
    gnome-tweaks gnome-extensions-app \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    adobe-source-code-pro-fonts || error "GNOME installation failed"

status "GNOME core and extras installed"

# 3. Install essential applications
echo -e "\n${YELLOW}>>> Step 3: Installing essential applications${NC}"
pacman -S --needed --noconfirm \
    firefox \
    # libreoffice-fresh libreoffice-fresh-en-us \
    vlc \
    # gimp \
    evince \
    eog \
    file-roller \
    gnome-calculator \
    gnome-calendar \
    gnome-contacts \
    gnome-maps \
    gnome-music \
    gnome-photos \
    gnome-screenshot \
    gnome-system-monitor \
    gnome-text-editor \
    baobab \
    gnome-disk-utility \
    gnome-characters \
    simple-scan \
    cheese \
    transmission-gtk \
    gedit \
    git curl wget \
    unzip p7zip \
    neofetch || error "Application installation failed"

status "Essential applications installed"

# 4. Enable required services
echo -e "\n${YELLOW}>>> Step 4: Enabling systemd services${NC}"
systemctl enable gdm.service || warning "Failed to enable GDM"
systemctl enable bluetooth.service 2>/dev/null || true
systemctl enable NetworkManager.service || warning "Failed to enable NetworkManager"

status "System services enabled"

# 5. Install Flatpak + Flathub (for additional apps)
echo -e "\n${YELLOW}>>> Step 5: Setting up Flatpak + Flathub${NC}"
if ! command -v flatpak &>/dev/null; then
    pacman -S --needed --noconfirm flatpak || warning "Flatpak installation failed"
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
status "Flatpak and Flathub configured"

# 6. Post-install recommendations
echo -e "\n${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Reboot your system: ${YELLOW}reboot${NC}"
echo "  2. After reboot, log in via GDM (GNOME session)"
echo "  3. Recommended post-install:"
echo "     • Install GNOME extensions: https://extensions.gnome.org"
echo "     • Configure Wayland vs X11 in /etc/gdm/custom.conf if needed"
echo "     • Install additional Flatpak apps:"
echo "         flatpak install flathub com.spotify.Client"
echo "         flatpak install flathub com.discordapp.Discord"
echo ""
echo -e "${YELLOW}Note:${NC} Some applications may require additional codecs."
echo "      Install multimedia codecs with:"
echo "      ${YELLOW}sudo pacman -S gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav${NC}"
echo ""

exit 0
