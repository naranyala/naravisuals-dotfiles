#!/usr/bin/env bash
# Quick MATE Desktop Installer for Arch-based distros
# Usage: sudo ./mate-quick-install.sh
set -euo pipefail
IFS=$'\n\t'

# --- Config ---
PACKAGES=(
  # Core graphics
  xorg-server xorg-xinit

  # Display manager
  lightdm lightdm-slick-greeter

  # MATE desktop
  mate mate-extra

  # Networking
  networkmanager network-manager-applet

  # Apps
  firefox vlc gimp libreoffice-fresh

  # Fonts
  ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji
)

# --- Functions ---
msg()  { printf '==> %s\n' "$*"; }
die()  { printf 'ERR: %s\n' "$*" >&2; exit 1; }

require_root() {
  [[ $EUID -eq 0 ]] || die "Please run as root."
}

check_arch() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${ID,,}" != "arch" && "${ID_LIKE,,}" != *"arch"* ]]; then
      die "This script is for Arch-based systems only."
    fi
  fi
}

install_packages() {
  msg "Updating system..."
  pacman -Syu --noconfirm
  msg "Installing packages..."
  pacman -S --noconfirm --needed "${PACKAGES[@]}"
}

configure_lightdm() {
  msg "Enabling LightDM..."
  mkdir -p /etc/lightdm
  if ! grep -q '^greeter-session=lightdm-slick-greeter' /etc/lightdm/lightdm.conf 2>/dev/null; then
    cat > /etc/lightdm/lightdm.conf <<'EOF'
[Seat:*]
greeter-session=lightdm-slick-greeter
user-session=mate
EOF
  fi
  systemctl enable lightdm
}

enable_services() {
  msg "Enabling NetworkManager..."
  systemctl enable NetworkManager
}

# --- Main ---
require_root
check_arch
install_packages
configure_lightdm
enable_services

msg "Installation complete. Reboot to start MATE."

