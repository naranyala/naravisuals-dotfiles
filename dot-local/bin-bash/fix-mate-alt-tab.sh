#!/usr/bin/env bash
#
# fix-mate-alt-tab.sh — Self-healing script for MATE Alt+Tab issues
# Author: Fudzer (with Copilot assist)
# Description: Detects and fixes broken Alt+Tab in MATE by restoring
#              Marco WM, resetting keybindings, and optionally clearing configs.
# Audit: Logs all actions to ~/mate-alt-tab-fix-YYYYmmdd-HHMMSS.log
#

LOGFILE="$HOME/mate-alt-tab-fix-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOGFILE"
}

log "=== Starting MATE Alt+Tab fix ==="

# 1. Check if Marco is running
if pgrep -x marco >/dev/null; then
    log "Marco is running."
else
    log "Marco is NOT running. Restarting..."
    nohup marco --replace >/dev/null 2>&1 &
    sleep 1
    if pgrep -x marco >/dev/null; then
        log "Marco restarted successfully."
    else
        log "ERROR: Failed to start Marco."
    fi
fi

# 2. Reset Alt+Tab keybindings
log "Resetting Alt+Tab keybindings..."
gsettings reset org.mate.Marco.global-keybindings switch-windows
gsettings reset org.mate.Marco.global-keybindings switch-windows-backward
log "Keybindings reset to defaults."

# 3. Check accessibility settings that may interfere
log "Disabling Sticky Keys and Slow Keys if enabled..."
gsettings set org.mate.accessibility-keyboard stickykeys-enable false
gsettings set org.mate.accessibility-keyboard slowkeys-enable false
log "Accessibility interference disabled."

# 4. Optional: Offer to clear MATE config
read -rp "Do you want to reset MATE config to defaults? (y/N): " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
    log "Backing up and clearing MATE config..."
    [[ -d "$HOME/.config/mate" ]] && mv "$HOME/.config/mate" "$HOME/.config/mate.bak.$(date +%s)"
    [[ -d "$HOME/.mateconf" ]] && mv "$HOME/.mateconf" "$HOME/.mateconf.bak.$(date +%s)"
    log "Config cleared. Please log out and back in."
else
    log "Skipped config reset."
fi

log "=== MATE Alt+Tab fix completed ==="
log "Log saved to $LOGFILE"

