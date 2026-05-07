#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$HOME/package-logs"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

log_packages() {
    local manager="$1"
    local cmd="$2"
    local logfile="$LOG_DIR/${manager}-${TIMESTAMP}.txt"

    echo "📦 Logging $manager packages..."
    if command -v "${cmd%% *}" &>/dev/null; then
        eval "$cmd" >"$logfile" 2>&1
        echo "✅ Saved to $logfile"
    else
        echo "⚠️ $manager not found, skipping."
    fi
}

# Core package managers
log_packages "apt" "apt list --installed"
log_packages "brew" "brew list --versions"
log_packages "snap" "snap list"
log_packages "flatpak" "flatpak list --app --columns=application,version"
log_packages "nix" "nix profile list"
log_packages "cargo" "cargo install --list"

echo -e "\n📁 All logs saved in: $LOG_DIR"
