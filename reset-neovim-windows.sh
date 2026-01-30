#!/usr/bin/env bash
# reset-lazy.sh
# Safely clear Lazy.nvim cache and lock files without deleting your setup

# Define Neovim data directory (Windows via MSYS2, Git Bash, or WSL)
NVIM_DATA="${LOCALAPPDATA}/nvim-data"

# Paths
LAZY_DIR="${NVIM_DATA}/lazy"
LOCK_FILE="${NVIM_DATA}/lazy-lock.json"

echo "Clearing Lazy.nvim cache from: $LAZY_DIR"
if [ -d "$LAZY_DIR" ]; then
  rm -rf "$LAZY_DIR"
  echo "Removed lazy cache directory."
else
  echo "No lazy cache directory found."
fi

echo "Checking for lock file: $LOCK_FILE"
if [ -f "$LOCK_FILE" ]; then
  rm "$LOCK_FILE"
  echo "Removed lazy-lock.json."
else
  echo "No lock file found."
fi

echo "✅ Lazy.nvim cache reset complete. Your setup files remain untouched."
echo "Next step: open Neovim and run ':Lazy sync' to rebuild plugins."

