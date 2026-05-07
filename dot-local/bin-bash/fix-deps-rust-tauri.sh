#!/usr/bin/env bash
#
# install_tauri_deps.sh
# Installs essential third-party libraries for Rust + Tauri development on Fedora.
# Supports both Tauri v1 (webkit2gtk3) and Tauri v2 (webkit2gtk4.1).
#
# Usage:
#   ./install_tauri_deps.sh [v1|v2]
#
# Example:
#   ./install_tauri_deps.sh v2

set -euo pipefail

# ===== CONFIG =====
TAURI_VERSION="${1:-v2}"   # default to v2 if not specified
LOG_FILE="/var/log/tauri_deps_install.log"

# ===== FUNCTIONS =====
log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "Please run as root (sudo)."
        exit 1
    fi
}

install_packages() {
    local pkgs=("$@")
    log "Installing packages: ${pkgs[*]}"
    dnf install -y --skip-unavailable \
      "${pkgs[@]}" | tee -a "$LOG_FILE"
}

# ===== MAIN =====
check_root
log "=== Starting Tauri dependency installation for $TAURI_VERSION ==="

# Base build tools
BASE_PKGS=(
    gcc-c++
    make
    rust cargo
    nodejs npm
    pkgconf-pkg-config
)

# Common runtime & dev libs
COMMON_LIBS=(
    libappindicator-gtk3-devel
    openssl-devel
    atk-devel
    gdk-pixbuf2-devel
    cairo-devel
    pango-devel
    harfbuzz-devel
    glib2-devel
    libjpeg-turbo-devel
    libpng-devel
    libwebp-devel
    libtiff-devel
    libX11-devel
    libXcomposite-devel
    libXcursor-devel
    libXdamage-devel
    libXext-devel
    libXfixes-devel
    libXi-devel
    libXrandr-devel
    libXScrnSaver-devel
    libXtst-devel
    mesa-libEGL-devel
    mesa-libGL-devel
    libepoxy-devel
    icu-devel
)

# WebKitGTK selection
if [[ "$TAURI_VERSION" == "v1" ]]; then
    WEBKIT_PKG="webkit2gtk3-devel"
elif [[ "$TAURI_VERSION" == "v2" ]]; then
    WEBKIT_PKG="webkit2gtk4.1-devel"
else
    log "Unknown Tauri version: $TAURI_VERSION"
    exit 1
fi

# Install all
install_packages "${BASE_PKGS[@]}" "${COMMON_LIBS[@]}" "$WEBKIT_PKG"

log "=== Installation complete for $TAURI_VERSION ==="
log "You can now build Tauri apps with Rust + Node.js on Fedora."

