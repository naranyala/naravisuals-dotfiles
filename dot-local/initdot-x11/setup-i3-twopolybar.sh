#!/usr/bin/env bash
set -euo pipefail

readonly LOGFILE="$HOME/.cache/i3-setup.log"
readonly MODKEY="Mod4"
readonly TERMINAL="alacritty"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOGFILE"; }
die() { log "ERROR: $*"; exit 1; }

check_system() {
    [[ "$(id -u)" -eq 0 ]] && die "Don't run as root"
    command -v apt >/dev/null || die "Debian/Ubuntu only"
    mkdir -p "$(dirname "$LOGFILE")" "$HOME/.config" "$HOME/.local/share/fonts"
}

install_packages() {
    local packages=(
        i3-wm polybar rofi picom feh alacritty 
        pulseaudio-utils pavucontrol i3status 
        i3lock xss-lock brightnessctl fonts-hack-ttf
    )
    
    log "Updating package cache..."
    sudo apt update || die "Package update failed"
    
    log "Installing packages..."
    sudo apt install -y "${packages[@]}" || die "Package installation failed"
}

setup_fonts() {
    if fc-list | grep -qi "Hack Nerd Font"; then
        log "Nerd Font already installed"
        return
    fi
    
    log "Installing Hack Nerd Font..."
    local temp_dir
    temp_dir="$(mktemp -d)"
    
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip -O "$temp_dir/Hack.zip" && \
       cd "$temp_dir" && unzip -q Hack.zip && cp ./*.ttf "$HOME/.local/share/fonts/" && \
       fc-cache -fv >/dev/null; then
        log "Nerd Font installed"
    else
        log "WARNING: Nerd Font install failed, using system font"
    fi
    
    rm -rf "$temp_dir"
}

create_i3_config() {
    mkdir -p "$HOME/.config/i3"
    cat > "$HOME/.config/i3/config" <<EOF
set \$mod $MODKEY
font pango:Hack Nerd Font 11

default_border pixel 2
gaps inner 8
gaps outer 4

# Autostart
exec_always --no-startup-id feh --bg-fill \$HOME/Pictures/wallpaper.jpg 2>/dev/null || true
exec_always --no-startup-id picom
exec_always --no-startup-id polybar -r top &
exec_always --no-startup-id polybar -r bottom &
exec --no-startup-id xss-lock -- i3lock -c 000000

# Keybindings
bindsym \$mod+Return exec $TERMINAL
bindsym \$mod+d exec rofi -show drun
bindsym \$mod+Shift+q kill
bindsym \$mod+f fullscreen toggle
bindsym \$mod+Shift+space floating toggle

# Focus
bindsym \$mod+Left focus left
bindsym \$mod+Down focus down
bindsym \$mod+Up focus up
bindsym \$mod+Right focus right

# Move
bindsym \$mod+Shift+Left move left
bindsym \$mod+Shift+Down move down
bindsym \$mod+Shift+Up move up
bindsym \$mod+Shift+Right move right

# Workspaces
set \$ws1 "1"
set \$ws2 "2"
set \$ws3 "3"
set \$ws4 "4"
set \$ws5 "5"

bindsym \$mod+1 workspace \$ws1
bindsym \$mod+2 workspace \$ws2
bindsym \$mod+3 workspace \$ws3
bindsym \$mod+4 workspace \$ws4
bindsym \$mod+5 workspace \$ws5

bindsym \$mod+Shift+1 move container to workspace \$ws1
bindsym \$mod+Shift+2 move container to workspace \$ws2
bindsym \$mod+Shift+3 move container to workspace \$ws3
bindsym \$mod+Shift+4 move container to workspace \$ws4
bindsym \$mod+Shift+5 move container to workspace \$ws5

# Media keys
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

# i3 control
bindsym \$mod+Shift+c reload
bindsym \$mod+Shift+r restart
bindsym \$mod+Shift+e exit

# Resize mode
mode "resize" {
    bindsym Left resize shrink width 10 px
    bindsym Down resize grow height 10 px
    bindsym Up resize shrink height 10 px
    bindsym Right resize grow width 10 px
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym \$mod+r mode "resize"

# Floating rules
for_window [class="Pavucontrol"] floating enable
for_window [class="Arandr"] floating enable

# Disable default i3bar (using polybar instead)
# bar {
#     status_command i3status
#     position top
# }
EOF
}

create_polybar_config() {
    mkdir -p "$HOME/.config/polybar"
    cat > "$HOME/.config/polybar/config.ini" <<EOF
[bar/top]
width = 100%
height = 26
background = #282a36
foreground = #f8f8f2
font-0 = Hack Nerd Font:size=10;2
position = top

modules-left = i3
modules-center = date
modules-right = cpu memory battery

[bar/bottom]
width = 100%
height = 26
background = #282a36
foreground = #f8f8f2
font-0 = Hack Nerd Font:size=10;2
position = bottom

modules-left = filesystem network
modules-center = xwindow
modules-right = volume backlight wireless-network wired-network

[module/i3]
type = internal/i3
label-focused = %name%
label-focused-background = #44475a
label-focused-padding = 2
label-unfocused = %name%
label-unfocused-padding = 2

[module/date]
type = internal/date
interval = 5
date = %a %d %b
time = %H:%M
label = %date% %time%

[module/cpu]
type = internal/cpu
interval = 2
label = CPU %percentage%%

[module/memory]
type = internal/memory
interval = 2
label = RAM %percentage_used%%

[module/battery]
type = internal/battery
battery = BAT0
adapter = ADP1
label-charging = BAT %percentage%%
label-discharging = BAT %percentage%%
label-full = BAT FULL

[module/filesystem]
type = internal/fs
interval = 25
mount-0 = /
label-mounted = DISK %percentage_used%%
label-unmounted = DISK N/A

[module/network]
type = internal/network
interface = eth0
interval = 3.0
format-connected = ETH <label-connected>
format-disconnected = ETH down
label-connected = %downspeed:9%

[module/xwindow]
type = internal/xwindow
label = %title:0:50:...%

[module/volume]
type = internal/pulseaudio
format-volume = VOL <label-volume>
label-volume = %percentage%%
label-muted = VOL muted

[module/backlight]
type = internal/backlight
card = intel_backlight
format = BRI <label>
label = %percentage%%

[module/wireless-network]
type = internal/network
interface = wlan0
interval = 3.0
format-connected = WIFI <label-connected>
format-disconnected = WIFI down
label-connected = %essid%

[module/wired-network]
type = internal/network
interface = eth0
interval = 3.0
format-connected = ETH connected
format-disconnected = ETH down
EOF
}

create_picom_config() {
    mkdir -p "$HOME/.config/picom"
    cat > "$HOME/.config/picom/picom.conf" <<EOF
backend = "glx";
vsync = true;
shadow = true;
shadow-radius = 8;
shadow-offset-x = -8;
shadow-offset-y = -8;
shadow-opacity = 0.5;
inactive-opacity = 0.9;
blur-background = true;
blur-method = "dual_kawase";
blur-strength = 3;
fading = true;
fade-delta = 4;
EOF
}

create_rofi_config() {
    mkdir -p "$HOME/.config/rofi"
    cat > "$HOME/.config/rofi/config.rasi" <<EOF
configuration {
    font: "Hack Nerd Font 11";
    show-icons: true;
    display-drun: "Apps";
}

* {
    background-color: #282a36;
    text-color: #f8f8f2;
    border-color: #bd93f9;
}

window {
    background-color: @background-color;
    border: 2px;
    border-color: @border-color;
    padding: 8px;
}

element selected {
    background-color: @border-color;
    text-color: @background-color;
}
EOF
}

main() {
    log "Starting i3 setup..."
    
    check_system
    install_packages
    setup_fonts
    
    log "Creating configurations..."
    create_i3_config
    create_polybar_config
    create_picom_config
    create_rofi_config
    
    # Create wallpaper directory
    mkdir -p "$HOME/Pictures"
    
    log "Setup complete! Logout and select i3 from login screen"
    log "Log file: $LOGFILE"
}

main
