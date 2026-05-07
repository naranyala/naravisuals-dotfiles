#!/usr/bin/env bash
#
# powerctl.sh — Modular power management script
# Author: Fudzer + Copilot
# Description: Suspend, hibernate, reboot, shutdown, or lock the system
#              with confirmation, logging, and easy extensibility.

set -euo pipefail

# === CONFIG ===
LOG_FILE="${HOME}/.local/share/powerctl.log"

# Map actions to commands
declare -A ACTIONS=(
    [suspend]="systemctl suspend"
    [hibernate]="systemctl hibernate"
    [reboot]="systemctl reboot"
    [poweroff]="systemctl poweroff"
    [lock]="loginctl lock-session"
)

# === FUNCTIONS ===
log_action() {
    local action="$1"
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$(date '+%F %T') — $action" >> "$LOG_FILE"
}

list_actions() {
    echo "Usage: $0 <action>"
    echo
    echo "Available actions:"
    for act in "${!ACTIONS[@]}"; do
        echo "  - $act"
    done
}

confirm() {
    local action="$1"
    read -rp "Are you sure you want to '$action'? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

run_action() {
    local action="$1"
    if [[ -n "${ACTIONS[$action]:-}" ]]; then
        if confirm "$action"; then
            log_action "$action"
            eval "${ACTIONS[$action]}"
        else
            echo "Cancelled."
        fi
    else
        echo "Unknown action: $action"
        list_actions
        exit 1
    fi
}

# === MAIN ===
if [[ $# -eq 0 ]]; then
    list_actions
    exit 0
fi

run_action "$1"

