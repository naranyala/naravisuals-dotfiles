#!/usr/bin/env bash
set -euo pipefail

# gnome-app-store-installer.sh
# Installs GNOME Software with Flatpak support and Flathub on Fedora (dnf or rpm-ostree).
# Usage:
#   sudo bash gnome-app-store-installer.sh            # Install
#   sudo bash gnome-app-store-installer.sh --uninstall # Uninstall
#   sudo bash gnome-app-store-installer.sh --no-flathub # Skip enabling Flathub

# -----------------------------
# Helpers
# -----------------------------
err() { echo "ERROR: $*" >&2; }
info() { echo "INFO: $*"; }
warn() { echo "WARN: $*"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    err "Please run as root (use sudo)."
    exit 1
  fi
}

is_fedora() {
  [[ -f /etc/fedora-release ]]
}

is_ostree() {
  command -v rpm-ostree >/dev/null 2>&1
}

reboot_needed=false

enable_flathub() {
  if command -v flatpak >/dev/null 2>&1; then
    if flatpak remote-list | awk '{print $1}' | grep -qx "flathub"; then
      info "Flathub is already enabled."
    else
      info "Enabling Flathub remote..."
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      info "Flathub enabled."
    fi
  else
    warn "Flatpak not found; skipping Flathub remote."
  fi
}

# -----------------------------
# Install paths
# -----------------------------
install_dnf() {
  info "Installing GNOME Software via dnf..."
  # dnf -y install --skip-unavailable \ 
    # gnome-software \
    # gnome-software-plugin-flatpak \
    # flatpak

  # PackageKit is usually pulled in automatically; ensure it’s present.
  dnf -y install PackageKit || true

  # Optional: make sure socket is ready (PackageKit uses socket activation).
  systemctl list-unit-files | grep -q "packagekit.service" || true

  # Enable Flathub
  $enable_flathub && enable_flathub

  info "GNOME Software installed (dnf)."
}

install_ostree() {
  info "Installing GNOME Software via rpm-ostree..."
  rpm-ostree install \
    gnome-software \
    gnome-software-plugin-flatpak \
    flatpak || {
      err "rpm-ostree install failed."
      exit 1
    }

  # PackageKit for GNOME Software
  rpm-ostree install PackageKit || true

  reboot_needed=true

  # Flathub can be enabled before reboot if flatpak is already present; otherwise after.
  if command -v flatpak >/dev/null 2>&1; then
    $enable_flathub && enable_flathub
  else
    warn "Flatpak CLI will be available after reboot; Flathub will need enabling then."
  fi

  info "GNOME Software queued for installation (rpm-ostree). Reboot required."
}

# -----------------------------
# Uninstall paths
# -----------------------------
uninstall_dnf() {
  info "Uninstalling GNOME Software via dnf..."
  dnf -y remove gnome-software gnome-software-plugin-flatpak || true
  info "Removing Flatpak (optional)..."
  dnf -y remove flatpak || true
  info "Uninstall complete (dnf)."
}

uninstall_ostree() {
  info "Uninstalling GNOME Software via rpm-ostree (layer removal)..."
  rpm-ostree uninstall gnome-software gnome-software-plugin-flatpak flatpak || true
  reboot_needed=true
  info "Uninstall queued (rpm-ostree). Reboot required."
}

# -----------------------------
# Main
# -----------------------------
require_root

# Parse flags
do_uninstall=false
enable_flathub=true
for arg in "$@"; do
  case "$arg" in
    --uninstall) do_uninstall=true ;;
    --no-flathub) enable_flathub=false ;;
    *) err "Unknown option: $arg"; exit 1 ;;
  esac
done

# if ! is_fedora; then
#  err "This script is intended for Fedora."
#  exit 1
# fi

if $do_uninstall; then
  if is_ostree; then
    uninstall_ostree
  else
    uninstall_dnf
  fi
else
  if is_ostree; then
    install_ostree
  else
    install_dnf
  fi
fi

# Post-install guidance
if $reboot_needed; then
  echo
  warn "A system reboot is required to finalize changes."
  echo "Run: sudo systemctl reboot"
else
  echo
  info "Done. You can launch GNOME Software from your app menu or with: gnome-software"
fi

# If we couldn’t enable Flathub earlier, guide the user
if ! $do_uninstall && ! $enable_flathub; then
  warn "Flathub was skipped by request (--no-flathub)."
elif ! $do_uninstall && $enable_flathub && ! command -v flatpak >/dev/null 2>&1; then
  warn "After reboot, enable Flathub with:"
  echo "  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo"
fi

