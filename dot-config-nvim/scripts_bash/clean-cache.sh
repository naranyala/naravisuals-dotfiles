#!/bin/sh

# Set Neovim cache directories
NVIM_CACHE_DIR="${HOME}/.local/share/nvim"
NVIM_STATE_DIR="${HOME}/.local/state/nvim"

echo "🧼 Cleaning Neovim cache directories..."

cleanup_path() {
    if [ -d "$1" ]; then
        echo "Removing directory $1"
        rm -rf "$1"
    elif [ -f "$1" ]; then
        echo "Removing file $1"
        rm -f "$1"
    fi
}

cleanup_path "${NVIM_CACHE_DIR}/swap"
cleanup_path "${NVIM_CACHE_DIR}/undo"
cleanup_path "${NVIM_CACHE_DIR}/view"
cleanup_path "${NVIM_CACHE_DIR}/shada"
cleanup_path "${NVIM_STATE_DIR}"

# Optional: clean shada file
SHADA_FILE="${NVIM_CACHE_DIR}/shada/main.shada"
[ -f "$SHADA_FILE" ] && rm -f "$SHADA_FILE" && echo "Deleted $SHADA_FILE"

echo "✅ Done. Neovim cache cleaned."
