#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/labwc_install.log"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/labwc"

# Package Lists - Wayland-native focused
CORE_COMPONENTS="labwc wlroots wayland-protocols xwayland"
ESSENTIAL_APPS="foot swaybg grim slurp wofi bemenu-wayland"
FILE_MANAGEMENT="nemo gvfs udisks2"  # Nemo has native Wayland support
INTERNET_APPS="firefox-wayland qutebrowser"
MULTIMEDIA="mpv imv swaylock-effects"
UTILITIES="swayidle waybar mako-notifier wl-clipboard"
DEV_TOOLS="neovim helix alacritty"  # Terminal that supports Wayland
OFFICE="onlyoffice-desktopeditors"  # Has Wayland support
EXTRA_APPS="swaync kanshi wdisplays"

# Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper Functions
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

check_wayland() {
    if [ -z "$WAYLAND_DISPLAY" ] && [ ! -f /usr/bin/sway ]; then
        warn "Wayland doesn't appear to be available. LabWC is a Wayland compositor."
        read -p "Continue installation anyway? [y/N]: " -n 1 -r
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
    elif command -v zypper >/dev/null; then
        PKG_MANAGER="zypper"
        INSTALL_CMD="zypper install -y --no-recommends"
        UPDATE_CMD="zypper refresh"
    else
        error "Unsupported package manager"
    fi
    log "Detected package manager: $PKG_MANAGER"
}

show_banner() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
     _                    ____      ____  
    | |    __ _ _ __ ___ |___ \    / ___| 
    | |   / _` | '_ ` _ \  __) |___\___ \ 
    | |__| (_| | | | | | |/ __/_____|__) |
    |_____\__,_|_| |_| |_|_____|   |____/ 
                                           
EOF
    echo -e "${NC}"
    echo -e "LabWC Wayland Compositor Application Installer"
    echo -e "Focusing on native Wayland applications for optimal performance"
    echo -e "${YELLOW}Note: This will install a minimal Wayland desktop environment${NC}"
    echo
}

confirm_installation() {
    echo -e "${BLUE}The following components will be installed:${NC}"
    echo -e " » ${GREEN}Core LabWC${NC}: $CORE_COMPONENTS"
    echo -e " » ${GREEN}Essentials${NC}: $ESSENTIAL_APPS"
    echo -e " » ${GREEN}File Management${NC}: $FILE_MANAGEMENT"
    echo -e " » ${GREEN}Internet${NC}: $INTERNET_APPS"
    echo -e " » ${GREEN}Multimedia${NC}: $MULTIMEDIA"
    echo -e " » ${GREEN}Utilities${NC}: $UTILITIES"
    echo -e " » ${GREEN}Development${NC}: $DEV_TOOLS"
    echo -e " » ${GREEN}Office${NC}: $OFFICE"
    echo -e " » ${GREEN}Extras${NC}: $EXTRA_APPS"
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

setup_labwc_config() {
    log "Setting up LabWC configuration..."
    mkdir -p "$CONFIG_DIR" "$CONFIG_DIR/themes" "$CONFIG_DIR/menu"

    # Create basic config if none exists
    if [ ! -f "$CONFIG_DIR/rc.xml" ]; then
        cat > "$CONFIG_DIR/rc.xml" << 'EOF'
<labwc_config>
    <core>
        <gap>10</gap>
        <theme>default</theme>
    </core>
    <keyboard>
        <keybind key="A-Return">
            <action name="Execute">
                <command>foot</command>
            </action>
        </keybind>
        <keybind key="A-d">
            <action name="Execute">
                <command>wofi --show drun</command>
            </action>
        </keybind>
    </keyboard>
</labwc_config>
EOF
    fi

    # Create simple menu
    if [ ! -f "$CONFIG_DIR/menu.xml" ]; then
        cat > "$CONFIG_DIR/menu.xml" << 'EOF'
<openbox_menu>
    <menu id="root-menu" label="Applications">
        <item label="Terminal">
            <action name="Execute">
                <command>foot</command>
            </action>
        </item>
        <item label="File Manager">
            <action name="Execute">
                <command>nemo</command>
            </action>
        </item>
        <separator/>
        <menu id="internet-menu" label="Internet"/>
        <menu id="office-menu" label="Office"/>
        <separator/>
        <item label="Exit">
            <action name="Exit"/>
        </item>
    </menu>
</openbox_menu>
EOF
    fi

    log "LabWC configuration created at $CONFIG_DIR"
}

main() {
    # Setup
    echo "LabWC Installer Log - $(date)" > "$LOG_FILE"
    show_banner
    check_wayland
    detect_pkg_manager
    confirm_installation

    # Update system
    log "Updating package database..."
    $UPDATE_CMD >> "$LOG_FILE" 2>&1 || warn "Failed to update packages"

    # Installation
    install_group "Core Components" "$CORE_COMPONENTS"
    install_group "Essential Applications" "$ESSENTIAL_APPS"
    install_group "File Management" "$FILE_MANAGEMENT"
    install_group "Internet Applications" "$INTERNET_APPS"
    install_group "Multimedia Applications" "$MULTIMEDIA"
    install_group "System Utilities" "$UTILITIES"
    install_group "Development Tools" "$DEV_TOOLS"
    install_group "Office Applications" "$OFFICE"
    install_group "Extra Components" "$EXTRA_APPS"

    # Post-install
    setup_labwc_config

    # Completion
    echo -e "${GREEN}"
    cat << "EOF"
     _         _   _ ____      ____  
    | |    ___| | | |___ \    / ___| 
    | |   / __| | | | __) |___\___ \ 
    | |__| (__| |_| |/ __/_____|__) |
    |_____\___|\___/|_____|   |____/ 
                                     
EOF
    echo -e "${NC}"
    echo -e "LabWC installation complete!"
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo -e " • Start LabWC by running: ${GREEN}labwc${NC}"
    echo -e " • Configure your environment in: ${GREEN}$CONFIG_DIR/${NC}"
    echo -e " • Customize Waybar: ${GREEN}~/.config/waybar/config${NC}"
    echo -e " • Set wallpaper with: ${GREEN}swaybg -i /path/to/wallpaper.jpg${NC}"
    echo -e "\nLog file: ${YELLOW}$LOG_FILE${NC}"
}

main
