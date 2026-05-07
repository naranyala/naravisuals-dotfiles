#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="./install_webkitgtk_deps.log"
DRY_RUN=false
VERBOSE=false

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"
}

run() {
    if $DRY_RUN; then
        log "[DRY-RUN] $*"
    else
        log "[EXEC] $*"
        eval "$@"
    fi
}

detect_distro() {
    if command -v apt &>/dev/null; then
        echo "debian"
    elif command -v dnf &>/dev/null; then
        echo "fedora"
    elif command -v pacman &>/dev/null; then
        echo "arch"
    else
        echo "unknown"
    fi
}

install_debian() {
    run "sudo apt update"
    run "sudo apt install -y libwebkit2gtk-4.1-dev libgtk-3-dev build-essential curl git"
}

install_fedora() {
    run "sudo dnf install -y webkit2gtk3-devel gtk3-devel gcc-c++ curl git"
}

install_arch() {
    run "sudo pacman -Sy --noconfirm webkit2gtk gtk3 base-devel curl git"
}

main() {
    log "Starting WebKitGTK dependency installation"
    DISTRO=$(detect_distro)
    log "Detected distro: $DISTRO"

    case "$DISTRO" in
        debian) install_debian ;;
        fedora) install_fedora ;;
        arch) install_arch ;;
        *)
            log "Unsupported distro. Please install dependencies manually."
            exit 1
            ;;
    esac

    log "Installation complete"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --verbose) VERBOSE=true ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

main

