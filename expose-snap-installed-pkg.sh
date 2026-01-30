#!/usr/bin/env bash

set -e

SNAP_DESKTOP_DIR="/var/lib/snapd/desktop/applications"
LOCAL_APPS_DIR="$HOME/.local/share/applications"

echo "Ensuring local applications directory exists..."
mkdir -p "$LOCAL_APPS_DIR"

echo "Creating symlinks for Snap desktop files..."
for file in "$SNAP_DESKTOP_DIR"/*.desktop; do
    if [ -f "$file" ]; then
        target="$LOCAL_APPS_DIR/$(basename "$file")"
        if [ -L "$target" ]; then
            echo "Symlink already exists: $target"
        else
            ln -s "$file" "$target"
            echo "Created symlink: $target"
        fi
    fi
done

echo "Reloading GNOME Shell..."
# Reload GNOME Shell to refresh the app list (works on X11)
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "Press Alt+F2, type 'r', and hit Enter to reload GNOME Shell."
else
    echo "On Wayland, log out and back in to refresh the launcher."
fi

echo "✅ All Snap apps should now be visible in GNOME Launcher!"

