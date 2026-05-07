#!/bin/bash
# reload-mate.sh
# Safely reload MATE panel, Compiz compositor, and Plank dock

echo "=== Reloading MATE desktop components ==="

# --- Reload mate-panel ---
echo "[1/3] Restarting mate-panel..."
killall mate-panel && mate-panel &

# --- Reload Compiz ---
echo "[2/3] Restarting Compiz compositor..."
# Kill any existing compiz instance
killall compiz && compiz --replace ccp &

# --- Reload Plank ---
echo "[3/3] Restarting Plank dock..."
killall plank && plank & 

echo "=== All components reloaded successfully ==="

