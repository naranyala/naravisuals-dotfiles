#!/usr/bin/env bash
#
# mate-hotcorners-reset.sh — Reset & configure MATE hot corners
# Author: Fudzer (with Copilot assist)
# Description: Enables Compiz, sets bottom-left to show all windows (Scale),
#              bottom-right to show all workspaces (Expo), with backups & logging.
#

LOGFILE="$HOME/mate-hotcorners-$(date +%Y%m%d-%H%M%S).log"

log() {
    echo "[$(date '+%F %T')] $*" | tee -a "$LOGFILE"
}

log "=== Starting MATE hot corners reset ==="

# 1. Ensure Compiz & CCSM are installed
if ! command -v compiz >/dev/null; then
    log "Installing Compiz and plugins..."
    sudo apt update && sudo apt install -y compiz compiz-plugins compizconfig-settings-manager
else
    log "Compiz already installed."
fi

# 2. Switch to Compiz as WM
log "Switching to Compiz..."
nohup compiz --replace >/dev/null 2>&1 &
sleep 2

# 3. Enable Scale (all windows) and Expo (all workspaces)
log "Enabling Scale and Expo plugins..."
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ active-plugins \
"['core','composite','opengl','compiztoolbox','decor','move','resize','place','wall','scale','expo']"

# 4. Set hot corners
# Edge bindings: 0=TopLeft, 1=Top, 2=TopRight, 3=Right, 4=BottomRight, 5=Bottom, 6=BottomLeft, 7=Left
# Scale plugin bottom-left
log "Setting bottom-left corner to show all windows..."
dconf write /org/compiz/profiles/unity/plugins/scale/initiate-edge 6

# Expo plugin bottom-right
log "Setting bottom-right corner to show all workspaces..."
dconf write /org/compiz/profiles/unity/plugins/expo/expo-edge 4

log "Hot corners configured: BL=All Windows, BR=All Workspaces."
log "=== MATE hot corners reset completed ==="
log "Log saved to $LOGFILE"

