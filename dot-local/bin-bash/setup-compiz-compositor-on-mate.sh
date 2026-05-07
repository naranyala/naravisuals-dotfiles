#!/usr/bin/env bash
# compiz-mate-hotcorners.sh — Install & enable Compiz with hot corners in MATE without touching panel
# Author: Fudzer & Copilot
# License: MIT

set -euo pipefail

log() { echo -e "\e[1;32m[INFO]\e[0m $*"; }
err() { echo -e "\e[1;31m[ERROR]\e[0m $*" >&2; }

# --- Detect package manager ---
if command -v apt >/dev/null 2>&1; then
    PKG_INSTALL="sudo apt install -y"
    PKG_UPDATE="sudo apt update"
    PKGS="compiz compiz-plugins compiz-plugins-extra compizconfig-settings-manager mate-tweak wmctrl"
elif command -v dnf >/dev/null 2>&1; then
    PKG_INSTALL="sudo dnf install -y"
    PKG_UPDATE="sudo dnf check-update || true"
    PKGS="compiz compiz-plugins-main compiz-plugins-extra ccsm mate-tweak wmctrl"
elif command -v pacman >/dev/null 2>&1; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
    PKG_UPDATE="sudo pacman -Sy"
    PKGS="compiz compiz-plugins-main compiz-plugins-extra ccsm mate-tweak wmctrl"
else
    err "Unsupported package manager. Install Compiz manually."
    exit 1
fi

# --- Install packages ---
log "Updating package lists..."
$PKG_UPDATE
log "Installing Compiz + MATE integration..."
$PKG_INSTALL $PKGS

# --- Set Compiz as default WM for future sessions ---
log "Setting Compiz as default window manager..."
gsettings set org.mate.session.required-components windowmanager compiz

# --- Start Compiz now without touching panel ---
log "Starting Compiz in current session..."
compiz --replace --sm-disable --ignore-desktop-hints & disown
sleep 3

# --- Enable core plugins ---
log "Enabling core Compiz plugins..."
gconftool-2 --type list --list-type string \
    --set /apps/compiz/general/allscreens/options/active_plugins \
    "[core,composite,opengl,decor,move,resize,place,session,scale,expo]"

# --- Configure hot corners (hover activation) ---
log "Configuring hot corners..."
# Bottom-left → Scale (show all windows)
gconftool-2 --type string \
    --set /apps/compiz/plugins/scale/allscreens/options/initiate_edge "BottomLeft"
# Bottom-right → Expo (show all workspaces)
gconftool-2 --type string \
    --set /apps/compiz/plugins/expo/allscreens/options/expo_edge "BottomRight"

# --- Recovery script ---
cat << 'EOF' > ~/restore-marco.sh
#!/usr/bin/env bash
echo "Restoring Marco as window manager..."
gsettings set org.mate.session.required-components windowmanager marco
marco --replace &
EOF
chmod +x ~/restore-marco.sh
log "Recovery script saved to ~/restore-marco.sh"

log "Setup complete! Compiz is active with hover hot corners — panel untouched."

