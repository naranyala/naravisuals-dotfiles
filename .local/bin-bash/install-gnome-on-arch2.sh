#!/usr/bin/env bash
# =============================================================================
#  Arch → GNOME desktop installation script (2025/2026 edition)
#  Meant to be run AFTER base + base-devel + network + user + sudo is ready
# =============================================================================

set -euo pipefail

# ─── Colors ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ─── Configurable section ──────────────────────────────────────────────────
DESIRED_HOSTNAME="arch-gnome"
TIMEZONE="Europe/Berlin"           # ← CHANGE THIS
LOCALE="en_US.UTF-8 UTF-8"         # ← CHANGE IF NEEDED
KEYMAP="us"                        # console keymap

GNOME_GROUP="gnome gnome-extra"
ESSENTIAL_APPS=(
    # Core GNOME experience
    gnome-control-center gnome-tweaks gnome-software gnome-software-packagekit-plugin
    # File management & archive
    nautilus file-roller
    # Text / code editors
    gnome-text-editor
    # Browser (most people want one preinstalled)
    firefox firefox-ublock-origin
    # Media
    totem mpv celluloid
    # Useful utilities
    loupe    # image viewer
    evince   # pdf viewer
    baobab   # disk usage analyzer
    seahorse # keyring / passwords
    # Terminal & tools
    gnome-terminal tilix
    neofetch fastfetch htop btop
    # Commonly wanted extras
    vlc code gimp inkscape
    # Nice to have fonts & cursors
    noto-fonts noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-font-awesome
    adwaita-icon-theme papirus-icon-theme
)

# ─── Helpers ───────────────────────────────────────────────────────────────
msg_info()  { printf "${GREEN}→ %s${NC}\n" "$*"; }
msg_warn()  { printf "${YELLOW}⚠  %s${NC}\n" "$*"; }
msg_error() { printf "${RED}✖  %s${NC}\n" "$*" >&2; exit 1; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

pacman_install() {
    local pkgs=("$@")
    if (( ${#pkgs[@]} == 0 )); then return; fi

    msg_info "Installing ${#pkgs[@]} packages..."
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

yay_install() {
    if ! command_exists yay; then
        msg_info "Installing yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    fi

    msg_info "Installing AUR packages: $*"
    yay -S --needed --noconfirm "$@"
}

# ─── Main logic ────────────────────────────────────────────────────────────
clear
printf "\n${GREEN}┌───────────────────────────────────────────────┐${NC}\n"
printf "${GREEN}│   Arch Linux → GNOME desktop installer        │${NC}\n"
printf "${GREEN}└───────────────────────────────────────────────┘${NC}\n\n"

# 1. Make sure we have a working network
if ! ping -c1 -W2 1.1.1.1 &>/dev/null; then
    msg_error "No internet connection detected. Connect first."
fi

# 2. Update mirrorlist & full system upgrade first
msg_info "Refreshing mirrors and performing full system upgrade..."
sudo pacman -Syyu --noconfirm

# 3. Install GNOME (proper session + apps)
pacman_install xorg xorg-xwayland mesa vulkan-intel vulkan-radeon vulkan-mesa-layers \
               "${GNOME_GROUP[@]}"

pacman_install "${ESSENTIAL_APPS[@]}"

# 4. Optional: some popular GNOME extensions & tools via AUR
if command_exists yay; then
    yay_install \
        gnome-shell-extension-appindicator-git \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-blur-my-shell \
        gnome-shell-extension-pop-shell \
        morewaita \
        gradience
fi

# 5. Enable useful services
msg_info "Enabling important services..."
sudo systemctl enable --now \
    gdm \
    NetworkManager \
    bluetooth \
    cups \
    avahi-daemon

# 6. Basic system configuration
msg_info "Setting timezone, locale, hostname, keymap..."

sudo timedatectl set-timezone "$TIMEZONE"

# Locale
sudo tee /etc/locale.gen >/dev/null <<EOF
$LOCALE
EOF
sudo locale-gen
sudo localectl set-locale LANG="${LOCALE%% *}"

echo "$DESIRED_HOSTNAME" | sudo tee /etc/hostname
sudo tee /etc/hosts >/dev/null <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $DESIRED_HOSTNAME.localdomain $DESIRED_HOSTNAME
EOF

# Console keymap (also affects early boot)
echo "KEYMAP=$KEYMAP" | sudo tee /etc/vconsole.conf

# 7. Final touches
msg_info "Creating user directories and updating font cache..."
xdg-user-dirs-update || true
fc-cache -fv || true

# 8. Summary
cat <<'EOF'

┌─────────────────────────────────────────────────────────────┐
│                    Installation finished                    │
│                                                             │
│  → Reboot now?   (recommended)                              │
│                                                             │
│     sudo reboot                                             │
│                                                             │
│  After reboot you should see the GDM login screen.          │
│                                                             │
│  Happy hacking!                                             │
└─────────────────────────────────────────────────────────────┘

EOF

read -p "Reboot now? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi
