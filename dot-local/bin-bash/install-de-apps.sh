
#!/usr/bin/env bash
# Fedora Major DE App Installer Script
# Focused on GNOME, KDE Plasma, XFCE, and MATE apps

set -e

# --- GNOME Apps ---
GNOME_APPS=(
  gnome-calendar
  gnome-weather
  gnome-maps
  gnome-boxes
  gnome-contacts
  gnome-clocks
  gnome-screenshot
  gnome-system-monitor
  gnome-disk-utility
)

# --- KDE Plasma Apps ---
KDE_APPS=(
  dolphin
  konsole
  okular
  kdenlive
  kate
  gwenview
  spectacle
  kcalc
  kmail
  amarok
)

# --- XFCE Apps ---
XFCE_APPS=(
  thunar
  ristretto
  mousepad
  xfce4-terminal
  xfce4-screenshooter
  xfce4-taskmanager
  parole
  xfburn
  orage
)

# --- MATE Apps ---
MATE_APPS=(
  atril
  pluma
  engrampa
  mate-terminal
  mate-system-monitor
  mate-screenshot
  mate-calc
  caja
  eom
)

# --- Functions ---
install_dnf_apps() {
  local apps=("$@")
  echo "Installing: ${apps[*]}"
  sudo dnf install -y "${apps[@]}"
}

# --- Execution ---
echo "Updating system..."
sudo dnf upgrade -y

echo "Installing GNOME apps..."
install_dnf_apps "${GNOME_APPS[@]}"

echo "Installing KDE apps..."
install_dnf_apps "${KDE_APPS[@]}"

echo "Installing XFCE apps..."
install_dnf_apps "${XFCE_APPS[@]}"

echo "Installing MATE apps..."
install_dnf_apps "${MATE_APPS[@]}"

echo "Major DE app installation complete! 🎉"
