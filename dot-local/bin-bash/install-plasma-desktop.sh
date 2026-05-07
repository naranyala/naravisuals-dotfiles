#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/kde_install.log"
DISTRO_CHECK=$(grep -Ei 'debian|buntu' /etc/os-release 2>/dev/null || true)
X11_PACKAGES="xserver-xorg xinit x11-xserver-utils"
KDE_PACKAGES="kde-plasma-desktop plasma-workspace kde-cli-tools systemsettings kde-config-gtk-style"
APP_PACKAGES="dolphin konsole kate plasma-nm plasma-pa pipewire kdeconnect policykit-1-gnome"
SDDM_PACKAGE="sddm"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE"
    exit 1
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Please run as root: sudo $0"
    fi
}

check_distro() {
    if [ -z "$DISTRO_CHECK" ]; then
        error "This script is designed for Debian-based systems."
    fi
}

check_internet() {
    log "Checking internet connectivity..."
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        error "No internet connection detected. Please check your network."
    fi
}

confirm_prompt() {
    read -p "Proceed with KDE Plasma installation? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Installation aborted by user."
        exit 0
    fi
}

check_package_installed() {
    local package="$1"
    dpkg -s "$package" >/dev/null 2>&1
}

install_packages() {
    local package_list="$1"
    local section_name="$2"
    log "[$section_name] Checking and installing packages..."
    local to_install=""
    for pkg in $package_list; do
        if ! check_package_installed "$pkg"; then
            to_install="$to_install $pkg"
        else
            log "  $pkg is already installed, skipping."
        fi
    done
    if [ -n "$to_install" ]; then
        if ! apt install -y --no-install-recommends $to_install >>"$LOG_FILE" 2>&1; then
            error "Failed to install packages: $to_install"
        fi
        log "  Installed: $to_install"
    else
        log "  No new packages to install."
    fi
}

main() {
    # Initialize log
    touch "$LOG_FILE" || error "Cannot create log file at $LOG_FILE"
    log "Starting KDE Plasma minimal installation..."

    # Pre-flight checks
    check_root
    check_distro
    check_internet
    confirm_prompt

    # Update system
    log "[1/5] Updating system..."
    if ! apt update >>"$LOG_FILE" 2>&1; then
        error "Failed to update package lists"
    fi
    if ! apt -y upgrade >>"$LOG_FILE" 2>&1; then
        error "Failed to upgrade system"
    fi

    # Install X11 components
    install_packages "$X11_PACKAGES" "2/5 Installing X11 components"

    # Install minimal KDE Plasma desktop
    install_packages "$KDE_PACKAGES" "3/5 Installing minimal KDE Plasma"

    # Install essential KDE apps
    install_packages "$APP_PACKAGES" "4/5 Installing essential KDE apps"

    # Install and enable SDDM
    log "[5/5] Installing and enabling SDDM..."
    if ! check_package_installed "$SDDM_PACKAGE"; then
        if ! apt install -y --no-install-recommends "$SDDM_PACKAGE" >>"$LOG_FILE" 2>&1; then
            error "Failed to install SDDM"
        fi
        if ! systemctl enable sddm >>"$LOG_FILE" 2>&1; then
            error "Failed to enable SDDM"
        fi
        log "  SDDM installed and enabled."
    else
        log "  SDDM is already installed, checking if enabled..."
        if ! systemctl is-enabled sddm >/dev/null 2>&1; then
            if ! systemctl enable sddm >>"$LOG_FILE" 2>&1; then
                error "Failed to enable SDDM"
            fi
            log "  SDDM enabled."
        else
            log "  SDDM is already enabled."
        fi
    fi

    # Final cleanup
    log "[✔] Cleaning up unused packages..."
    if ! apt autoremove -y >>"$LOG_FILE" 2>&1; then
        error "Failed to clean up unused packages"
    fi

    log "[✅] KDE Plasma minimal install complete."
    echo -e "${GREEN}KDE Plasma minimal install complete.${NC}"
    echo "Reboot or run 'startx' (if not using SDDM)."
}

# Execute main
main
