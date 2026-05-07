#!/usr/bin/env bash
set -euo pipefail

# snap-app-store-installer.sh
# Installs Snapd and the Snap Store GUI on Fedora.
# Usage:
#   sudo bash snap-app-store-installer.sh
#   sudo bash snap-app-store-installer.sh --uninstall

err() { echo "ERROR: $*" >&2; }
info() { echo "INFO: $*"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    err "Please run as root (use sudo)."
    exit 1
  fi
}

install_snap() {
  info "Installing snapd..."
  dnf -y install snapd

  info "Enabling snapd socket..."
  systemctl enable --now snapd.socket

  # Ensure /snap symlink exists (needed for classic confinement)
  if [[ ! -e /snap ]]; then
    ln -s /var/lib/snapd/snap /snap
  fi

  info "Installing Snap Store GUI..."
  snap install snap-store

  info "Snap Store installed. Launch it from your app menu."
}

uninstall_snap() {
  info "Removing Snap Store..."
  snap remove snap-store || true

  info "Removing snapd..."
  dnf -y remove snapd || true

  info "Uninstall complete."
}

# -----------------------------
# Main
# -----------------------------
require_root

do_uninstall=false
for arg in "$@"; do
  case "$arg" in
    --uninstall) do_uninstall=true ;;
    *) err "Unknown option: $arg"; exit 1 ;;
  esac
done

if $do_uninstall; then
  uninstall_snap
else
  install_snap
fi

