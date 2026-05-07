#!/usr/bin/env bash

set -euo pipefail

### CONFIG ###
PKGS=(
    libxcrypt-compat
    libcurl
    libcurl-devel
    mesa-libGLU
    ffmpeg
    gstreamer1
    gstreamer1-plugins-base
    gstreamer1-plugins-good
    gstreamer1-plugins-bad-free
    gstreamer1-plugins-bad-freeworld
    gstreamer1-plugins-ugly
    gstreamer1-libav
    x264
    x265
    lame
    libvpx
    libtheora
    libvorbis
    libogg
    libwebp
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
)

### LOGGING ###
log() {
    echo "[$(date '+%F %T')] $*" 
}

### CHECK DNF ###
check_dnf() {
    if ! command -v dnf &>/dev/null; then
        log "ERROR: dnf not found. This script is for Fedora-based systems."
        exit 1
    fi
}

### INSTALL PACKAGES ###
install_pkgs() {
    log "Starting multimedia package installation..."
    for pkg in "${PKGS[@]}"; do
        if dnf list installed "$pkg" &>/dev/null; then
            log "✓ $pkg already installed. Skipping."
        else
            log "→ Installing $pkg..."
            sudo dnf install -y "$pkg" &>> "$LOG_FILE" || log "⚠️ Failed to install $pkg"
        fi
    done
    log "Multimedia package installation complete."
}

### MAIN ###
log "=== Multimedia Installer Initiated ==="
check_dnf
install_pkgs
log "=== Multimedia Installer Completed ==="

