#!/usr/bin/env bash

WALLPAPER_DIR="/usr/share/wallpapers"
CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

# Collect image paths
IMAGES=()
while IFS= read -r -d $'\0' img; do
  IMAGES+=("$img")
done < <(find "$WALLPAPER_DIR" -type f -path "*/contents/images/*" \( -iname "*.jpg" -o -iname "*.png" \) -print0)

# Pick one
SELECTED="${IMAGES[RANDOM % ${#IMAGES[@]}]}"
echo "🎨 Selected: $SELECTED"

plasma-apply-wallpaperimage "$SELECTED"

# Update config
sed -i "/Wallpaper/,/^$/ {
  /Image=/c\Image=file://$SELECTED
}" "$CONFIG"

# Reload Plasma shell
dbus-send --session --type=method_call \
  --dest=org.kde.plasmashell \
  /PlasmaShell \
  org.kde.PlasmaShell.evaluateScript \
  string:"var allDesktops = desktops(); for (i = 0; i < allDesktops.length; i++) { allDesktops[i].reloadConfig(); }"
