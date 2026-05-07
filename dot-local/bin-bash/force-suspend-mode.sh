#!/usr/bin/env bash
# suspend-universal-confirm.sh — Suspend system with countdown and post-resume confirmation

set -euo pipefail

LOGFILE="/var/log/suspend-universal.log"
DRY_RUN=false
COUNTDOWN=5  # seconds before suspend

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

detect_suspend_command() {
    if command -v systemctl &>/dev/null; then
        echo "systemctl suspend"
    elif command -v pm-suspend &>/dev/null; then
        echo "pm-suspend"
    elif [ -w /sys/power/state ]; then
        echo "echo mem > /sys/power/state"
    else
        log "ERROR: No known suspend method available on this system."
        exit 1
    fi
}

countdown_timer() {
    log "Countdown initiated: suspending in $COUNTDOWN seconds..."
    for ((i=COUNTDOWN; i>0; i--)); do
        echo -ne "Suspending in $i...\r"
        sleep 1
    done
    echo ""
}

suspend_system() {
    local cmd
    cmd=$(detect_suspend_command)
    log "Suspend method detected: $cmd"

    if $DRY_RUN; then
        log "Dry run enabled — suspend command skipped."
    else
        countdown_timer
        log "Executing suspend command..."
        eval "$cmd"
        log "System resumed from suspend."
    fi
}

post_resume_confirmation() {
    echo ""
    read -rp "✅ System resumed. Press Enter to confirm and continue..." _
    log "User confirmed resume at $(date '+%Y-%m-%d %H:%M:%S')"
}

main() {
    suspend_system
    post_resume_confirmation
}

main "$@"

