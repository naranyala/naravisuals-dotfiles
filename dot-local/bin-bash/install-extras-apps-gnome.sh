#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/gnome_extras_install.log"
DISTRO_CHECK=$(grep -Ei 'debian|buntu|mint|pop|fedora|arch' /etc/os-release 2>/dev/null || true)

# GNOME Package Lists
# CORE_APPS="gnome-shell gnome-shell-extensions gnome-shell-extension-manager gnome-tweaks gnome-control-center"
CORE_APPS=""
MULTIMEDIA_APPS="totem rhythmbox cheese eog gnome-sound-recorder gnome-video-effects"
INTERNET_APPS="epiphany evolution geary transmission-gtk remmina"
PRODUCTIVITY_APPS="gnome-calendar gnome-calculator gnome-characters gnome-maps gnome-weather"
UTILITIES_APPS="baobab gnome-disk-utility gnome-font-viewer gnome-logs gnome-system-monitor seahorse"
DEV_TOOLS="gedit devhelp builder"
OFFICE_APPS="evince simple-scan"
THEMING="gnome-backgrounds adwaita-icon-theme-full yaru-theme-gnome-shell"
EXTRA_EXTRAS="dconf-editor gnome-screenshot gnome-terminal file-roller"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
        warn "This script is designed for Debian-based and Fedora/Arch systems. Continue at your own risk."
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

detect_pkg_manager() {
    if command -v apt >/dev/null 2>&1; then
        PKG_MANAGER="apt"
        INSTALL_CMD="apt install -y"
        UPDATE_CMD="apt update"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="dnf install -y"
        UPDATE_CMD="dnf update -y"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="pacman -S --noconfirm"
        UPDATE_CMD="pacman -Syu --noconfirm"
    else
        error "Could not detect package manager (tried apt, dnf, pacman)"
    fi
    log "Detected package manager: $PKG_MANAGER"
}

confirm_prompt() {
    echo -e "${PURPLE}"
    cat << "EOF"
   ____ _   ___   ___  ___  _____ 
  / ___| \ | \ \ / / |/ _ \| ____|
 | |  _|  \| |\ V /| | | | |  _|  
 | |_| | |\  | | | | | |_| | |___ 
  \____|_| \_| |_| |_|\___/|_____|
                                  
EOF
    echo -e "${NC}"
    echo "The following GNOME components will be installed:"
    echo -e "${BLUE}» Core:${NC} $CORE_APPS"
    echo -e "${BLUE}» Multimedia:${NC} $MULTIMEDIA_APPS"
    echo -e "${BLUE}» Internet:${NC} $INTERNET_APPS"
    echo -e "${BLUE}» Productivity:${NC} $PRODUCTIVITY_APPS"
    echo -e "${BLUE}» Utilities:${NC} $UTILITIES_APPS"
    echo -e "${BLUE}» Development:${NC} $DEV_TOOLS"
    echo -e "${BLUE}» Office:${NC} $OFFICE_APPS"
    echo -e "${BLUE}» Theming:${NC} $THEMING"
    echo -e "${BLUE}» Extras:${NC} $EXTRA_EXTRAS"
    echo
    
    read -p "Proceed with GNOME extras installation? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Installation aborted by user."
        exit 0
    fi
}

check_package_installed() {
    local package="$1"
    case $PKG_MANAGER in
        apt) dpkg -s "$package" >/dev/null 2>&1 ;;
        dnf) rpm -q "$package" >/dev/null 2>&1 ;;
        pacman) pacman -Qi "$package" >/dev/null 2>&1 ;;
    esac
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
        if ! $INSTALL_CMD $to_install >>"$LOG_FILE" 2>&1; then
            warn "Some packages failed to install. Continuing with others..."
        fi
    else
        log "  No new packages to install in this section."
    fi
}

install_codecs() {
    log "[+] Installing recommended codecs and plugins..."
    case $PKG_MANAGER in
        apt)
            local codecs="gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav"
            ;;
        dnf)
            local codecs="gstreamer1-plugins-good gstreamer1-plugins-bad-free gstreamer1-plugins-ugly-free gstreamer1-libav"
            ;;
        pacman)
            local codecs="gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav"
            ;;
    esac
    
    if ! $INSTALL_CMD $codecs >>"$LOG_FILE" 2>&1; then
        warn "Failed to install some recommended codecs"
    fi
}

clean_system() {
    log "[+] Cleaning up..."
    case $PKG_MANAGER in
        apt) apt autoremove -y >>"$LOG_FILE" 2>&1 || warn "Failed to autoremove packages" ;;
        dnf) dnf autoremove -y >>"$LOG_FILE" 2>&1 || warn "Failed to autoremove packages" ;;
        pacman) pacman -Qdtq | pacman -Rs - >>"$LOG_FILE" 2>&1 || warn "Failed to remove orphans" ;;
    esac
    
    log "[+] Updating desktop database and mime types..."
    update-desktop-database 2>/dev/null || true
    update-mime-database /usr/share/mime 2>/dev/null || true
}

main() {
    # Initialize log
    echo "GNOME Extras Installation Log - $(date)" > "$LOG_FILE" || error "Cannot create log file at $LOG_FILE"
    log "Starting GNOME extras installation..."
    
    # Pre-flight checks
    check_root
    check_distro
    detect_pkg_manager
    check_internet
    confirm_prompt

    # Update system
    log "[1/10] Updating system packages..."
    if ! $UPDATE_CMD >>"$LOG_FILE" 2>&1; then
        error "Failed to update package lists"
    fi

    # Install Core GNOME Apps
    install_packages "$CORE_APPS" "2/10 Installing Core GNOME Components"

    # Install Multimedia Apps
    install_packages "$MULTIMEDIA_APPS" "3/10 Installing Multimedia Applications"

    # Install Internet Apps
    install_packages "$INTERNET_APPS" "4/10 Installing Internet Applications"

    # Install Productivity Apps
    install_packages "$PRODUCTIVITY_APPS" "5/10 Installing Productivity Tools"

    # Install Utilities
    install_packages "$UTILITIES_APPS" "6/10 Installing System Utilities"

    # Install Development Tools
    install_packages "$DEV_TOOLS" "7/10 Installing Development Tools"
    
    # Install Office Apps
    install_packages "$OFFICE_APPS" "8/10 Installing Office Applications"
    
    # Install Theming
    install_packages "$THEMING" "9/10 Installing Themes and Appearance"
    
    # Install Extras
    install_packages "$EXTRA_EXTRAS" "10/10 Installing Extra Components"
    
    # Install recommended codecs
    install_codecs
    
    # Final cleanup
    clean_system

    success "[✅] GNOME Extras installation completed successfully!"
    cat << "EOF"
   _____ _   _ ____  _____ _   _  _____ 
  / ____| \ | |  _ \| ____| \ | |/ ___|
 | |  __|  \| | | | |  _| |  \| | |  _ 
 | | |_ | |\  | |_| | |___| |\  | |_| |
  \_____|_| \_|____/|_____|_| \_|\____|
                                       
EOF
    echo -e "${GREEN}GNOME extras installed successfully!${NC}"
    echo -e "\nSome suggestions to enhance your GNOME experience:"
    echo -e " • Run ${YELLOW}gnome-tweaks${NC} to customize your desktop"
    echo -e " • Visit ${YELLOW}https://extensions.gnome.org/${NC} for more shell extensions"
    echo -e " • Use ${YELLOW}gnome-shell-extension-manager${NC} to manage extensions"
    echo -e "\nDetailed log available at ${YELLOW}$LOG_FILE${NC}"
}

# Execute main
main
