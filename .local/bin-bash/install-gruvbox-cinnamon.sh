#!/usr/bin/env bash
# Proper setup for Gruvbox Material GTK + Gruvbox Plus Icon Pack on Fedora Cinnamon

set -euo pipefail

# Repositories
GTK_REPO="https://github.com/TheGreatMcPain/gruvbox-material-gtk"
GTK_NAME="Gruvbox-Material-GTK"
GTK_DIR="$HOME/.themes"

ICON_REPO="https://github.com/SylEleuth/gruvbox-plus-icon-pack"
ICON_NAME="Gruvbox-Plus"
ICON_DIR="$HOME/.icons"

echo "==> Installing Gruvbox Material GTK + Gruvbox Plus Icons"

# Ensure git is installed
if ! command -v git &>/dev/null; then
    echo "Installing git..."
    sudo dnf install -y git
fi

# Create directories
mkdir -p "$GTK_DIR" "$ICON_DIR"

# Clone GTK theme
if [ -d "$GTK_DIR/$GTK_NAME" ]; then
    echo "Updating GTK theme..."
    git -C "$GTK_DIR/$GTK_NAME" pull
else
    echo "Cloning GTK theme..."
    git clone --depth=1 "$GTK_REPO" "$GTK_DIR/$GTK_NAME"
fi

# Clone icon theme
if [ -d "$ICON_DIR/$ICON_NAME" ]; then
    echo "Updating icon theme..."
    git -C "$ICON_DIR/$ICON_NAME" pull
else
    echo "Cloning Gruvbox Plus icon pack..."
    git clone --depth=1 "$ICON_REPO" "$ICON_DIR/$ICON_NAME"
fi

# Apply themes via gsettings
echo "Applying themes..."
gsettings set org.cinnamon.desktop.interface gtk-theme "$GTK_NAME"
gsettings set org.cinnamon.desktop.interface icon-theme "$ICON_NAME"
gsettings set org.cinnamon.desktop.wm.preferences theme "$GTK_NAME"
gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita" # adjust if you want a Gruvbox cursor

echo "==> Gruvbox Material GTK + Gruvbox Plus setup complete!"
echo "You may need to log out/in or restart Cinnamon for full effect."

