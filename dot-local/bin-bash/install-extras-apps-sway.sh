#!/bin/bash
set -e

# Constants
LOG_FILE="/var/log/sway_i3_install.log"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

# Package Lists
CORE_SWAY="sway swaybg swayidle swaylock swaync waybar wofi"
CORE_I3="i3 i3blocks i3lock i3status dmenu"
# ESSENTIALS="foot alacritty kitty"  # Foot for Wayland, others as fallback
ESSENTIALS="alacritty kitty"  # Foot for Wayland, others as fallback
FILE_MANAGERS="pcmanfm nautilus thunar"
BROWSERS="firefox qutebrowser"
TERMINAL_APPS="tmux ranger fzf bat exa zsh"
MEDIA="mpv imv swayimg feh"
UTILITIES="rofi mako grim slurp wl-clipboard xclip"
DEVELOPMENT="neovim helix git vscode codium"
OFFICE="onlyoffice-desktopeditors"
SYSTEM="htop btop nm-connection-editor blueman"
EXTRA="kanshi wdisplays nwg-displays autorandr"

# Colors
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Please run as root: sudo $0"
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
    else
        error "Unsupported package manager"
    fi
    log "Detected package manager: $PKG_MANAGER"
}

show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
  ____                  ____ ___ 
 / ___|_      _____ _ _|_  /_ _|
 \___ \ \ /\ / / _ \ '__|/ / | | 
  ___) \ V  V /  __/ |  / /| | | 
 |____/ \_/\_/ \___|_| /___|___|
                                 
EOF
    echo -e "${NC}"
    echo -e "Sway/i3 Window Manager Application Installer"
    echo -e "Provides both Wayland (sway) and X11 (i3) environments"
    echo -e "${YELLOW}Note: This will install a keyboard-focused tiling environment${NC}"
    echo
}

select_wm() {
    echo -e "${BLUE}Select window manager to configure:${NC}"
    echo "1) Sway (Wayland)"
    echo "2) i3 (X11)"
    echo "3) Both"
    echo -n "Your choice [1-3]: "
    read -r choice
    
    case $choice in
        1) WM="sway"; INSTALL_I3=false ;;
        2) WM="i3"; INSTALL_SWAY=false ;;
        3) WM="both"; INSTALL_I3=true; INSTALL_SWAY=true ;;
        *) error "Invalid selection" ;;
    esac
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

setup_config() {
    local wm=$1
    log "Setting up $wm configuration..."
    
    mkdir -p "$CONFIG_DIR/$wm"
    
    # Sway specific setup
    if [ "$wm" = "sway" ]; then
        if [ ! -f "$CONFIG_DIR/sway/config" ]; then
            cat > "$CONFIG_DIR/sway/config" << 'EOF'
# Default Sway config
set $mod Mod4

# Keybindings
bindsym $mod+Return exec foot
bindsym $mod+d exec wofi --show drun
bindsym $mod+Shift+q kill

# Layout
workspace_layout tabbed
default_border pixel 2
gaps inner 10

# Output configuration
output * bg ~/wallpaper.jpg fill

# Input configuration
input * {
    xkb_layout us
    tap enabled
    natural_scroll enabled
}

# Status bar
bar {
    position top
    status_command waybar
}
EOF
        fi
        
        # Waybar setup
        if [ ! -d "$CONFIG_DIR/waybar" ]; then
            mkdir -p "$CONFIG_DIR/waybar"
            cat > "$CONFIG_DIR/waybar/config" << 'EOF'
{
    "layer": "top",
    "position": "top",
    "modules-left": ["sway/workspaces", "sway/mode"],
    "modules-center": ["sway/window"],
    "modules-right": ["network", "cpu", "memory", "temperature", "battery", "clock", "tray"],
    "clock": {
        "format": "{:%H:%M}"
    }
}
EOF
            cat > "$CONFIG_DIR/waybar/style.css" << 'EOF'
* {
    border: none;
    font-family: sans-serif;
    font-size: 12px;
    min-height: 0;
}
EOF
        fi
    
    # i3 specific setup
    elif [ "$wm" = "i3" ]; then
        if [ ! -f "$CONFIG_DIR/i3/config" ]; then
            cat > "$CONFIG_DIR/i3/config" << 'EOF'
# Default i3 config
set $mod Mod1

# Keybindings
bindsym $mod+Return exec alacritty
bindsym $mod+d exec dmenu_run
bindsym $mod+Shift+q kill

# Layout
workspace_layout tabbed
default_border pixel 2
gaps inner 10

# Status bar
bar {
    status_command i3status
}
EOF
        fi
        
        if [ ! -f "$CONFIG_DIR/i3status/config" ]; then
            mkdir -p "$CONFIG_DIR/i3status"
            cat > "$CONFIG_DIR/i3status/config" << 'EOF'
general {
    colors = true
    interval = 5
}

order += "ipv6"
order += "disk /"
order += "memory"
order += "load"
order += "tztime local"
EOF
        fi
    fi
}

