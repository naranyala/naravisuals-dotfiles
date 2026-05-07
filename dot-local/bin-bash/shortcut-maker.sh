#!/bin/bash

# Check if the user is root
if [ $(id -u) -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# App Launcher Maker Script
read -p "Enter the name of the application: " app_name
read -p "Enter the path to the executable binary (absolute or relative): " exec_path
read -p "Enter the path to the icon (PNG/SVG/etc): " icon_path
# Define output launcher filename
desktop_file="/home/${USER}/.local/share/applications/${app_name}.desktop"
# Create the .desktop file directory if it does not exist
mkdir -p "$(dirname "$desktop_file")"
cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$app_name
Exec=$exec_path
Icon=$icon_path
Type=Application
Terminal=false
Categories=Utility;
EOF
# Make the launcher executable
chmod +x "$desktop_file"
echo "Launcher created at $desktop_file ✅"
