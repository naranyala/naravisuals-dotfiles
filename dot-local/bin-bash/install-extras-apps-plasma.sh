#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/kde_extras_install.log"
DISTRO_CHECK=$(grep -Ei 'debian|buntu|mint|pop' /etc/os-release 2>/dev/null || true)

# Expanded package lists
MULTIMEDIA_PACKAGES="dragonplayer kmix k3b elisa ffmpegthumbs audiocd-kio"
INTERNET_PACKAGES="firefox-esr falkon kget konversation ktorrent krdc krfb"
SYSTEM_PACKAGES="partitionmanager filelight kde-spectacle ksystemlog sweeper kfind krename"
OFFICE_PACKAGES="okular ark kcharselect kdegraphics-thumbnailers kaddressbook kmail kontact"
DEV_PACKAGES="kate kdiff3 lokalize plasma-sdk kompare cervisia"
PERSONAL_PACKAGES="korganizer kcalc ktimer knotes kjots"
THEMING_PACKAGES="plasma-workspace-wallpapers kde-config-gtk-style breeze-gtk"
UTILITIES_PACKAGES="plasma-disks plasma-nm plasma-pa plasma-thunderbolt print-manager"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}WARNING: $1${NC}" | tee -a "$LOG_FILE" >&2
}

success() {
    echo -e "${GREEN}$1${NC}" | tee -a "$LOG_FILE"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Please run as root: sudo $0"
    fi
}

check_distro() {
    if [ -z "$DISTRO_CHECK" ]; then
        warn "This script is designed for Debian-based systems. Continue at your own risk."
        read -p "Continue anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Installation aborted by user."
            exit 0
        fi
    fi
}

check_internet() {
    log "Checking internet connectivity..."
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && ! ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1; then
        error "No internet connection detected. Please check your network."
    fi
}

confirm_prompt() {
    echo -e "${YELLOW}"
    cat << "EOF"
  _  __ _____   ____              
 | |/ // ____| |  _ \             
 | ' /| (___   | |_) |_ __ ___    
 |  <  \___ \  |  _ <| '__/ _ \   
 | . \ ____) | | |_) | | | (_) |  
 |_|\_\_____/  |____/|_|  \___/   
                                  
EOF
    echo -e "${NC}"
    echo "The following KDE components will be installed:"
    echo -e "${BLUE}» Multimedia:${NC} $MULTIMEDIA_PACKAGES"
    echo -e "${BLUE}» Internet:${NC} $INTERNET_PACKAGES"
    echo -e "${BLUE}» System:${NC} $SYSTEM_PACKAGES"
    echo -e "${BLUE}» Office:${NC} $OFFICE_PACKAGES"
    echo -e "${BLUE}» Development:${NC} $DEV_PACKAGES"
    echo -e "${BLUE}» Personal:${NC} $PERSONAL_PACKAGES"
    echo -e "${BLUE}» Theming:${NC} $THEMING_PACKAGES"
    echo -e "${BLUE}» Utilities:${NC} $UTILITIES_PACKAGES"
    echo
    
    read -p "Proceed with KDE extras installation? [y/N]: " -n 1 -r
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
    local skipped=""
    
    for pkg in $package_list; do
        if ! check_package_installed "$pkg"; then
            to_install="$to_install $pkg"
        else
            skipped="$skipped $pkg"
        fi
    done
    
    if [ -n "$skipped" ]; then
        log "  Already installed:${GREEN}$skipped${NC}"
    fi
    
    if [ -n "$to_install" ]; then
        log "  Installing:${YELLOW}$to_install${NC}"
        if ! apt install -y --no-install-recommends $to_install >>"$LOG_FILE" 2>&1; then
            warn "Some packages failed to install. Continuing with others..."
        fi
    else
        log "  No new packages to install in this section."
    fi
}

install_backends() {
    log "[+] Installing recommended backends and codecs..."
    local backends="kde-config-gtk-style-preview gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav"
    if ! apt install -y $backends >>"$LOG_FILE" 2>&1; then
        warn "Failed to install some recommended backends"
    fi
}

clean_system() {
    log "[+] Cleaning up unused packages..."
    if ! apt autoremove -y >>"$LOG_FILE" 2>&1; then
        warn "Failed to clean up unused packages"
    fi
    
    log "[+] Updating desktop database and mime types..."
    update-desktop-database 2>/dev/null || true
    update-mime-database /usr/share/mime 2>/dev/null || true
}

main() {
    # Initialize log
    echo "KDE Plasma Extras Installation Log - $(date)" > "$LOG_FILE" || error "Cannot create log file at $LOG_FILE"
    log "Starting KDE extras installation..."
    
    # Pre-flight checks
    check_root
    check_distro
    check_internet
    confirm_prompt

    # Update package lists
    log "[1/9] Updating package lists..."
    if ! apt update >>"$LOG_FILE" 2>&1; then
        error "Failed to update package lists"
    fi

    # Install Multimedia Tools
    install_packages "$MULTIMEDIA_PACKAGES" "2/9 Installing Multimedia Tools"

    # Install Internet Tools
    install_packages "$INTERNET_PACKAGES" "3/9 Installing Internet/Communication Tools"

    # Install System Utilities
    install_packages "$SYSTEM_PACKAGES" "4/9 Installing System Utilities"

    # Install Office/Document Tools
    install_packages "$OFFICE_PACKAGES" "5/9 Installing Office/Document Tools"

    # Install Development Tools
    install_packages "$DEV_PACKAGES" "6/9 Installing Development/Admin Tools"

    # Install Personal Utilities
    install_packages "$PERSONAL_PACKAGES" "7/9 Installing Personal Utilities"
    
    # Install Theming Packages
    install_packages "$THEMING_PACKAGES" "8/9 Installing Theming Packages"
    
    # Install Plasma Utilities
    install_packages "$UTILITIES_PACKAGES" "9/9 Installing Plasma Utilities"
    
    # Install recommended backends
    install_backends
    
    # Final cleanup
    clean_system

    success "[✅] KDE Suite Extras installation completed successfully!"
    cat << "EOF"
 _____ _   _ _   _ __  __ _____  
|_   _| | | | \ | |  \/  | ____| 
  | | | | | |  \| | |\/| |  _|  
  | | | |_| | |\  | |  | | |___ 
  |_|  \___/|_| \_|_|  |_|_____|
                                 
EOF
    echo -e "${GREEN}KDE Plasma extras installed successfully!${NC}"
    echo -e "Detailed log available at ${YELLOW}$LOG_FILE${NC}"
}

# Execute main
main
