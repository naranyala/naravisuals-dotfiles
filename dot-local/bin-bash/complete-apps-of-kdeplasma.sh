#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

LOGFILE="/var/log/kde-app-suite.log"
PKGS=(
    dolphin
    konsole
    kate
    gwenview
    okular
    kcalc
    ark
    ksystemlog
    kcharselect
    kfind
    spectacle
    plasma-systemmonitor
    plasma-discover
    kdeconnect
    kdenlive
    yakuake
)

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

preflight() {
    log "Running preflight checks..."
    if [[ $EUID -ne 0 ]]; then
        log "Error: Run as root."
        exit 1
    fi
    if ! command -v dnf &>/dev/null; then
        log "Error: DNF not found. This script is for Fedora."
        exit 1
    fi
    log "Preflight checks passed."
}

install_kde_apps() {
    log "Installing KDE Plasma system apps..."
    dnf install -y --skip-unavailable \
      "${PKGS[@]}" | tee -a "$LOGFILE"
    log "KDE apps installed successfully."
}

main() {
    preflight
    install_kde_apps
    log "KDE app suite installation complete. No desktop environment changes made."
}

main "$@"

