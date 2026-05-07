#!/usr/bin/env bash

# === Metadata ===
SCRIPT_NAME="mesa_recovery.sh"
LOG_FILE="/var/log/mesa_recovery.log"
DISTRO=$(grep -Po '(?<=^ID=).+' /etc/os-release | tr -d '"')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# === Logging ===
log() {
  echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

# === Check Mesa Status ===
check_mesa() {
  log "Checking installed Mesa packages..."
  dnf list installed | grep mesa || log "No Mesa packages found."
  log "Checking OpenGL version..."
  glxinfo | grep "OpenGL version" || log "glxinfo not available or broken."
}

# === Rollback Mesa ===
rollback_mesa() {
  log "Attempting to downgrade Mesa packages..."
  sudo dnf downgrade mesa* -y || log "Downgrade failed or no previous version available."
}

# === Undo Last DNF Transaction ===
undo_last_update() {
  log "Listing DNF history..."
  sudo dnf history
  read -p "Enter transaction ID to undo: " TXID
  log "Undoing transaction $TXID..."
  sudo dnf history undo "$TXID" -y || log "Undo failed."
}

# === Clean Reinstall Mesa ===
reinstall_mesa() {
  log "Removing Mesa packages..."
  sudo dnf remove mesa* --noautoremove -y
  log "Reinstalling core Mesa packages..."
  sudo dnf install -y mesa-dri-drivers mesa-vulkan-drivers mesa-libGL mesa-libEGL
}

# === Check Dependencies ===
check_deps() {
  log "Checking for broken dependencies..."
  sudo dnf check || log "Dependency check failed."
  sudo dnf repoquery --unsatisfied || log "Unsatisfied dependencies found."
}

# === Rebuild GL Cache ===
rebuild_cache() {
  log "Rebuilding GL and MIME cache..."
  sudo ldconfig
  sudo update-mime-database /usr/share/mime
  rm -rf ~/.cache/mesa_shader_cache
}

# === Lock Mesa Version ===
lock_mesa() {
  log "Locking Mesa version to prevent future breakage..."
  sudo dnf install -y 'dnf-plugins-core'
  sudo dnf versionlock add mesa*
}

# === Main Execution ===
main() {
  log "=== Starting Mesa Recovery Script ==="
  check_mesa
  rollback_mesa
  reinstall_mesa
  check_deps
  rebuild_cache
  lock_mesa
  log "=== Mesa Recovery Complete ==="
}

main

