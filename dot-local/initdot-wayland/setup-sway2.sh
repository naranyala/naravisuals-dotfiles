
#!/usr/bin/env bash
set -euo pipefail

# === Configurable Variables ===
DOTFILES_DIR="$HOME/projects-remote/modular-dotfiles"
CONFIG_DIR="$HOME/.config"
LOG_FILE="$DOTFILES_DIR/setup.log"
REQUIRED_PROGRAMS=("sway" "alacritty" "swaybg" "pactl" "brightnessctl")
AUTOSTART_SERVICES=("swaybg -i /usr/share/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png")

touch "$LOG_FILE"

# === Helper Functions ===
log() { echo "[$(date +'%F %T')] $*" | tee -a "$LOG_FILE"; }
ensure_dir() { mkdir -p "$1" && log "📁 Created: $1"; }
safe_symlink() {
    local src="$1" dst="$2"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        log "⚠️  Skipped symlink: $dst exists and is not a symlink"
    else
        ln -sf "$src" "$dst" && log "🔗 Linked: $src → $dst"
    fi
}

# === Setup Directories ===
log "🚀 Starting Sway-only setup..."
ensure_dir "$DOTFILES_DIR/sway"

# === Check Required Programs ===
log "🔍 Checking required programs..."
for prog in "${REQUIRED_PROGRAMS[@]}"; do
    if ! command -v "$prog" &> /dev/null; then
        log "❌ Missing: $prog — consider installing it"
    else
        log "✅ Found: $prog"
    fi
done

# === Generate Sway Config ===
cat <<EOF > "$DOTFILES_DIR/sway/config"
# Sway config
set \$mod Mod4

# Launch terminal
bindsym \$mod+Return exec foot -L nix-shell

# Close window
bindsym \$mod+Shift+q kill

# Reload config
bindsym \$mod+Shift+c reload

# Exit Sway
bindsym \$mod+Shift+e exit

# Move focus
bindsym \$mod+h focus left
bindsym \$mod+j focus down
bindsym \$mod+k focus up
bindsym \$mod+l focus right

# Move windows
bindsym \$mod+Shift+h move left
bindsym \$mod+Shift+j move down
bindsym \$mod+Shift+k move up
bindsym \$mod+Shift+l move right

# Split layout
bindsym \$mod+v split v
bindsym \$mod+b split h

# Toggle fullscreen
bindsym \$mod+f fullscreen

# Change layout
bindsym \$mod+space layout toggle split

# Resize mode
mode "resize" {
    bindsym h resize shrink width 10px
    bindsym j resize grow height 10px
    bindsym k resize shrink height 10px
    bindsym l resize grow width 10px
    bindsym Return mode "default"
}
bindsym \$mod+r mode "resize"

# Volume control
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle

# Brightness control
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

# Autostart services
$(for svc in "${AUTOSTART_SERVICES[@]}"; do echo "exec $svc"; done)
EOF
log "📝 Generated Sway config"

# === Symlink to ~/.config ===
log "🔗 Linking Sway config to $CONFIG_DIR..."
safe_symlink "$DOTFILES_DIR/sway" "$CONFIG_DIR/sway"

# === Final Message ===
log "✅ Sway setup complete!"
echo -e "\n📂 Configs: $DOTFILES_DIR/sway → $CONFIG_DIR/sway"
echo "📄 Log: $LOG_FILE"
echo "🔄 Reload Sway with: swaymsg reload"
