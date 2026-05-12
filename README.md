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


## 💭 Analysis & Critique

**Opinion:**
This repository is more than a dotfile collection; it is a "digital garden" for systems programming. The polyglot approach in `packages/` (comparing C, C3, Rust, Zig, and TS) is an excellent way to benchmark language ergonomics and binary sizes.

**Critics:**
- **Repository Bloat:** Including the full source code of `latte-dock` inside a dotfiles repo is non-standard and increases repo size unnecessarily.
- **High Entropy:** The root directory is cluttered with backup files (`.bak`, `.bak-alt2`), making it harder to distinguish active configs from legacy ones.
- **Inconsistent Documentation:** While the high-level structure is clear, many sub-packages and Python scripts lack meaningful `README` files.
- **Manual Management:** The repo relies on manual file copying rather than a dedicated dotfile manager.

## 🚀 Future Roadmap

- **Adopt a Dotfile Manager:** Integrate [GNU Stow](https://www.gnu.org/software/stow/) or [Chezmoi](https://www.chezmoi.io/) to manage symlinks systematically.
- **Modularize External Projects:** Move `latte-dock` and other large third-party sources into separate repositories and link them as Git submodules.
- **Unified Bootstrapping:** Create a global `setup.sh` (Linux) and `setup.ps1` (Windows) to automate the installation of all dependencies and configurations.
- **Documentation Sprint:** Standardize `README.md` files across all entries in `packages/` and `script-python/` to document the "why" behind each experiment.
- **Cleanup:** Remove legacy `.bak` files and move them to a dedicated `archive/` directory.
