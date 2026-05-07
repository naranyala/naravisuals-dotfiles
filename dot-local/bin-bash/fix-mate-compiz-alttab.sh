#!/usr/bin/env bash
#
# fix-compiz-alt-tab.sh — Restore Alt+Tab in MATE when using Compiz
# Author: Fudzer (with Copilot assist)
# Description: Ensures Compiz Application Switcher is enabled and Alt+Tab is bound.
#

LOGFILE="$HOME/fix-compiz-alt-tab-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOGFILE"
}

log "=== Starting Compiz Alt+Tab fix ==="

# 1. Check if Compiz is running
if pgrep -x compiz >/dev/null; then
    log "Compiz is running."
else
    log "Compiz is NOT running. Starting Compiz..."
    nohup compiz --replace >/dev/null 2>&1 &
    sleep 2
    if pgrep -x compiz >/dev/null; then
        log "Compiz started successfully."
    else
        log "ERROR: Could not start Compiz."
        exit 1
    fi
fi

# 2. Ensure ccsm/dconf are available
for pkg in compizconfig-settings-manager dconf-cli; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        log "Installing missing package: $pkg"
        sudo apt install -y "$pkg"
    fi
done

# 3. Enable Application Switcher plugin
PROFILE_PATH="/org/compiz/profiles/mate/plugins"
ACTIVE_PLUGINS_KEY="$PROFILE_PATH/core/active-plugins"

log "Enabling Application Switcher plugin..."
# Read current plugins
CURRENT_PLUGINS=$(dconf read "$ACTIVE_PLUGINS_KEY" | tr -d "[]'" | tr , '\n' | awk '{$1=$1};1')
if ! echo "$CURRENT_PLUGINS" | grep -q "^applicationswitcher$"; then
    UPDATED_PLUGINS=$(printf "%s\napplicationswitcher" "$CURRENT_PLUGINS" | awk 'NF' | sort -u | tr '\n' ',' | sed 's/,$//')
    dconf write "$ACTIVE_PLUGINS_KEY" "['$(echo "$UPDATED_PLUGINS" | sed "s/,/','/g")']"
    log "Application Switcher added to active plugins."
else
    log "Application Switcher already active."
fi

# 4. Bind Alt+Tab and Shift+Alt+Tab
log "Binding Alt+Tab and Shift+Alt+Tab..."
dconf write "$PROFILE_PATH/applicationswitcher/next-window" "['<Alt>Tab']"
dconf write "$PROFILE_PATH/applicationswitcher/prev-window" "['<Shift><Alt>Tab']"

log "Alt+Tab bindings restored."

log "=== Compiz Alt+Tab fix completed ==="
log "Log saved to $LOGFILE"

