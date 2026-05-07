#!/usr/bin/env bash
#
# geany-installer.sh — Cross-distro Geany installer with dark color schemes
# Author: Fudzer & Copilot
# License: MIT
#
# Features:
# - Detects package manager (APT, DNF, YUM, Zypper, Pacman)
# - Installs Geany
# - Downloads & installs dark color schemes
# - Logs all actions for audit
# - Safe exit on errors

set -euo pipefail

LOGFILE="$HOME/geany_install.log"
SCHEME_DIR="$HOME/.config/geany/colorschemes"
SCHEME_REPO="https://github.com/geany/geany-themes.git"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

error_exit() {
    log "ERROR: $*"
    exit 1
}

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_INSTALL="sudo apt-get install -y"
        PKG_UPDATE="sudo apt-get update"
    elif command -v dnf &>/dev/null; then
        PKG_INSTALL="sudo dnf install -y"
        PKG_UPDATE="sudo dnf check-update || true"
    elif command -v yum &>/dev/null; then
        PKG_INSTALL="sudo yum install -y"
        PKG_UPDATE="sudo yum check-update || true"
    elif command -v zypper &>/dev/null; then
        PKG_INSTALL="sudo zypper install -y"
        PKG_UPDATE="sudo zypper refresh"
    elif command -v pacman &>/dev/null; then
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_UPDATE="sudo pacman -Sy"
    else
        error_exit "No supported package manager found."
    fi
}

install_geany() {
    log "Updating package lists..."
    eval "$PKG_UPDATE"
    log "Installing Geany..."
    eval "$PKG_INSTALL geany git"
}

install_color_schemes() {
    log "Installing Geany color schemes..."
    mkdir -p "$SCHEME_DIR"
    TMP_DIR=$(mktemp -d)
    git clone --depth=1 "$SCHEME_REPO" "$TMP_DIR"

    # The repo stores schemes in 'colorschemes' subfolder
    if [ -d "$TMP_DIR/colorschemes" ]; then
        cp -v "$TMP_DIR/colorschemes"/*.conf "$SCHEME_DIR" | tee -a "$LOGFILE"
    else
        # Fallback: search for any .conf files
        find "$TMP_DIR" -type f -name "*.conf" -exec cp -v {} "$SCHEME_DIR" \; | tee -a "$LOGFILE"
    fi

    rm -rf "$TMP_DIR"
    log "Color schemes installed to $SCHEME_DIR"
}


main() {
    log "=== Geany Installer Started ==="
    detect_pkg_manager
    install_geany
    install_color_schemes
    log "Installation complete. Launch Geany and select your dark theme via: View → Change Color Scheme."
    log "=== Geany Installer Finished ==="
}

main "$@"

