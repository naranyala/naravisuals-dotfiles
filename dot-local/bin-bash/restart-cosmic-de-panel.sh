#!/usr/bin/env bash

set -euo pipefail

### CONFIG ###
LOG_FILE="/tmp/restart-cosmic.log"
PANEL_PROC="cosmic-panel"
SESSION_PROC="cosmic-session"
RESTART_TIMEOUT=5

### LOGGING ###
log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

### CHECK PROCESS ###
is_running() {
    pgrep -x "$1" &>/dev/null
}

### RESTART PANEL ###
restart_panel() {
    if is_running "$PANEL_PROC"; then
        log "Stopping $PANEL_PROC..."
        pkill -x "$PANEL_PROC"
        sleep 2
    else
        log "$PANEL_PROC not running. Skipping kill."
    fi

    log "Starting $PANEL_PROC..."
    nohup "$PANEL_PROC" &>> "$LOG_FILE" &
    sleep "$RESTART_TIMEOUT"

    if is_running "$PANEL_PROC"; then
        log "$PANEL_PROC restarted successfully."
    else
        log "Failed to restart $PANEL_PROC. Attempting full session restart..."
        restart_session
    fi
}

### RESTART SESSION ###
restart_session() {
    if is_running "$SESSION_PROC"; then
        log "Restarting $SESSION_PROC via systemd..."
        systemctl --user restart cosmic-session.target || log "systemctl restart failed."
    else
        log "$SESSION_PROC not running. Starting manually..."
        nohup "$SESSION_PROC" &>> "$LOG_FILE" &
    fi
}

### MAIN ###
log "=== COSMIC Restart Script Initiated ==="
restart_panel
log "=== COSMIC Restart Script Completed ==="