main() {
    # Setup
    echo "Sway/i3 Installer Log - $(date)" > "$LOG_FILE"
    check_root
    show_banner
    detect_pkg_manager
    select_wm

    # Update system
    log "Updating package database..."
    $UPDATE_CMD >> "$LOG_FILE" 2>&1 || warn "Failed to update packages"

    # Installation
    if [ "$INSTALL_SWAY" = true ]; then
        install_group "Sway Core" "$CORE_SWAY"
    fi
    
    if [ "$INSTALL_I3" = true ]; then
        install_group "i3 Core" "$CORE_I3"
    fi
    
    install_group "Essential Apps" "$ESSENTIALS"
    install_group "File Managers" "$FILE_MANAGERS"
    install_group "Web Browsers" "$BROWSERS"
    install_group "Terminal Apps" "$TERMINAL_APPS"
    install_group "Media Apps" "$MEDIA"
    install_group "Utilities" "$UTILITIES"
    install_group "Development Tools" "$DEVELOPMENT"
    install_group "Office Suite" "$OFFICE"
    install_group "System Tools" "$SYSTEM"
    install_group "Extra Components" "$EXTRA"

    # Configuration
    if [ "$INSTALL_SWAY" = true ]; then
        setup_config "sway"
    fi
    
    if [ "$INSTALL_I3" = true ]; then
        setup_config "i3"
    fi

    # Completion
    echo -e "${GREEN}"
    cat << "EOF"
  ____                  _   _ ____ ___ 
 / ___| _   _ _ __ ___ | | | |_  /_ _|
 \___ \| | | | '_ ` _ \| | | |/ / | | 
  ___) | |_| | | | | | | |_| / /| | | 
 |____/ \__,_|_| |_| |_|\___/___|___|
                                       
EOF
    echo -e "${NC}"
    echo -e "Installation complete!"
    
    if [ "$INSTALL_SWAY" = true ]; then
        echo -e "\n${YELLOW}Sway Configuration:${NC}"
        echo -e " • Config: ${GREEN}$CONFIG_DIR/sway/config${NC}"
        echo -e " • Start Sway: ${GREEN}sway${NC} (from TTY)"
    fi
    
    if [ "$INSTALL_I3" = true ]; then
        echo -e "\n${YELLOW}i3 Configuration:${NC}"
        echo -e " • Config: ${GREEN}$CONFIG_DIR/i3/config${NC}"
        echo -e " • Start i3: ${GREEN}startx${NC} (from TTY)"
    fi
    
    echo -e "\n${YELLOW}Recommended Next Steps:${NC}"
    echo -e " • Set wallpaper: ${GREEN}~/.config/sway/config${NC} or ${GREEN}feh --bg-fill${NC}"
    echo -e " • Customize keybindings in your WM config file"
    echo -e " • Install fonts: ${GREEN}$INSTALL_CMD fonts-noto fonts-roboto${NC}"
    echo -e "\nLog file: ${YELLOW}$LOG_FILE${NC}"
}

main
