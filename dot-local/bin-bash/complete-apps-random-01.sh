#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

LOGFILE="/var/log/universal-app-suite.log"
PKGS=(
    htop              # System monitor
    neofetch          # System info display
    tmux              # Terminal multiplexer
    curl              # Data transfer tool
    wget              # File downloader
    git               # Version control
    flatpak           # Universal app installer
    gparted           # Partition editor (GTK but not DE-bound)
    vlc               # Media player
    mpv               # Lightweight media player
    filezilla         # FTP client
    qbittorrent       # Torrent client
    jq                # JSON cli-kit
    flameshot         # Screenshot tool
    # keepassxc         # Password manager
    # xournalpp         # PDF annotation and note-taking
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

install_universal_apps() {
    log "Installing universal apps..."
    dnf install -y --skip-unavailable \
      "${PKGS[@]}" | tee -a "$LOGFILE"
    log "Universal apps installed successfully."
}

main() {
    preflight
    install_universal_apps
    log "Universal app suite installation complete. No desktop environment dependencies required."
}

main "$@"

