#!/usr/bin/env bash
# dnf5-repair.sh — Force-repair broken DNF5 update in Fedora Linux

set -euo pipefail

LOGFILE="/var/log/dnf5-repair.log"
DRYRUN="${DRYRUN:-false}"

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

preflight() {
    log "🔍 Preflight checks..."
    command -v dnf5 >/dev/null || { log "❌ dnf5 not found. Aborting."; exit 1; }
    command -v rpm >/dev/null || { log "❌ rpm not found. Aborting."; exit 1; }
}

clean_cache() {
    log "🧹 Cleaning DNF5 cache..."
    sudo dnf5 clean all
    sudo rm -rf /var/cache/dnf/*
}

rebuild_rpm_db() {
    log "🔧 Rebuilding RPM database..."
    sudo rm -f /var/lib/rpm/__db*
    sudo rpm --rebuilddb
}

verify_system() {
    log "🔍 Verifying system integrity..."
    sudo dnf5 verify | tee -a "$LOGFILE"
}

sync_packages() {
    log "🔄 Syncing installed packages with repo versions..."
    if [[ "$DRYRUN" == "true" ]]; then
        log "🧪 Dry-run: would run 'dnf5 distro-sync'"
    else
        sudo dnf5 distro-sync -y
    fi
}

force_update() {
    log "🚀 Forcing update with best match and erasing conflicts..."
    if [[ "$DRYRUN" == "true" ]]; then
        log "🧪 Dry-run: would run 'dnf5 upgrade --best --allowerasing'"
    else
        sudo dnf5 upgrade --best --allowerasing -y
    fi
}

main() {
    log "🛠️ Starting DNF5 recovery sequence..."

    # sudo dnf5 install dnf5-command

    preflight
    clean_cache
    rebuild_rpm_db
    verify_system
    sync_packages
    force_update
    log "✅ DNF5 recovery complete."
}

main "$@"

