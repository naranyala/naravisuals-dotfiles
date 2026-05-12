# Naravisuals Dotfiles & Toolbox

A comprehensive collection of configuration files, automation scripts, and experimental software projects.

## 📂 Repository Structure

### 🛠️ Dotfiles
Configurations for a customized development environment:
- **Shells**: `.bashrc`, `.zshrc`, `starship.toml`
- **Window Managers**: Sway, Niri
- **UI Components**: Waybar, Fuzzel
- **Applications**: Neovim (`dot-config-nvim`), Kitty (`dot-config-kitty`), Tmux (`dot-tmux.conf`)

### 📦 Toolbox
A variety of utility projects and scripts:
- **`packages/`**: Polyglot implementations of CLI tools (e.g., `dirnav`) in C, C3, Rust, Zig, and TypeScript to compare performance and ergonomics.
- **`powershell_scripts/`**: Windows-specific automation for package managers (Scoop, Winget, Choco), user management, and environment setup.
- **`script-python/`**: Python utilities for package installation and system GUI/TUI tools.
- **`fresh-install/`**: Resources for system deployment, including customized `latte-dock` builds and `fpm` package templates.

### 📜 System Scripts
Root-level utility scripts for system maintenance and information:
- `expose-niche-system-info.sh`: Extract detailed system specifications.
- `setup-local-ssh-key.sh`: Automate SSH key generation and setup.
- `fix-ntfs2.sh`: NTFS filesystem utility.

## 🚀 Getting Started

This repository is primarily used as a personal backup and reference. To use these configurations:
1. Explore the `dot-` prefixed files for application settings.
2. Check the `packages/` directory for language-specific CLI experiments.
3. Use `powershell_scripts/` for Windows environment bootstrapping.
