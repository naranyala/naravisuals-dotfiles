#!/usr/bin/env bash
# Quick MATE Desktop Installer for Fedora
# Usage: sudo ./mate-quick-install.sh

set -euo pipefail
IFS=$'\n\t'

# --- Config ---
PACKAGES=(
  # Core graphics
  @x11

  # Display manager
  lightdm lightdm-gtk

  # MATE desktop
  @mate-desktop @mate-applications

  # Networking
  NetworkManager NetworkManager-applet

  # Apps
  firefox vlc gimp #libreoffice

  # Fonts
  dejavu-sans-fonts liberation-fonts google-noto-sans-fonts google-noto-cjk-fonts google-noto-emoji-fonts
)

# --- Functions ---
msg()  { printf '==> %s\n' "$*"; }
die()  { printf 'ERR: %s\n' "$*" >&2; exit 1; }

require_root() {
  [[ $EUID -eq 0 ]] || die "Please run as root."
}

check_fedora() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "${ID,,}" != "fedora" && "${ID_LIKE,,}" != *"fedora"* ]]; then
      die "This script is for Fedora-based systems only."
    fi
  fi
}

install_packages() {
  msg "Updating system..."
  # dnf -y update
  msg "Installing packages..."
  dnf -y install "${PACKAGES[@]}" --skip-unavailable
}

configure_lightdm() {
  msg "Enabling LightDM..."
  mkdir -p /etc/lightdm
  if ! grep -q '^greeter-session=lightdm-gtk-greeter' /etc/lightdm/lightdm.conf 2>/dev/null; then
    cat > /etc/lightdm/lightdm.conf <<'EOF'
[Seat:*]
greeter-session=lightdm-gtk-greeter
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
check_fedora
install_packages
configure_lightdm
enable_services

msg "Installation complete. Reboot to start MATE."

