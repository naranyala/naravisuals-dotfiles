#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
# Switch current login manager to SDDM
# Author: Fudzer (via Copilot)
# ─────────────────────────────────────────────

LOG_PREFIX="[SDDM-SWITCH]"
DISTRO_ID="$(. /etc/os-release && echo "$ID")"
KNOWN_DM=("lightdm" "gdm" "gdm3" "xdm" "lxdm" "ly" "sddm")

log() { echo -e "$LOG_PREFIX $1"; }

detect_pkg_manager() {
  if command -v apt &>/dev/null; then echo "apt"
  elif command -v pacman &>/dev/null; then echo "pacman"
  elif command -v dnf &>/dev/null; then echo "dnf"
  else log "No supported package manager found."; exit 1
  fi
}

install_sddm() {
  local pkg_mgr
  pkg_mgr="$(detect_pkg_manager)"
  log "Installing SDDM using $pkg_mgr..."

  case "$pkg_mgr" in
    apt) sudo apt update && sudo apt install -y sddm ;;
    pacman) sudo pacman -Sy --noconfirm sddm ;;
    dnf) sudo dnf install -y sddm ;;
  esac
}

detect_active_dm() {
  local active_dm
  active_dm="$(systemctl show -p Id display-manager.service 2>/dev/null | cut -d= -f2)"
  if [[ -z "$active_dm" ]]; then
    log "No active display manager detected via systemd. Checking fallback..."
    for dm in "${KNOWN_DM[@]}"; do
      if systemctl is-enabled "$dm" &>/dev/null; then
        echo "$dm"
        return
      fi
    done
    echo "none"
  else
    echo "$active_dm"
  fi
}

disable_current_dm() {
  local current_dm="$1"
  if [[ "$current_dm" == "none" ]]; then
    log "No active display manager to disable."
    return
  fi

  log "Disabling current display manager: $current_dm"
  sudo systemctl disable "$current_dm" || log "Failed to disable $current_dm (may not be a systemd unit)"
}

enable_sddm() {
  log "Enabling SDDM as default display manager..."
  sudo systemctl enable sddm
  sudo systemctl set-default graphical.target
}

main() {
  log "Starting login manager switch to SDDM..."
  install_sddm
  current_dm="$(detect_active_dm)"
  log "Detected current login manager: $current_dm"
  disable_current_dm "$current_dm"
  enable_sddm
  log "SDDM is now set as the default login manager. Reboot to apply."
}

main "$@"

