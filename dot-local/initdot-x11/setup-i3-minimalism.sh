#!/usr/bin/env bash
set -euo pipefail

readonly LOGFILE="$HOME/.cache/i3-setup.log"
readonly TERMINAL="alacritty"

log() { echo "[$(date '+%H:%M')] $*" | tee -a "$LOGFILE"; }
die() { log "ERR: $*"; exit 1; }

check() {
    [[ "$(id -u)" -eq 0 ]] && die "Don't run as root"
    command -v apt >/dev/null || die "Debian/Ubuntu only"
    mkdir -p "$(dirname "$LOGFILE")" "$HOME/.config"
}

install() {
    local pkgs=(i3-wm polybar rofi picom feh alacritty pulseaudio-utils i3lock)
    
    log "Installing minimal i3 environment..."
    sudo apt update -qq || die "Update failed"
    sudo apt install -y "${pkgs[@]}" || die "Install failed"
}

setup_i3() {
    mkdir -p "$HOME/.config/i3"
    cat > "$HOME/.config/i3/config" <<'EOF'
set $mod Mod4
font pango:monospace 9

# Remove all decorations
default_border none
default_floating_border none
hide_edge_borders both
focus_follows_mouse no

# No gaps - pure minimal
gaps inner 0
gaps outer 0

# Minimal autostart
exec_always --no-startup-id picom --no-vsync --backend xrender
exec_always --no-startup-id polybar -r minimal
exec --no-startup-id feh --bg-fill ~/.config/wallpaper 2>/dev/null || feh --bg-solid "#000000"

# Essential bindings only
bindsym $mod+Return exec alacritty
bindsym $mod+space exec rofi -show drun
bindsym $mod+q kill
bindsym $mod+f fullscreen toggle

# Arrow key navigation
bindsym $mod+Left focus left
bindsym $mod+Down focus down  
bindsym $mod+Up focus up
bindsym $mod+Right focus right

bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# Minimal workspaces (1-5)
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5

bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5

# System
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exit
bindsym $mod+l exec i3lock -c 000000

# Volume (no visual feedback)
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
EOF
}

setup_polybar() {
    mkdir -p "$HOME/.config/polybar"
    cat > "$HOME/.config/polybar/config.ini" <<'EOF'
[bar/minimal]
width = 100%
height = 20
background = #00000000
foreground = #ffffff
font-0 = monospace:size=9
position = top
fixed-center = true
padding = 0
module-margin = 0

modules-left = workspaces
modules-center = time
modules-right = battery

separator = 

[module/workspaces]
type = internal/i3
format = <label-state>
label-focused = [%name%]
label-unfocused = %name%
label-visible = (%name%)
label-urgent = !%name%!
label-focused-padding = 1
label-unfocused-padding = 1
label-visible-padding = 1
label-urgent-padding = 1

[module/time]
type = internal/date
interval = 60
date = %H:%M
label = %date%

[module/battery]
type = internal/battery
battery = BAT0
adapter = ADP1
format-charging = +%percentage%
format-discharging = %percentage%
format-full = full
poll-interval = 60
EOF
}

setup_picom() {
    mkdir -p "$HOME/.config/picom"
    cat > "$HOME/.config/picom/picom.conf" <<'EOF'
backend = "xrender";
vsync = false;
shadow = false;
fading = false;
inactive-opacity = 1.0;
blur-background = false;
EOF
}

setup_rofi() {
    mkdir -p "$HOME/.config/rofi"
    cat > "$HOME/.config/rofi/config.rasi" <<'EOF'
configuration {
    font: "monospace 10";
    show-icons: false;
    display-drun: "";
    sidebar-mode: false;
}

* {
    background-color: #000000;
    text-color: #ffffff;
    border-color: #ffffff;
}

window {
    background-color: @background-color;
    border: 1px;
    border-color: @border-color;
    padding: 4px;
    width: 300px;
}

inputbar {
    background-color: @background-color;
    text-color: @text-color;
    padding: 2px;
    children: [entry];
}

listview {
    background-color: @background-color;
    padding: 2px 0px;
    lines: 6;
    columns: 1;
}

element {
    background-color: @background-color;
    text-color: @text-color;
    padding: 2px;
}

element selected {
    background-color: @text-color;
    text-color: @background-color;
}
EOF
}

setup_terminal() {
    mkdir -p "$HOME/.config/alacritty"
    cat > "$HOME/.config/alacritty/alacritty.yml" <<'EOF'
window:
  padding:
    x: 4
    y: 4
  decorations: none

font:
  normal:
    family: monospace
  size: 11

colors:
  primary:
    background: '#000000'
    foreground: '#ffffff'
  
cursor:
  style:
    shape: Block
    blinking: Never

scrolling:
  history: 1000
EOF
}

create_wallpaper() {
    # Create a pure black 1x1 pixel image as minimal wallpaper
    mkdir -p "$HOME/.config"
    echo -e '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x00\x00\x00\x00:~\x9bU\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xdb\x00\x00\x00\x00IEND\xaeB`\x82' > "$HOME/.config/wallpaper"
}

main() {
    log "Minimal i3 setup..."
    
    check
    install
    
    log "Creating minimal configs..."
    setup_i3
    setup_polybar  
    setup_picom
    setup_rofi
    setup_terminal
    create_wallpaper
    
    log "Done. Logout -> select i3"
}

main
