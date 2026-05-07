#!/bin/bash
# Switch Fedora Linux to full KDE Plasma environment with enriched apps

set -euo pipefail

log() {
    echo -e "\033[1;32m[INFO]\033[0m $*"
}

error_exit() {
    echo -e "\033[1;31m[ERROR]\033[0m $*" >&2
    exit 1
}

install_packages() {
    local pkgs=("$@")
    log "Installing: ${pkgs[*]}"
    if ! sudo dnf install -y --skip-unavailable "${pkgs[@]}"; then
        error_exit "Failed to install packages: ${pkgs[*]}"
    fi
}

log "Updating system..."
if ! sudo dnf upgrade --refresh -y --skip-unavailable; then
    error_exit "System update failed"
fi

log "Installing KDE Plasma core packages..."
install_packages plasma-desktop plasma-workspace plasma-workspace-wayland \
    kde-settings sddm sddm-breeze

log "Installing enriched KDE applications..."
install_packages \
    # Core utilities
    konsole dolphin kate okular gwenview kcalc ark spectacle \
    # Multimedia
    kdenlive krita dragon-player juk kmix \
    # Office/productivity
    calligra calligra-plan calligra-sheets calligra-words \
    # Internet
    kget kmail kmail-account-wizard akregator konversation \
    # Graphics & design
    kolourpaint kcolorchooser kgraphviewer \
    # System tools
    ksystemlog kdiskfree kdf kcron ksystemsettings \
    # Education/science
    kalzium kstars marble \
    # Games (optional fun set)
    kpat kmines ksudoku kmahjongg

log "Configuring SDDM as default display manager..."
if sudo systemctl disable gdm 2>/dev/null; then
    log "Disabled GDM"
fi
sudo systemctl enable sddm || error_exit "Failed to enable SDDM"
sudo systemctl set-default graphical.target || error_exit "Failed to set graphical.target"

log "Setup complete! Reboot to start KDE Plasma."

