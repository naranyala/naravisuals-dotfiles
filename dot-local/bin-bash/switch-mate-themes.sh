#!/usr/bin/env bash
set -e

# Minimal MATE Theme Manager
THEMES_DIR="$HOME/.themes"
BACKUP_FILE="$HOME/.mate_theme_backup"

# Dark themes with direct download URLs
declare -A THEMES=(
    ["Nordic"]="https://github.com/EliverLara/Nordic/archive/refs/heads/master.zip"
    ["Dracula"]="https://github.com/dracula/gtk/archive/refs/heads/master.zip" 
    ["Sweet-Dark"]="https://github.com/EliverLara/Sweet/archive/refs/heads/nova.zip"
    ["Ant-Dracula"]="https://github.com/EliverLara/Ant-Dracula/archive/refs/heads/master.zip"
)

# Backup current theme
gsettings get org.mate.interface gtk-theme > "$BACKUP_FILE"

# Show themes
echo "Dark themes:"
i=1; for name in "${!THEMES[@]}"; do echo "$i) $name"; ((i++)); done

# Get choice
read -p "Choose theme (number): " choice
theme_name=$(printf "%s\n" "${!THEMES[@]}" | sed -n "${choice}p")
[[ -z "$theme_name" ]] && { echo "Invalid choice"; exit 1; }

# Download and install
mkdir -p "$THEMES_DIR"
cd /tmp
wget -q "${THEMES[$theme_name]}" -O theme.zip
unzip -q theme.zip
mv *-master "$THEMES_DIR/$theme_name" 2>/dev/null || mv *-nova "$THEMES_DIR/$theme_name" 2>/dev/null
rm theme.zip

# Apply theme
gsettings set org.mate.interface gtk-theme "$theme_name"
echo "Applied: $theme_name"
echo "Restore with: gsettings set org.mate.interface gtk-theme $(cat $BACKUP_FILE)"
