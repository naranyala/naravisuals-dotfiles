#!/usr/bin/env bash
set -e

echo "=== Installing Doom Emacs on Fedora ==="

# Backup existing configs
[[ -d ~/.emacs.d ]] && mv ~/.emacs.d ~/.emacs.d.backup_$(date +%s)
[[ -d ~/.doom.d ]] && mv ~/.doom.d ~/.doom.d.backup_$(date +%s)

# Install dependencies
echo "Installing dependencies..."
sudo dnf install -y emacs git ripgrep fd-find cmake gcc gcc-c++ \
    nodejs python3 sqlite editorconfig

# # Install Nerd Font
# echo "Installing fonts..."
# mkdir -p ~/.local/share/fonts/NerdFonts
# cd /tmp
# curl -fLo JetBrainsMono.zip \
#     https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
# unzip -qo JetBrainsMono.zip -d ~/.local/share/fonts/NerdFonts
# rm JetBrainsMono.zip
# fc-cache -f

# Clone and install Doom
echo "Installing Doom Emacs..."
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
~/.emacs.d/bin/doom install --force

# Add to PATH
SHELL_RC="${HOME}/.bashrc"
[[ -n "$ZSH_VERSION" ]] && SHELL_RC="${HOME}/.zshrc"
grep -q '.emacs.d/bin' "$SHELL_RC" || echo 'export PATH="$HOME/.emacs.d/bin:$PATH"' >> "$SHELL_RC"

echo ""
echo "✓ Installation complete!"
echo "Run: source $SHELL_RC"
echo "Then: doom sync"
