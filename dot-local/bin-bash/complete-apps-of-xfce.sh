#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

LOGFILE="/var/log/xfce-app-suite.log"
PKGS=(
    thunar
    xfce4-terminal
    ristretto
    mousepad
    xfce4-settings
    xfce4-taskmanager
    xfce4-power-manager
    xfce4-notifyd
    xfce4-screenshooter
    xfce4-panel
    xfce4-appfinder
    xfce4-session
    xfce4-dict
    xfce4-systemload-plugin
    xfce4-weather-plugin
    xfce-polkit
    xfce4-whiskermenu-plugin
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

install_xfce_apps() {
    log "Installing XFCE system apps..."
    dnf install -y --skip-unavailable \
      "${PKGS[@]}" | tee -a "$LOGFILE"

    log "XFCE apps installed successfully."
}

main() {
    preflight
    install_xfce_apps
    log "XFCE app suite installation complete. No desktop environment changes made."
}

main "$@"

