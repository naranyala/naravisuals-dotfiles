#!/bin/bash

# Define directories
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

# Create dotfiles structure
mkdir -p "$DOTFILES_DIR/sway"
mkdir -p "$DOTFILES_DIR/waybar/config"
mkdir -p "$DOTFILES_DIR/waybar/style"
mkdir -p "$DOTFILES_DIR/wofi"

# Check for required programs
REQUIRED_PROGRAMS=("sway" "waybar" "wofi")
echo "🔍 Checking required programs..."
for prog in "${REQUIRED_PROGRAMS[@]}"; do
    if ! command -v "$prog" &> /dev/null; then
        echo "⚠️  Warning: '$prog' is not installed."
    else
        echo "✅ '$prog' is installed."
    fi
done

# Create Sway config with autostart
cat <<EOF > "$DOTFILES_DIR/sway/config"
# Sway config starter
set \$mod Mod4

# Launch terminal
bindsym \$mod+Return exec alacritty

# Launch Wofi app launcher
bindsym \$mod+d exec wofi --show drun

# Close focused window
bindsym \$mod+Shift+q kill

# Autostart Waybar
exec waybar

# Optional background services
# exec mako
# exec nm-applet
# exec blueman-applet
EOF

# Create Waybar config
cat <<EOF > "$DOTFILES_DIR/waybar/config/config.jsonc"
/* Waybar config starter */
{
  "layer": "bottom",
  "modules-left": ["sway/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["battery", "network"]
}
EOF

# Create Waybar style
cat <<EOF > "$DOTFILES_DIR/waybar/style/style.css"
/* Waybar style starter */
* {
  font-family: "JetBrainsMono Nerd Font", monospace;
  font-size: 14px;
}
EOF

# Create Wofi config
cat <<EOF > "$DOTFILES_DIR/wofi/config"
# Wofi config starter
prompt="Run:"
width=500
height=300
EOF

# Symlink configs to ~/.config
echo "🔗 Creating symlinks in $CONFIG_DIR..."
ln -sf "$DOTFILES_DIR/sway" "$CONFIG_DIR/sway"
ln -sf "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar"
ln -sf "$DOTFILES_DIR/wofi" "$CONFIG_DIR/wofi"

echo "🎉 Dotfiles setup complete!"
echo "➡️  Configs are in $DOTFILES_DIR and symlinked to $CONFIG_DIR"
echo "🔄 Reload Sway with: swaymsg reload"

