#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

LOGFILE="/var/log/gnome-app-suite.log"
PKGS=(
    gnome-terminal
    nautilus
    gedit
    gnome-system-monitor
    gnome-calculator
    gnome-disk-utility
    gnome-font-viewer
    gnome-logs
    gnome-screenshot
    gnome-weather
    gnome-maps
    gnome-characters
    gnome-clocks
    gnome-tweaks
    gnome-software
    gnome-control-center
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

install_gnome_apps() {
    log "Installing GNOME system apps..."
    dnf install -y --skip-unavailable \
      "${PKGS[@]}" | tee -a "$LOGFILE"
    log "GNOME apps installed successfully."
}

main() {
    preflight
    install_gnome_apps
    log "GNOME app suite installation complete. No desktop environment changes made."
}

main "$@"

