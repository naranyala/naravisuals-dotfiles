#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/icewm_extras_install.log"
DISTRO_CHECK=$(grep -Ei 'debian|buntu|mint|pop|fedora|arch|slackware|void' /etc/os-release 2>/dev/null || true)

# IceWM Package Lists
CORE_COMPONENTS="icewm icewm-themes icewm-config"
LIGHTWEIGHT_APPS="pcmanfm viewnior feh lxterminal mtpaint galculator"
INTERNET_APPS="falkon transmission-cli sylpheed claws-mail"
MULTIMEDIA_APPS="mpv sxiv audacious"
UTILITIES_APPS="rox-filer geany leafpad mousepad xarchiver"
SYSTEM_TOOLS="htop lxtask xfce4-terminal roxterm"
MINIMAL_OFFICE="abiword gnumeric"
TERMINAL_APPS="tmux ranger mc w3m"
EXTRA_EXTRAS="tint2 conky nitrogen"

# Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper functions
log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}ERROR: $1${NC}" | tee -a "$LOG_FILE" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}WARNING: $1${NC}" | tee -a "$LOG_FILE" >&2
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Please run as root: sudo $0"
    fi
}

check_distro() {
    if [ -z "$DISTRO_CHECK" ]; then
        warn "This script targets Debian, Ubuntu, Fedora, Arch, and similar distros."
        read -p "Continue anyway? [y/N]: " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 0
    fi
}

detect_pkg_manager() {
    if command -v apt >/dev/null; then
        PKG_MANAGER="apt"
        INSTALL_CMD="apt install -y --no-install-recommends"
        UPDATE_CMD="apt update"
    elif command -v dnf >/dev/null; then
        PKG_MANAGER="dnf"
        INSTALL_CMD="dnf install -y --setopt=install_weak_deps=False"
        UPDATE_CMD="dnf update -y"
    elif command -v pacman >/dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="pacman -S --noconfirm --needed"
        UPDATE_CMD="pacman -Syu --noconfirm"
    elif command -v xbps-install >/dev/null; then
        PKG_MANAGER="xbps"
        INSTALL_CMD="xbps-install -y"
        UPDATE_CMD="xbps-install -Su"
    else
        error "Unsupported package manager"
    fi
    log "Detected package manager: $PKG_MANAGER"
}

show_intro() {
    clear
    echo -e "${GREEN}"
    cat << "EOF"
 _____ _____ _____ __    _____ 
|_   _|     |     |  |  |     |
  | | |  |  | | | |  |__|  |  |
  |_| |_____|_|_|_|_____|_____|
                               
EOF
    echo -e "${NC}"
    echo -e "This installer will set up IceWM with lightweight applications"
    echo -e "Designed for minimal resource usage and maximum efficiency"
    echo -e "${YELLOW}Warning: This focuses on terminal and lightweight GUI apps${NC}"
    echo
}

confirm_install() {
    echo -e "${BLUE}The following components will be installed:${NC}"
    echo -e " » ${GREEN}Core IceWM${NC}: $CORE_COMPONENTS"
    echo -e " » ${GREEN}Lightweight Apps${NC}: $LIGHTWEIGHT_APPS"
    echo -e " » ${GREEN}Internet${NC}: $INTERNET_APPS"
    echo -e " » ${GREEN}Multimedia${NC}: $MULTIMEDIA_APPS"
    echo -e " » ${GREEN}Utilities${NC}: $UTILITIES_APPS"
    echo -e " » ${GREEN}System Tools${NC}: $SYSTEM_TOOLS"
    echo -e " » ${GREEN}Office${NC}: $MINIMAL_OFFICE"
    echo -e " » ${GREEN}Terminal Apps${NC}: $TERMINAL_APPS"
    echo -e " » ${GREEN}Extras${NC}: $EXTRA_EXTRAS"
    echo
    read -p "Proceed with installation? [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 0
}

install_group() {
    local title="$1"
    local packages="$2"
    log "Installing $title..."
    for pkg in $packages; do
        if ! $INSTALL_CMD "$pkg" >> "$LOG_FILE" 2>&1; then
            warn "Failed to install $pkg - skipping"
        else
            echo -e "${GREEN}✔${NC} $pkg"
        fi
    done
}

setup_icewm() {
    log "Configuring IceWM..."
    # Create basic IceWM config if none exists
    if [ ! -d ~/.icewm ]; then
        mkdir -p ~/.icewm
        cp /usr/share/icewm/* ~/.icewm/ 2>/dev/null || true
    fi
    
    # Create simple menu if none exists
    if [ ! -f ~/.icewm/menu ]; then
        cat > ~/.icewm/menu << 'EOF'
prog "Terminal" utilities-terminal lxterminal
prog "File Manager" system-file-manager pcmanfm
prog "Web Browser" web-browser falkon
prog "Text Editor" accessories-text-editor leafpad
separator
prog "HTOP Monitor" system-monitor htop
prog "Task Manager" utilities-system-monitor lxtask
separator
menu "Multimedia" folder
prog "MPV Player" multimedia-video-player mpv
prog "Audacious" multimedia-audio-player audacious
prog "Image Viewer" multimedia-image-viewer sxiv
endmenu
menu "Office" folder
prog "AbiWord" office-word-processor abiword
prog "Gnumeric" office-spreadsheet gnumeric
endmenu
separator
menu "IceWM" folder
restart "Restart IceWM"
reload "Reload IceWM"
exit "Exit IceWM"
command "XTerm" "xterm"
command "UXTerm" "uxterm"
endmenu
EOF
    fi
    
    log "IceWM configuration complete"
}

main() {
    # Setup
    echo "IceWM Installer Log - $(date)" > "$LOG_FILE"
    check_root
    show_intro
    check_distro
    detect_pkg_manager
    confirm_install
    
    # Update system
    log "Updating package database..."
    $UPDATE_CMD >> "$LOG_FILE" 2>&1 || warn "Failed to update packages"
    
    # Installation
    install_group "Core IceWM Components" "$CORE_COMPONENTS"
    install_group "Lightweight Applications" "$LIGHTWEIGHT_APPS"
    install_group "Internet Applications" "$INTERNET_APPS"
    install_group "Multimedia Applications" "$MULTIMEDIA_APPS"
    install_group "System Utilities" "$UTILITIES_APPS"
    install_group "System Monitoring Tools" "$SYSTEM_TOOLS"
    install_group "Office Applications" "$MINIMAL_OFFICE"
    install_group "Terminal Applications" "$TERMINAL_APPS"
    install_group "Extra Components" "$EXTRA_EXTRAS"
    
    # Post-install
    setup_icewm
    
    # Completion
    echo -e "${GREEN}"
    cat << "EOF"
 _____ _____ _____ _____ 
|     |  |  |   __| __  |
| | | |  |  |   __|    -|
|_|_|_|_____|_____|__|__|
                         
EOF
    echo -e "${NC}"
    echo -e "IceWM installation complete!"
    echo -e "Some next steps:"
    echo -e " • Edit ${YELLOW}~/.icewm/menu${NC} to customize your application launcher"
    echo -e " • Check ${YELLOW}~/.icewm/keys${NC} to configure keyboard shortcuts"
    echo -e " • Use ${YELLOW}feh${NC} or ${YELLOW}nitrogen${NC} to set your wallpaper"
    echo -e " • Run ${YELLOW}icewmctrl -r${NC} to reload IceWM configuration"
    echo -e "\nLog file: ${YELLOW}$LOG_FILE${NC}"
}

main
