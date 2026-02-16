#!/usr/bin/env bash
# Arch Linux Wine + QEMU Setup Toolkit
# Author: Fudzer (modular systems builder)

set -euo pipefail
IFS=$'\n\t'

LOGFILE="/var/log/wine_qemu_setup.log"
ROLLBACK_ACTIONS=()

# --- Utility functions ---
log() { echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"; }
rollback() {
  log "Rolling back..."
  for action in "${ROLLBACK_ACTIONS[@]}"; do
    eval "$action" || log "Rollback step failed: $action"
  done
}

trap rollback ERR

# --- Presets ---
PRESET="${1:-full}"   # options: minimal, full

# --- Package installer ---
install_pkg() {
  local pkg="$1"
  if ! pacman -Qi "$pkg" &>/dev/null; then
    log "Installing $pkg..."
    sudo pacman --noconfirm -S "$pkg"
    ROLLBACK_ACTIONS+=("sudo pacman -Rns --noconfirm $pkg")
  else
    log "$pkg already installed."
  fi
}

# --- Wine setup ---
setup_wine() {
  log "Setting up Wine..."
  sudo pacman --noconfirm -S wine winetricks
  sudo pacman --noconfirm -S lib32-mesa lib32-nvidia-utils || true
  mkdir -p "$HOME/.wine"
  log "Wine prefix initialized at ~/.wine"
}

# --- QEMU setup ---
setup_qemu() {
  log "Setting up QEMU + libvirt..."
  sudo pacman --noconfirm -S qemu virt-manager dnsmasq vde2 bridge-utils openbsd-netcat
  sudo pacman --noconfirm -S libvirt
  sudo systemctl enable --now libvirtd
  sudo usermod -aG libvirt "$USER"
  log "QEMU + libvirt configured. Re-login required for group changes."
}

# --- Main orchestration ---
main() {
  log "Starting setup with preset: $PRESET"

  case "$PRESET" in
    minimal)
      install_pkg wine
      install_pkg qemu
      ;;
    full)
      setup_wine
      setup_qemu
      ;;
    *)
      log "Unknown preset: $PRESET"
      exit 1
      ;;
  esac

  log "Setup complete!"
}

main "$@"

