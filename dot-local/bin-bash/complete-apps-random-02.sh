#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

LOGFILE="/var/log/power-tools-suite.log"
PKGS=(
    btop               # Modern resource monitor (better than htop)
    ncdu               # Disk usage analyzer (TUI)
    bat                # Cat clone with syntax highlighting
    fd-find            # Fast file search (better than `find`)
    ripgrep            # Fast grep alternative
    exa                # Modern `ls` replacement
    xclip              # Clipboard CLI tool
    xdotool            # Simulate keyboard/mouse input
    ranger             # Terminal file manager
    zoxide             # Smarter `cd` command
    fzf                # Fuzzy finder
    tldr               # Simplified man pages
    jq                 # JSON processor
    yq                 # YAML processor
    entr               # Run commands when files change
    shellcheck         # Static analysis for shell scripts
    asciinema          # Terminal session recorder
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

install_power_tools() {
    log "Installing power tools..."
    dnf install -y --skip-unavailable \
      "${PKGS[@]}" | tee -a "$LOGFILE"
    log "Power tools installed successfully."
}

main() {
    preflight
    install_power_tools
    log "Power tools suite installation complete. Your system is now supercharged."
}

main "$@"

