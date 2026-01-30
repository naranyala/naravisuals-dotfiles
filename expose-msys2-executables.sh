#!/bin/bash
# Install MSYS2 if missing, then install GNU utilities and expose them in Git Bash
# Includes silent installer run, path conversion, error handling, and visible linking progress

set -euo pipefail

MSYS_DIR="/c/msys64"
MSYS_BIN="$MSYS_DIR/usr/bin"
INSTALLER_URL="https://github.com/msys2/msys2-installer/releases/latest/download/msys2-x86_64-latest.exe"
INSTALLER_PATH="/c/Users/$(whoami)/Downloads/msys2-installer.exe"

error_exit() {
    echo "❌ ERROR: $1"
    exit 1
}

to_winpath() {
    echo "$1" | sed 's#^/c/#C:\\#; s#/#\\#g'
}

# --- Install MSYS2 if missing ---
if [ ! -d "$MSYS_DIR" ]; then
    echo "⚠️ MSYS2 not found. Downloading installer..."
    curl -L -o "$INSTALLER_PATH" "$INSTALLER_URL" || error_exit "Download failed."

    WIN_INSTALLER_PATH=$(to_winpath "$INSTALLER_PATH")
    WIN_MSYS_DIR=$(to_winpath "$MSYS_DIR")

    echo "📦 Running MSYS2 installer silently..."
    powershell.exe -Command "Start-Process -FilePath '$WIN_INSTALLER_PATH' -ArgumentList '/SILENT','/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/DIR=$WIN_MSYS_DIR' -Wait -NoNewWindow" || error_exit "Installer failed."

    [ -d "$MSYS_DIR" ] || error_exit "MSYS2 directory not found after installation."
    echo "✅ MSYS2 installed at $MSYS_DIR"
fi

# --- Update and install GNU utilities ---
echo "🔄 Updating MSYS2..."
"$MSYS_BIN/pacman.exe" -Sy --noconfirm || error_exit "Update failed."

echo "📦 Installing GNU coreutils, grep, sed, awk, etc..."
"$MSYS_BIN/pacman.exe" -S --noconfirm coreutils grep sed gawk findutils diffutils || error_exit "Package install failed."

# --- Linking process with progress ---
mkdir -p ~/bin
echo "🔗 Linking GNU utilities into ~/bin..."

executables=("$MSYS_BIN"/*.exe)
total=${#executables[@]}
count=0

for exe in "${executables[@]}"; do
    count=$((count+1))
    exe_name=$(basename "$exe")
    link_name="${exe_name%.exe}"

    if ln -sf "$exe" "$HOME/bin/$link_name"; then
        percent=$((count * 100 / total))
        echo "➡️ [$count/$total] Linked $link_name ($percent%)"
    else
        echo "⚠️ Skipped $exe_name due to error."
    fi
done

echo "✅ Finished linking $count GNU utilities."
echo "➡️ Restart Git Bash or run: source ~/.bashrc"
