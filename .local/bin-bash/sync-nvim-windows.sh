#!/usr/bin/bash

echo "delete ~/.config/nvim ..."
rm -rf ~/.config/nvim

echo "symlink neovim ..."
/d/projects-remote/naravisuals-dotfiles/.local/create-symlinks/symlink-nvim.sh
