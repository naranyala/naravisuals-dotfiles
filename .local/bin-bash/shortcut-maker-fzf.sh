#!/bin/bash

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root. Try again with: sudo $0"
  exit 1
fi

# --- Dependencies check ---
for cmd in fzf; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "❌ Required command '$cmd' not found. Please install it first."
    exit 1
  fi
done

read -p "Enter the name of the application: " app_name

# --- Executable fuzzy search ---
echo "🔍 Searching executables (this may take time)..."
exec_path=$(find / -type f -executable 2>/dev/null | fzf --prompt="Binary> ")
if [[ -z "$exec_path" ]]; then
  echo "❌ No executable selected. Aborting."
  exit 1
fi

# --- Icon fuzzy search ---
echo "🔍 Searching icons (PNG/SVG)..."
icon_path=$(find / -type f \( -iname "*.png" -o -iname "*.svg" \) 2>/dev/null | fzf --prompt="Icon> ")
if [[ -z "$icon_path" ]]; then
  echo "❌ No icon selected. Aborting."
  exit 1
fi

desktop_file="/usr/share/applications/${app_name}.desktop"

# --- Rollback if file exists ---
if [[ -f "$desktop_file" ]]; then
  echo "⚠️ Launcher already exists at $desktop_file"
  read -p "Overwrite? (y/N): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

cat > "$desktop_file" << EOF
[Desktop Entry]
Name=$app_name
Exec=$exec_path
Icon=$icon_path
Type=Application
Terminal=false
Categories=Utility;
EOF

chmod +x "$desktop_file"
echo "✅ Launcher created at $desktop_file"

