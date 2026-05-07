#!/bin/bash

# Exit on error
set -e

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Backup existing configurations
backup_configs() {
    local backup_dir="$HOME/.config/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
    log "Backing up existing configurations to $backup_dir"
    mkdir -p "$backup_dir"
    for dir in sway waybar wofi; do
        if [[ -d "$HOME/.config/$dir" ]]; then
            cp -r "$HOME/.config/$dir" "$backup_dir/$dir"
            log "Backed up $dir configuration"
        fi
    done
}

# Check for dependencies
check_dependencies() {
    local deps=(sway waybar wofi brightnessctl pamixer)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "Warning: $dep is not installed"
            read -p "Would you like to install $dep? (y/n): " answer
            if [[ "$answer" == "y" ]]; then
                sudo apt-get install -y "$dep" || log "Failed to install $dep"
            fi
        fi
    done
}

# Create directory structure
mkdir -p ~/.config/sway ~/.config/waybar ~/.config/wofi ~/.local/bin

# Backup existing configs
backup_configs

# Check dependencies
check_dependencies

# Create Sway configuration
cat > ~/.config/sway/config << 'EOF'
# Sway configuration
set $mod Mod4
set $term alacritty
set $menu wofi --show drun

# Display settings
output * bg #1a1a1a solid_color
output * adaptive_sync on

# Input configuration
input * {
    xkb_layout us
    xkb_options ctrl:nocaps
    tap enabled
}

# Keybindings
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+q exec swaymsg kill
bindsym $mod+Shift+e exec swaymsg exit
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right
bindsym $mod+t floating toggle
bindsym $mod+s scratchpad show
bindsym $mod+Shift+s move scratchpad
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+b exec ~/.local/bin/brightness.sh up
bindsym $mod+Shift+b exec ~/.local/bin/brightness.sh down
bindsym $mod+v exec ~/.local/bin/volume.sh up
bindsym $mod+Shift+v exec ~/.local/bin/volume.sh down

# Window management
default_border pixel 2
default_floating_border pixel 2
gaps inner 8
gaps outer 5
smart_gaps on
smart_borders on

# Floating windows
for_window [app_id="pavucontrol"] floating enable
for_window [app_id="blueman-manager"] floating enable

# Startup applications
exec waybar
exec swaymsg "workspace 1"
exec notify-send "Sway" "Window manager started"
EOF

# Create Waybar configuration
cat > ~/.config/waybar/config.jsonc << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "spacing": 4,
    "modules-left": ["sway/workspaces", "sway/mode", "sway/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "tray"],
    "sway/workspaces": {
        "disable-scroll": false,
        "all-outputs": true,
        "format": "{name}: {icon}",
        "format-icons": {
            "1": "一",
            "2": "二",
            "3": "三",
            "urgent": "",
            "focused": "",
            "default": "○"
        }
    },
    "sway/window": {
        "max-length": 50
    },
    "clock": {
        "format": "{:%Y-%m-%d %H:%M:%S}",
        "interval": 1,
        "tooltip-format": "{:%Y-%m-%d | %H:%M}",
        "calendar": {
            "mode": "month",
            "weeks-pos": "right"
        }
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-muted": "MUTED",
        "format-icons": {
            "default": ["", "", ""]
        },
        "on-click": "pamixer -t"
    },
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "ETH {ipaddr}",
        "format-disconnected": "Disconnected ⚠",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}"
    },
    "cpu": {
        "format": "CPU {usage}%",
        "interval": 2
    },
    "memory": {
        "format": "MEM {used:0.1f}G/{total:0.1f}G",
        "interval": 2
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "BAT {capacity}% {icon}",
        "format-charging": "BAT {capacity}% ⚡",
        "format-icons": ["", "", "", "", ""]
    }
}
EOF

# Create Waybar stylesheet
cat > ~/.config/waybar/style.css << 'EOF'
* {
    font-family: JetBrains Mono, monospace;
    font-size: 13px;
    min-height: 0;
    border: none;
    border-radius: 0;
}

