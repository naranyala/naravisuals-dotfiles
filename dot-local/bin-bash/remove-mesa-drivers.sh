#!/usr/bin/env bash
# purge-mesa.sh — Danger zone: removes all Mesa-related packages

set -euo pipefail

LOGFILE="/var/log/purge-mesa.log"
DRYRUN="${DRYRUN:-false}"

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

find_mesa_packages() {
    log "🔍 Locating all Mesa-related packages..."
    dnf list installed | awk '/^mesa/ {print $1}'
}

purge_mesa() {
    local pkgs
    pkgs=$(find_mesa_packages)

    if [[ -z "$pkgs" ]]; then
        log "✅ No Mesa packages found."
        return
    fi

    log "⚠️ Packages to be removed:"
    echo "$pkgs" | tee -a "$LOGFILE"

    if [[ "$DRYRUN" == "true" ]]; then
        log "🧪 Dry-run: would remove $pkgs"
    else
        sudo dnf remove -y $pkgs
        log "✅ Mesa packages removed."
    fi
}

main() {
    log "🚨 Starting full Mesa purge..."
    purge_mesa
    log "🧹 Completed. System may require reboot or driver replacement."
}

main "$@"

