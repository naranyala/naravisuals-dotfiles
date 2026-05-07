#!/usr/bin/env bash

# Dotfiles setup script for Sway, Waybar, and Wofi
# This script creates configuration files in ~/.config

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}Error: This script should not be run as root.${NC}" >&2
    exit 1
fi

# Check if running under Wayland
if [[ -z "${WAYLAND_DISPLAY}" ]]; then
    echo -e "${YELLOW}Warning: Not running under Wayland. Some features may not work properly.${NC}"
fi

# Create necessary directories
mkdir -p ~/.config/{sway,waybar,wofi} ~/.local/share/wofi/themes

# Backup existing configs if they exist
backup_file() {
    local file=$1
    if [[ -f "$file" ]]; then
        echo -e "${YELLOW}Backing up existing $file to ${file}.bak${NC}"
        cp "$file" "${file}.bak"
    fi
}

# Install required packages if they're not installed
check_and_install() {
    local pkg=$1
    if ! command -v "$pkg" &> /dev/null; then
        echo -e "${YELLOW}$pkg not found. Attempting to install...${NC}"
        if command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm "$pkg"
        elif command -v apt &> /dev/null; then
            sudo apt install -y "$pkg"
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y "$pkg"
        else
            echo -e "${RED}Error: Package manager not supported. Please install $pkg manually.${NC}"
            exit 1
        fi
    fi
}

# Check for required tools
check_and_install sway
check_and_install waybar
check_and_install wofi
check_and_install foot  # Recommended terminal for Sway
check_and_install swaylock
check_and_install swayidle
check_and_install mako  # Notification daemon

# Sway configuration
SWAY_CONFIG=~/.config/sway/config
backup_file "$SWAY_CONFIG"

cat > "$SWAY_CONFIG" << 'EOL'
# Default config for Sway
#
# Copy this to ~/.config/sway/config and edit it to your liking.

set $mod Mod4

# Input configuration
input * {
    xkb_layout us
    xkb_variant intl
    tap enabled
    natural_scroll enabled
}

# Output configuration
output * {
    bg ~/.config/sway/wallpaper.png fill
}

# Default programs
set $term foot
set $menu wofi --show drun

# Key bindings
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit Sway?' -b 'Yes' 'swaymsg exit'

# Layout bindings
bindsym $mod+f fullscreen
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# Focus movement
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Window movement
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Workspaces
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# System controls
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous

# Lock screen
bindsym $mod+Shift+p exec swaylock -f -c 000000

# Idle configuration
exec swayidle -w \
    timeout 300 'swaylock -f -c 000000' \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"' \
    before-sleep 'swaylock -f -c 000000'

# Status bar
exec waybar

# Notification daemon
exec mako

# Auto-start applications
exec_always {
    dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
}

# Window rules
for_window [class="Firefox"] inhibit_idle fullscreen
for_window [app_id="foot"] border pixel 2
EOL

echo -e "${GREEN}Created Sway configuration at $SWAY_CONFIG${NC}"

# Waybar configuration
WAYBAR_CONFIG=~/.config/waybar/config
WAYBAR_STYLE=~/.config/waybar/style.css

backup_file "$WAYBAR_CONFIG"
backup_file "$WAYBAR_STYLE"

cat > "$WAYBAR_CONFIG" << 'EOL'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "spacing": 4,
    "modules-left": ["sway/workspaces", "sway/mode"],
    "modules-center": ["sway/window"],
    "modules-right": ["network", "pulseaudio", "battery", "clock", "tray"],
    
    "sway/workspaces": {
        "disable-scroll": true,
        "all-outputs": false,
        "format": "{name}"
    },
    
    "sway/window": {
        "max-length": 50,
        "tooltip": false
    },
    
    "clock": {
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "format": "{:%H:%M}"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% {icon}",
        "format-muted": "",
        "format-icons": {
            "headphones": "",
            "handsfree": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", ""]
        },
        "scroll-step": 5,
        "on-click": "pavucontrol"
    },
    
    "network": {
        "interface": "wlp3s0",
        "format": "{ifname}",
        "format-wifi": " {essid}",
        "format-ethernet": " {ipaddr}/{cidr}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip-format": "{ifname} via {gwaddr}",
        "on-click": "nm-connection-editor"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "tray": {
        "icon-size": 21,
        "spacing": 10
    }
}
EOL

