#!/usr/bin/env bash
set -euo pipefail

LOGFILE="/var/log/webkit2gtk_debian_build.log"
SRC_DIR="$HOME/build/webkit2gtk-debian"

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

check_deps() {
    local deps=(apt dpkg-dev build-essential devscripts equivs)
    local missing=()
    log "🔍 Checking dependencies..."

    for dep in "${deps[@]}"; do
        if command -v "$dep" &>/dev/null; then
            log "✓ Found: $dep"
        else
            log "✗ Missing: $dep"
            missing+=("$dep")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        log "⚠️ Missing dependencies: ${missing[*]}"
        log "💡 Try: sudo apt install ${missing[*]}"
        exit 1
    fi
}

fetch_source() {
    mkdir -p "$SRC_DIR"
    cd "$SRC_DIR"
    log "📥 Fetching Debian source for webkit2gtk..."
    apt source libwebkit2gtk-4.1-dev
}

install_build_deps() {
    cd "$SRC_DIR"/webkit2gtk-*
    log "📦 Installing build dependencies..."
    sudo apt build-dep ./ -y
}

build_package() {
    cd "$SRC_DIR"/webkit2gtk-*
    log "🧱 Building Debian package..."
    dpkg-buildpackage -us -uc
}

install_package() {
    cd "$SRC_DIR"
    log "📦 Installing built packages..."
    sudo dpkg -i ./*.deb
}

main() {
    log "🚀 Starting Debian source build of WebKitGTK"
    # check_deps
    fetch_source
    install_build_deps
    build_package
    install_package
    log "✅ Debian source build and install complete"
}

main "$@"
