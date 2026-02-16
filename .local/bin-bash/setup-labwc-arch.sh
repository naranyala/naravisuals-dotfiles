#!/usr/bin/env bash
# labwc-full-setup.sh - Full Labwc environment setup with configs
# Author: Fudzer (systems builder style)

set -euo pipefail

PACKAGES=(
    labwc
    xdg-desktop-portal-wlr
    wl-clipboard
    waybar
    swaybg
    wofi
    alacritty
    thunar
    mako
)

ROLLBACK_FILE="/tmp/labwc_installed_pkgs.txt"
CONFIG_BACKUP_DIR="$HOME/.config-backup-labwc-$(date +%Y%m%d%H%M%S)"

# --- FUNCTIONS ---
error_exit() {
    echo "❌ Error: $1"
    rollback
    exit 1
}

rollback() {
    if [[ -f "$ROLLBACK_FILE" ]]; then
        echo "↩️ Rolling back installed packages..."
        sudo pacman -Rns --noconfirm $(cat "$ROLLBACK_FILE") || true
        rm -f "$ROLLBACK_FILE"
    fi
}

install_packages() {
    echo "📦 Installing full Labwc environment..."
    for pkg in "${PACKAGES[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            echo "$pkg" >> "$ROLLBACK_FILE"
            sudo pacman -S --needed --noconfirm "$pkg" || error_exit "Failed to install $pkg"
        else
            echo "✔️ $pkg already installed"
        fi
    done
}

backup_configs() {
    echo "📂 Backing up existing configs to $CONFIG_BACKUP_DIR"
    mkdir -p "$CONFIG_BACKUP_DIR"
    for dir in labwc waybar mako alacritty; do
        if [[ -d "$HOME/.config/$dir" ]]; then
            cp -r "$HOME/.config/$dir" "$CONFIG_BACKUP_DIR/"
        fi
    done
}

deploy_configs() {
    echo "📝 Deploying starter configs..."
    mkdir -p "$HOME/.config/labwc" "$HOME/.config/waybar" "$HOME/.config/mako" "$HOME/.config/alacritty"

    # Labwc rc.xml
    cat > "$HOME/.config/labwc/rc.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<labwc>
  <keyboard>
    <keybind key="W-Return">
      <action name="Execute"><command>alacritty</command></action>
    </keybind>
    <keybind key="W-d">
      <action name="Execute"><command>wofi --show drun</command></action>
    </keybind>
    <keybind key="W-w">
      <action name="Execute"><command>swaybg -i ~/Pictures/wallpaper.jpg</command></action>
    </keybind>
  </keyboard>
</labwc>
EOF

    # Waybar config
    cat > "$HOME/.config/waybar/config" <<'EOF'
{
  "layer": "top",
  "modules-left": ["clock", "cpu", "memory"],
  "modules-right": ["network", "battery"]
}
EOF

    # Mako config
    cat > "$HOME/.config/mako/config" <<'EOF'
font=Sans 12
background-color=#1e1e2e
text-color=#ffffff
border-color=#89b4fa
EOF

    # Alacritty config
    cat > "$HOME/.config/alacritty/alacritty.yml" <<'EOF'
window:
  opacity: 0.9
font:
  normal:
    family: monospace
    size: 12
colors:
  primary:
    background: '0x1e1e2e'
    foreground: '0xffffff'
EOF
}

# --- MAIN ---
trap 'error_exit "Unexpected failure"' ERR

echo "🚀 Starting full Labwc setup..."
> "$ROLLBACK_FILE"
install_packages
backup_configs
deploy_configs
echo "✅ Full Labwc setup complete!"
echo "Configs deployed to ~/.config/, backups in $CONFIG_BACKUP_DIR"
echo "You can now run 'labwc' from a Wayland session."

