#!/usr/bin/env bash
# Fedora App Installer Script with Niche Additions

set -e

# --- Core Categories ---
SYSTEM_APPS=(
  timeshift
  htop
  gnome-tweaks
  tlp              # Battery optimization
  guake            # Drop-down terminal
)


CREATIVE_APPS=(
  # gimp
  inkscape
  # krita
  blender
  darktable
  peek             # GIF screen recorder
  synfigstudio     # 2D animation
)

MEDIA_APPS=(
  vlc
  mpv
  kdenlive
  audacity         # Audio editing
  handbrake        # Video transcoder
)

SECURITY_APPS=(
  keepassxc
  gufw
  veracrypt        # Disk encryption
)

KNOWLEDGE_APPS=(
  calibre          # Ebook manager
  foliate          # Ebook reader
  newsboat         # Terminal RSS reader
  zeal             # Offline dev docs browser
)

DEVOPS_APPS=(
  neovim
  tmux
  git
  podman
  docker-compose
)

# Flatpak apps (from Flathub)
FLATPAK_APPS=(
  com.brave.Browser
  org.mozilla.firefox
  org.joplinapp.Joplin
  com.spotify.Client
  md.obsidian.Obsidian
  org.signal.Signal
)

# --- Functions ---
install_dnf_apps() {
  local apps=("$@")
  echo "Installing DNF apps: ${apps[*]}"
  sudo dnf install -y "${apps[@]}" --skip-unavailable
}

install_flatpak_apps() {
  local apps=("$@")
  echo "Installing Flatpak apps: ${apps[*]}"
  for app in "${apps[@]}"; do
    flatpak install -y flathub "$app"
  done
}

# --- Execution ---
echo "Updating system..."
sudo dnf upgrade -y

echo "Installing system apps..."
install_dnf_apps "${SYSTEM_APPS[@]}"

echo "Installing creative apps..."
install_dnf_apps "${CREATIVE_APPS[@]}"

echo "Installing media apps..."
install_dnf_apps "${MEDIA_APPS[@]}"

echo "Installing security apps..."
install_dnf_apps "${SECURITY_APPS[@]}"

echo "Installing knowledge apps..."
install_dnf_apps "${KNOWLEDGE_APPS[@]}"

echo "Installing devops apps..."
install_dnf_apps "${DEVOPS_APPS[@]}"

echo "Installing Flatpak apps..."
install_flatpak_apps "${FLATPAK_APPS[@]}"

echo "All done! 🚀"

