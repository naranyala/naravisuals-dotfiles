#!/bin/bash

# Create config directories
mkdir -p ~/.config/zellij/themes
mkdir -p ~/.config/rio/themes

# --- ZELLIJ INSTALLATION ---
echo "🎨 Installing Catppuccin Mocha for Zellij..."

# Use a working theme file from a community blog
curl -sSL https://raw.githubusercontent.com/haseebmajid/dotfiles/main/config/zellij/themes/catppuccin-mocha.kdl \
  -o ~/.config/zellij/themes/catppuccin-mocha.kdl

echo '✅ Zellij theme saved to ~/.config/zellij/themes/catppuccin-mocha.kdl'

# --- RIO INSTALLATION ---
echo "🌊 Installing Catppuccin Mocha for Rio..."

curl -sSL https://raw.githubusercontent.com/catppuccin/rio/main/themes/catppuccin-mocha.toml \
  -o ~/.config/rio/themes/catppuccin-mocha.toml

echo '✅ Rio theme saved to ~/.config/rio/themes/catppuccin-mocha.toml'

# --- DONE ---
echo "🎉 Catppuccin Mocha installed for both Zellij and Rio!"

