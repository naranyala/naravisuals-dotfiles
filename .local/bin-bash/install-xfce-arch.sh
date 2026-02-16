#!/usr/bin/env bash
# Arch Linux XFCE Complete Installation Toolkit
# Author: Fudzer + Copilot
# Purpose: Install full XFCE desktop with essentials, rollback, and logging

set -euo pipefail

LOGFILE="/var/log/xfce_install.log"
ROLLBACK_LIST="/tmp/xfce_installed_pkgs.txt"

# --- Utility functions ---
log() { echo "[+] $*" | tee -a "$LOGFILE"; }
err() { echo "[!] ERROR: $*" | tee -a "$LOGFILE" >&2; }
rollback() {
    if [[ -f "$ROLLBACK_LIST" ]]; then
        log "Rolling back installed packages..."
        sudo pacman -Rns --noconfirm $(cat "$ROLLBACK_LIST") || err "Rollback failed"
    else
        err "No rollback list found."
    fi
}

# --- Package sets ---
XFCE_CORE=(xfce4 xfce4-goodies)
DISPLAY_MANAGER=(lightdm lightdm-gtk-greeter)
ESSENTIALS=(
    network-manager-applet
    # pulseaudio
    pavucontrol
    thunar thunar-volman gvfs gvfs-smb
    ristretto mousepad
    firefox
    # arc-gtk-theme
    papirus-icon-theme
)

ALL_PACKAGES=("${XFCE_CORE[@]}" "${DISPLAY_MANAGER[@]}" "${ESSENTIALS[@]}")

# --- Install function ---
install_suite() {
    local suite=("$@")
    log "Installing XFCE complete suite: ${suite[*]}"
    for pkg in "${suite[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            log "Installing $pkg..."
            if sudo pacman -S --noconfirm "$pkg"; then
                echo "$pkg" >> "$ROLLBACK_LIST"
            else
                err "Failed to install $pkg"
                # rollback
                exit 1
            fi
        else
            log "$pkg already installed, skipping."
        fi
    done
    log "XFCE installation complete."
    log "Enabling LightDM..."
    sudo systemctl enable lightdm.service
}

# --- Main ---
case "${1:-}" in
    install|"")
        install_suite "${ALL_PACKAGES[@]}"
        ;;
    rollback)
        rollback
        ;;
    *)
        echo "Usage: $0 [install|rollback]"
        exit 1
        ;;
esac

