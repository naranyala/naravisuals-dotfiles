#!/usr/bin/env bash

set -euo pipefail

### CONFIG ###
LOG_FILE="/tmp/setup-virtualbox.log"
EXT_PACK="virtualbox-ext-oracle"

### LOGGING ###
log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

### DETECT DISTRO BY PACKAGE MANAGER ###
detect_distro() {
    if command -v pacman &>/dev/null; then
        DISTRO="arch"
    elif command -v dnf &>/dev/null; then
        DISTRO="fedora"
    elif command -v apt &>/dev/null; then
        DISTRO="debian"
    elif command -v zypper &>/dev/null; then
        DISTRO="opensuse"
    else
        log "✗ Unsupported or unknown distro. No known package manager found."
        exit 1
    fi
}

### INSTALL VIRTUALBOX ###
install_virtualbox() {
    log "→ Installing VirtualBox..."

    case "$DISTRO" in
        arch)
            sudo pacman -Sy --noconfirm virtualbox virtualbox-guest-iso
            if uname -r | grep -q "lts"; then
                sudo pacman -Sy --noconfirm virtualbox-host-modules-lts
            else
                sudo pacman -Sy --noconfirm virtualbox-host-modules-arch
            fi
            ;;
        fedora)
            sudo dnf install -y @virtualization VirtualBox kernel-devel kernel-headers dkms
            sudo systemctl enable --now vboxdrv.service
            ;;
        debian)
            sudo apt update
            sudo apt install -y virtualbox virtualbox-dkms linux-headers-$(uname -r)
            ;;
        opensuse)
            sudo zypper refresh
            sudo zypper install -y virtualbox virtualbox-kmp-default
            ;;
    esac
}

### LOAD KERNEL MODULES ###
load_modules() {
    log "→ Loading VirtualBox kernel modules..."
    sudo modprobe vboxdrv || log "⚠️ Could not load vboxdrv. It may require a reboot or DKMS rebuild."
    sudo modprobe vboxnetflt || true
    sudo modprobe vboxnetadp || true
}

### ADD USER TO GROUP ###
add_user_to_group() {
    log "→ Adding user '$USER' to vboxusers group..."
    sudo gpasswd -a "$USER" vboxusers
}

### INSTALL EXTENSION PACK (OPTIONAL) ###
install_extension_pack() {
    if command -v yay &>/dev/null && [[ "$DISTRO" == "arch" ]]; then
        log "→ Installing Oracle Extension Pack via AUR..."
        yay -S --noconfirm "$EXT_PACK"
    else
        log "⚠️ Extension Pack installation skipped. Manual install may be required for non-Arch distros."
    fi
}

### MAIN ###
log "=== VirtualBox Setup Initiated ==="
detect_distro
install_virtualbox
load_modules
add_user_to_group
install_extension_pack
log "=== Setup Complete. Please reboot or re-login to apply changes. ==="

