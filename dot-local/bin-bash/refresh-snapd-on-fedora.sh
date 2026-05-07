#!/usr/bin/env bash
set -euo pipefail

# === Usage ===
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <snap-app-name>"
  exit 1
fi

APP_NAME="$1"
LOG_FILE="/tmp/snap_visibility_fix.log"

log() {
  echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"
}

ensure_snapd() {
  if ! command -v snap &>/dev/null; then
    log "Snapd not found. Installing..."
    sudo dnf install -y snapd
    sudo systemctl enable --now snapd.socket
  else
    log "Snapd is installed."
  fi
}

ensure_classic_support() {
  if [[ ! -e /snap ]]; then
    log "Creating /snap symlink..."
    sudo ln -s /var/lib/snapd/snap /snap
  else
    log "/snap symlink already exists."
  fi
}

expose_binary() {
  local bin_path="/snap/bin/$APP_NAME"
  if [[ -x "$bin_path" ]]; then
    log "Creating symlink: $bin_path → /usr/local/bin/$APP_NAME"
    sudo ln -sf "$bin_path" "/usr/local/bin/$APP_NAME"
  else
    log "Binary not found at $bin_path. Skipping symlink."
  fi
}

refresh_desktop_entry() {
  local desktop_file="/var/lib/snapd/desktop/applications/${APP_NAME}.desktop"
  if [[ -f "$desktop_file" ]]; then
    log "Refreshing desktop entries..."
    sudo update-desktop-database
  else
    log "No desktop entry found for $APP_NAME"
  fi
}

check_selinux() {
  if command -v getenforce &>/dev/null; then
    local mode
    mode=$(getenforce)
    log "SELinux mode: $mode"
    if [[ "$mode" == "Enforcing" ]]; then
      log "⚠️ SELinux may block Snap. Consider 'sudo setenforce 0' for testing."
    fi
  fi
}

main() {
  log "=== Fixing Snap visibility for: $APP_NAME ==="
  ensure_snapd
  ensure_classic_support
  expose_binary
  refresh_desktop_entry
  check_selinux
  log "=== Done ==="
}

main

