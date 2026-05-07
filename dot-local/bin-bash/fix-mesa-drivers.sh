#!/usr/bin/env bash
# fix-mesa.sh — Mesa driver repair utility for Fedora Linux

set -euo pipefail

LOGFILE="/var/log/fix-mesa.log"
DRYRUN="${DRYRUN:-false}"

log() {
    echo "[$(date +'%F %T')] $*" | tee -a "$LOGFILE"
}

preflight() {
    log "🔍 Preflight checks..."
    command -v glxinfo >/dev/null || { log "❌ glxinfo not found. Installing mesa-utils..."; sudo dnf install -y mesa-utils; }
    command -v lspci >/dev/null || { log "❌ lspci not found. Installing pciutils..."; sudo dnf install -y pciutils; }
}

inspect_mesa() {
    log "📋 Inspecting Mesa setup..."
    glxinfo | grep "OpenGL version" | tee -a "$LOGFILE"
    lspci | grep -E 'VGA|3D|Display' | tee -a "$LOGFILE"
    rpm -qa | grep mesa | tee -a "$LOGFILE"
}

remove_conflicts() {
    log "🧼 Removing conflicting mesa-freeworld packages..."
    local pkgs
    pkgs=$(dnf list installed | awk '/mesa-freeworld/ {print $1}')
    if [[ -n "$pkgs" ]]; then
        if [[ "$DRYRUN" == "true" ]]; then
            log "🧪 Dry-run: would remove $pkgs"
        else
            sudo dnf remove -y $pkgs
        fi
    else
        log "✅ No mesa-freeworld packages found."
    fi
}

reinstall_mesa() {
    log "🔄 Reinstalling core Mesa packages..."
    local core_pkgs=(
        mesa-dri-drivers
        mesa-libGL
        mesa-vulkan-drivers
        mesa-va-drivers
        mesa-vdpau-drivers
    )
    if [[ "$DRYRUN" == "true" ]]; then
        log "🧪 Dry-run: would reinstall ${core_pkgs[*]}"
    else
        sudo dnf reinstall -y "${core_pkgs[@]}"
    fi
}

enable_testing_repo() {
    log "🧪 Enabling updates-testing repo (optional)..."
    sudo dnf config-manager --set-enabled updates-testing
    sudo dnf upgrade --refresh
}

verify_drivers() {
    log "🔍 Verifying OpenGL and Vulkan drivers..."
    glxinfo | grep "OpenGL renderer" | tee -a "$LOGFILE"
    command -v vulkaninfo >/dev/null && vulkaninfo | grep "driver" | tee -a "$LOGFILE" || log "ℹ️ vulkaninfo not found."
}

main() {
    log "🚀 Starting Mesa repair process..."
    preflight
    inspect_mesa
    remove_conflicts
    reinstall_mesa
    verify_drivers
    log "✅ Mesa repair completed."
}

main "$@"

