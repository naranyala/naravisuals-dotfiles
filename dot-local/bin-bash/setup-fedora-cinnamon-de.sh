#!/usr/bin/env bash
# install-cinnamon-full.sh — Installs Cinnamon desktop and extras via DNF

set -euo pipefail

log() {
  echo "[INFO] $*" >&2
}

err() {
  echo "[ERROR] $*" >&2
  exit 1
}

check_command() {
  command -v "$1" >/dev/null 2>&1 || err "Missing required command: $1"
}

check_dnf_group() {
  local group="$1"
  sudo dnf group list --available | grep -i "$group" >/dev/null || err "Group '$group' not found in available DNF groups"
}

install_cinnamon() {
  log "Installing Cinnamon desktop group..."
  # sudo dnf install cinnamon-desktop -y --skip-unavailable
  sudo dnf group install cinnamon-desktop -y 
}

install_extras() {
  local -a extra_packages=(
    gnome-terminal nemo-fileroller gnome-system-monitor
    vlc rhythmbox gthumb pavucontrol
    gnome-tweaks dconf-editor fonts-cantarell arc-theme
    network-manager-applet blueman firewalld nm-connection-editor
    git vim code gnome-disk-utility htop
    orca onboard gnome-font-viewer
  )

  log "Installing complementary packages..."
  sudo dnf install -y "${extra_packages[@]}" --skip-unavailable
}

main() {
  check_command dnf
  check_command sudo

  install_cinnamon
  install_extras

  log "Cinnamon desktop and extras installed successfully."
}

main "$@"

