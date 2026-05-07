#!/usr/bin/env bash
set -euo pipefail

# Respect XDG spec or fallback to defaults
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"

echo "🧹 Cleaning Neovim directories..."
for dir in "$CACHE_DIR" "$STATE_DIR" "$DATA_DIR"; do
    if [[ -d "$dir" ]]; then
        echo "🗑️ Removing: $dir"
        rm -rf "$dir"
    else
        echo "⚠️ Skipping missing: $dir"
    fi
    mkdir -p "$dir"
done

echo "✅ Neovim cache/state/data cleaned and reset."
