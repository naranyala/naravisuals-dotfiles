
#!/usr/bin/env bash
set -euo pipefail

# === Config ===
LOG_FILE="$HOME/.local/state/switch-shell.log"
BACKUP_FILE="$HOME/.local/state/switch-shell.backup"
NEW_SHELL="${1:-}"

# === Logging ===
log() { echo "[switch-shell] $*" | tee -a "$LOG_FILE"; }

# === Check Requirements ===
require_chsh() {
  if ! command -v chsh &>/dev/null; then
    log "Error: 'chsh' command not found."
    exit 1
  fi
}

validate_shell() {
  if [[ ! -x "$NEW_SHELL" ]]; then
    log "Error: '$NEW_SHELL' is not executable."
    exit 1
  fi
  if ! grep -Fxq "$NEW_SHELL" /etc/shells; then
    log "Error: '$NEW_SHELL' is not listed in /etc/shells."
    exit 1
  fi
}

backup_current_shell() {
  local current_shell
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  echo "$current_shell" > "$BACKUP_FILE"
  log "Backed up current shell: $current_shell"
}

switch_shell() {
  log "Switching shell to: $NEW_SHELL"
  chsh -s "$NEW_SHELL"
  log "Shell switched. You may need to log out and back in."
}

# === Main ===
main() {
  if [[ -z "$NEW_SHELL" ]]; then
    echo "Usage: $0 /path/to/new/shell"
    exit 1
  fi

  require_chsh
  validate_shell
  backup_current_shell
  switch_shell
}

main "$@"