#waybar {
    background: rgba(26, 26, 26, 0.9);
    color: #ffffff;
    transition: background-color 0.2s;
}

#workspaces button {
    padding: 0 8px;
    color: #ffffff;
    background: transparent;
    border-bottom: 2px solid transparent;
}

#workspaces button.focused {
    background: #4c7899;
    border-bottom: 2px solid #ffffff;
}

#workspaces button.urgent {
    background: #ff5555;
}

#window, #clock, #pulseaudio, #network, #cpu, #memory, #battery, #tray {
    padding: 0 12px;
    margin: 0 4px;
}

#pulseaudio.muted {
    color: #ff5555;
}

#network.disconnected {
    color: #ff5555;
}

#battery.critical:not(.charging) {
    color: #ff5555;
    animation: blink 0.5s ease-in-out infinite alternate;
}

@keyframes blink {
    to { opacity: 0.6; }
}
EOF

# Create Wofi configuration
cat > ~/.config/wofi/config << 'EOF'
show=drun
width=800
height=500
always_parse_args=true
show_all=false
prompt=Launch
insensitive=true
allow_images=true
lines=10
key_exit=Escape
key_submit=Return
key_up=Up
key_down=Down
key_left=Left
key_right=Right
EOF

# Create Wofi stylesheet
cat > ~/.config/wofi/style.css << 'EOF'
window {
    margin: 10px;
    background-color: rgba(26, 26, 26, 0.95);
    border: 2px solid #4c7899;
    border-radius: 8px;
    font-family: JetBrains Mono, monospace;
    font-size: 14px;
}

#input {
    margin: 8px;
    padding: 5px;
    border: none;
    background-color: #2e2e2e;
    color: #ffffff;
    border-radius: 5px;
}

#inner-box {
    margin: 8px;
    background-color: transparent;
}

#entry {
    padding: 8px;
    color: #ffffff;
    border-radius: 5px;
}

#entry:selected {
    background-color: #4c7899;
    color: #ffffff;
    border-radius: 5px;
}

#text:selected {
    color: #ffffff;
}
EOF

# Create brightness control script
cat > ~/.local/bin/brightness.sh << 'EOF'
#!/bin/bash
# Brightness control script
STEP=5
case $1 in
    up)
        brightnessctl set +${STEP}%
        notify-send "Brightness" "$(brightnessctl --machine-readable | cut -d',' -f4)"
        ;;
    down)
        brightnessctl set ${STEP}%-
        notify-send "Brightness" "$(brightnessctl --machine-readable | cut -d',' -f4)"
        ;;
esac
EOF

# Create volume control script
cat > ~/.local/bin/volume.sh << 'EOF'
#!/bin/bash
# Volume control script
STEP=5
case $1 in
    up)
        pamixer --increase $STEP
        notify-send "Volume" "$(pamixer --get-volume)%"
        ;;
    down)
        pamixer --decrease $STEP
        notify-send "Volume" "$(pamixer --get-volume)%"
        ;;
esac
EOF

# Set proper permissions
chmod 644 ~/.config/sway/config
chmod 644 ~/.config/waybar/config.jsonc
chmod 644 ~/.config/waybar/style.css
chmod 644 ~/.config/wofi/config
chmod 644 ~/.config/wofi/style.css
chmod 755 ~/.local/bin/brightness.sh
chmod 755 ~/.local/bin/volume.sh

log "Dotfiles setup completed successfully!"
log "Configuration files created in ~/.config/ for sway, waybar, and wofi"
log "Utility scripts created in ~/.local/bin/ for brightness and volume control"
log "Existing configurations backed up in ~/.config/dotfiles_backup_*"
log "To use, ensure sway, waybar, wofi, brightnessctl, and pamixer are installed"
log "Run 'sway' to start the session"