cat > "$WAYBAR_STYLE" << 'EOL'
* {
    border: none;
    border-radius: 0;
    font-family: "Fira Code", "Font Awesome 5 Free", sans-serif;
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background: rgba(40, 42, 54, 0.9);
    color: #f8f8f2;
}

#workspaces button {
    padding: 0 10px;
    background: transparent;
    color: #f8f8f2;
    border-bottom: 3px solid transparent;
}

#workspaces button.focused {
    background: #6272a4;
    border-bottom: 3px solid #f8f8f2;
}

#workspaces button.urgent {
    background: #ff5555;
}

#mode {
    background: #ff5555;
    padding: 0 10px;
}

#window {
    padding: 0 10px;
}

#clock, #battery, #network, #pulseaudio, #tray {
    padding: 0 10px;
    margin: 0 5px;
}

#battery {
    color: #f1fa8c;
}

#battery.charging {
    color: #50fa7b;
}

#battery.warning:not(.charging) {
    color: #ffb86c;
}

#battery.critical:not(.charging) {
    color: #ff5555;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

@keyframes blink {
    to {
        background-color: #ff5555;
        color: #282a36;
    }
}

#network {
    color: #8be9fd;
}

#network.disconnected {
    color: #ff5555;
}

#pulseaudio {
    color: #bd93f9;
}

#pulseaudio.muted {
    color: #ff5555;
}
EOL

echo -e "${GREEN}Created Waybar configuration at $WAYBAR_CONFIG and $WAYBAR_STYLE${NC}"

# Wofi configuration
WOFI_CONFIG=~/.config/wofi/config
WOFI_STYLE=~/.config/wofi/style.css

backup_file "$WOFI_CONFIG"
backup_file "$WOFI_STYLE"

cat > "$WOFI_CONFIG" << 'EOL'
width=600
height=400
show=drun
prompt=Search...
filter_rate=100
insensitive=true
allow_images=true
image_size=40
EOL

cat > "$WOFI_STYLE" << 'EOL'
* {
    font-family: "Fira Code", sans-serif;
}

window {
    background-color: rgba(40, 42, 54, 0.95);
    border-radius: 10px;
    border: 2px solid #bd93f9;
}

#input {
    margin: 5px;
    border-radius: 0px;
    border: none;
    background-color: #44475a;
    color: #f8f8f2;
}

#inner-box {
    margin: 5px;
    border: none;
    background-color: transparent;
}

#outer-box {
    margin: 5px;
    border: none;
    background-color: transparent;
}

#scroll {
    margin: 0px;
    border: none;
}

#text {
    margin: 5px;
    border: none;
    color: #f8f8f2;
} 

#entry {
    border: none;
}

#entry:selected {
    background-color: #6272a4;
    border-radius: 5px;
    border: none;
}

#entry image {
    padding: 5px;
    margin: 5px;
}
EOL

echo -e "${GREEN}Created Wofi configuration at $WOFI_CONFIG and $WOFI_STYLE${NC}"

# Download sample wallpaper
echo -e "${YELLOW}Downloading sample wallpaper...${NC}"
if command -v curl &> /dev/null; then
    curl -sL "https://unsplash.com/photos/hwLAI5lRhdM/download?force=true" -o ~/.config/sway/wallpaper.png || echo -e "${RED}Failed to download wallpaper${NC}"
elif command -v wget &> /dev/null; then
    wget "https://unsplash.com/photos/hwLAI5lRhdM/download?force=true" -O ~/.config/sway/wallpaper.png || echo -e "${RED}Failed to download wallpaper${NC}"
else
    echo -e "${YELLOW}Neither curl nor wget found. Skipping wallpaper download.${NC}"
fi

# Final instructions
echo -e "\n${GREEN}Dotfiles setup complete!${NC}"
echo -e "Here's what was installed:"
echo -e "  - Sway configuration: ~/.config/sway/config"
echo -e "  - Waybar configuration: ~/.config/waybar/config and style.css"
echo -e "  - Wofi configuration: ~/.config/wofi/config and style.css"
echo -e "\nTo start using Sway, simply log out and select Sway from your display manager,"
echo -e "or run 'sway' from a terminal if you're already in a TTY."
echo -e "\nKey bindings to remember:"
echo -e "  - Mod (Windows key) + Enter: Open terminal"
echo -e "  - Mod + d: Open application launcher"
echo -e "  - Mod + Shift + q: Close window"
echo -e "  - Mod + 1-0: Switch workspaces"
echo -e "  - Mod + Shift + 1-0: Move window to workspace"
echo -e "  - Mod + Shift + e: Exit Sway"
