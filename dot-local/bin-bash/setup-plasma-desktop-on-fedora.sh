#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/kde_install.log"

# Package groups (Fedora-valid names)
WAYLAND_PACKAGES="xorg-x11-server-Xwayland qt5-qtwayland qt6-qtwayland"
KDE_PACKAGES="plasma-desktop plasma-workspace kde-cli-tools plasma-systemsettings kde-gtk-config"
APP_PACKAGES="dolphin konsole kate plasma-nm plasma-pa pipewire kdeconnect polkit-gnome"
SDDM_PACKAGE="sddm"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Helpers
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"; exit 1; }

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Please run as root: sudo $0"
    fi
}

check_internet() {
    log "Checking internet connectivity..."
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        error "No internet connection detected."
    fi
}

confirm_prompt() {
    read -p "Proceed with KDE Plasma Wayland installation? [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || { log "Installation aborted."; exit 0; }
}

check_package_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

check_package_available() {
    dnf list available "$1" >/dev/null 2>&1
}

install_packages() {
    local package_list="$1"
    local section_name="$2"
    log "[$section_name] Checking and installing packages..."
    local to_install=""
    for pkg in $package_list; do
        if check_package_available "$pkg"; then
            if ! check_package_installed "$pkg"; then
                to_install="$to_install $pkg"
            else
                log "  $pkg already installed."
            fi
        else
            log "  $pkg not found in repos, skipping."
        fi
    done
    if [ -n "$to_install" ]; then
        dnf install -y $to_install >>"$LOG_FILE" 2>&1 || error "Failed to install: $to_install"
        log "  Installed: $to_install"
    else
        log "  No new packages needed."
    fi
}

main() {
    touch "$LOG_FILE" || error "Cannot create log file at $LOG_FILE"
    log "Starting KDE Plasma Wayland installation..."

    check_root
    check_internet
    confirm_prompt

    log "[1/4] Updating system..."
    dnf -y update >>"$LOG_FILE" 2>&1 || error "Failed to update system"

    install_packages "$WAYLAND_PACKAGES" "2/4 Installing Wayland components"
    install_packages "$KDE_PACKAGES" "3/4 Installing KDE Plasma"
    install_packages "$APP_PACKAGES" "4/4 Installing KDE apps"

    log "Installing and enabling SDDM..."
    if ! check_package_installed "$SDDM_PACKAGE"; then
        dnf install -y "$SDDM_PACKAGE" >>"$LOG_FILE" 2>&1 || error "Failed to install SDDM"
        systemctl enable sddm >>"$LOG_FILE" 2>&1 || error "Failed to enable SDDM"
        log "  SDDM installed and enabled."
    else
        log "  SDDM already installed."
        systemctl is-enabled sddm >/dev/null 2>&1 || {
            systemctl enable sddm >>"$LOG_FILE" 2>&1 || error "Failed to enable SDDM"
            log "  SDDM enabled."
        }
    fi

    log "[✔] Cleaning up unused packages..."
    dnf autoremove -y >>"$LOG_FILE" 2>&1 || error "Failed to autoremove"

    log "[✅] KDE Plasma Wayland install complete."
    echo -e "${GREEN}KDE Plasma Wayland install complete.${NC}"
    echo "Reboot to start KDE Plasma (Wayland session)."
}

main

