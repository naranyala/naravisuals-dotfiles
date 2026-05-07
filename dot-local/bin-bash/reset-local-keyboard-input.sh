#!/bin/bash

# Reset keyboard layout to US QWERTY (Wayland/KDE-friendly)
# Works on systemd-based distros

log() { echo "[*] $1"; }
warn() { echo "[!] $1"; }

# Check for systemd
if ! pidof systemd >/dev/null; then
  warn "Systemd not detected. This script requires systemd (for localectl)."
  exit 1
fi

# Check localectl availability
if ! command -v localectl &>/dev/null; then
  warn "'localectl' not found. Make sure systemd is installed properly."
  exit 1
fi

# Show current layout
current_layout=$(localectl status | grep "X11 Layout" | awk '{print $3}')
log "Current keyboard layout: $current_layout"

# If layout is already US, offer to skip
if [[ "$current_layout" == "us" ]]; then
  read -p "Keyboard layout is already 'us'. Reset anyway? [y/N]: " confirm
  [[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0
fi

# Reset layout
log "Resetting keyboard layout to US QWERTY..."
sudo localectl set-keymap us
sudo localectl set-x11-keymap us pc105

log "Layout reset complete. You may need to log out and log back in."


