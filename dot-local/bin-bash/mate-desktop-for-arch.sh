#!/usr/bin/env bash
# Arch-based MATE Desktop One-Shot Installer
# Usage: sudo bash mate-arch-installer.sh
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/var/log/mate_installer_$(date +%Y%m%d_%H%M%S).log"

#----------------------------
# Helpers
#----------------------------
msg()  { echo -e "==> $*"; }
inf()  { echo -e "  -> $*"; }
warn() { echo -e "WARN: $*" >&2; }
err()  { echo -e "ERR:  $*" >&2; }
die()  { err "$*"; exit 1; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    die "Please run as root (sudo $SCRIPT_NAME)."
  fi
}

confirm() {
  local prompt="${1:-Proceed?} [y/N]: "
  read -r -p "$prompt" ans || true
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

cmd_exists() { command -v "$1" >/dev/null 2>&1; }

log_setup() {
  touch "$LOG_FILE" || die "Cannot write log to $LOG_FILE"
  exec > >(tee -a "$LOG_FILE") 2>&1
  msg "Logging to $LOG_FILE"
}

#----------------------------
# Environment checks
#----------------------------
check_arch_based() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    ID_LIKE_LOWER="$(echo "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')"
    ID_LOWER="$(echo "${ID:-}" | tr '[:upper:]' '[:lower:]')"
    if [[ "$ID_LOWER" != "arch" && "$ID_LIKE_LOWER" != *"arch"* ]]; then
      warn "This does not look like an Arch-based distro (ID=$ID, ID_LIKE=$ID_LIKE)."
      warn "Continuing only if pacman is available."
    fi
  fi
  cmd_exists pacman || die "pacman not found. This script is for Arch-based systems only."
}

check_internet() {
  inf "Checking internet connectivity..."
  if ! ping -c1 -W2 archlinux.org >/dev/null 2>&1; then
    warn "No ping to archlinux.org. Continuing but installs may fail without internet."
  fi
}

#----------------------------
# Package selections
#----------------------------
PKG_XORG=(
  xorg-server xorg-xinit xorg-xrandr xorg-xset
)

# You can replace with a different DM if you prefer (e.g., sddm)
PKG_DISPLAY_MANAGER=(
  lightdm lightdm-slick-greeter
)

PKG_MATE_BASE=(
  mate mate-extra
  engrampa atril eom mate-terminal mate-system-monitor
  mate-control-center mate-power-manager mate-screensaver
  marco
)

PKG_NETWORK=(
  networkmanager network-manager-applet
)

PKG_APPS=(
  firefox vlc gimp libreoffice-fresh
)

PKG_UTILS=(
  git curl wget htop nano unzip zip p7zip
)

PKG_FONTS=(
  ttf-dejavu ttf-liberation noto-fonts noto-fonts-cjk noto-fonts-emoji
)

# Optional input method support (disabled by default)
ENABLE_FCITX5=0
PKG_FCITX5=(
  fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-mozc
)

ALL_PACKAGES=(
  "${PKG_XORG[@]}"
  "${PKG_DISPLAY_MANAGER[@]}"
  "${PKG_MATE_BASE[@]}"
  "${PKG_NETWORK[@]}"
  "${PKG_APPS[@]}"
  "${PKG_UTILS[@]}"
  "${PKG_FONTS[@]}"
)

#----------------------------
# Pacman helpers
#----------------------------
pacman_refresh() {
  msg "Refreshing package databases and upgrading system..."
  pacman -Syuu --noconfirm --needed
}

install_packages() {
  local -a pkgs=("$@")
  local to_install=()
  for p in "${pkgs[@]}"; do
    if ! pacman -Qi "$p" >/dev/null 2>&1; then
      to_install+=("$p")
    else
      inf "Already installed: $p"
    fi
  done
  if (( ${#to_install[@]} )); then
    msg "Installing packages: ${to_install[*]}"
    pacman -S --noconfirm --needed "${to_install[@]}"
  else
    msg "All selected packages already installed."
  fi
}

#----------------------------
# Configuration steps
#----------------------------
configure_lightdm() {
  if systemctl is-enabled lightdm >/dev/null 2>&1; then
    inf "LightDM already enabled."
    return
  fi

  msg "Configuring LightDM with slick-greeter..."
  local conf_dir="/etc/lightdm"
  local conf_file="/etc/lightdm/lightdm.conf"
  local greeter_conf="/etc/lightdm/slick-greeter.conf"

  mkdir -p "$conf_dir"

  # Ensure greeter is set
  if [[ -f "$conf_file" ]]; then
    sed -i 's|^#\?greeter-session=.*|greeter-session=lightdm-slick-greeter|g' "$conf_file" || true
  else
    cat > "$conf_file" <<'EOF'
[Seat:*]
greeter-session=lightdm-slick-greeter
user-session=mate
EOF
  fi

  # Greeter config (optional branding tweaks)
  if [[ ! -f "$greeter_conf" ]]; then
    cat > "$greeter_conf" <<'EOF'
[Greeter]
draw-user-backgrounds=false
show-a11y=false
show-power=false
EOF
  fi

  systemctl enable lightdm
  msg "LightDM enabled to start at boot."
}

enable_services() {
  msg "Enabling critical services..."
  systemctl enable NetworkManager || warn "Failed to enable NetworkManager"
}

configure_locales_hint() {
  # Provide a hint to the user for locales/keymaps if not configured
  if ! locale | grep -q "LANG="; then
    warn "Locales may not be configured. Consider editing /etc/locale.gen and running locale-gen, then set LANG in /etc/locale.conf."
  fi
}

setup_fcitx5_env() {
  (( ENABLE_FCITX5 == 1 )) || return 0
  msg "Configuring Fcitx5 environment variables..."
  local profile="/etc/environment"
  declare -A envs=(
    ["GTK_IM_MODULE"]="fcitx"
    ["QT_IM_MODULE"]="fcitx"
    ["XMODIFIERS"]="@im=fcitx"
    ["INPUT_METHOD"]="fcitx"
  )
  for k in "${!envs[@]}"; do
    if grep -q "^$k=" "$profile" 2>/dev/null; then
      sed -i "s|^$k=.*|$k=${envs[$k]}|g" "$profile"
    else
      echo "$k=${envs[$k]}" >> "$profile"
    fi
  done
  msg "Fcitx5 environment set in /etc/environment."
}

post_install_notes() {
  cat <<'NOTE'

Post-install notes:
- Default session is "MATE". At next boot, LightDM will present the login screen.
- NetworkManager is enabled. Use nm-connection-editor or the tray applet to connect.
- Fonts installed: DejaVu, Liberation, Noto (Latin, CJK, Emoji).
- LibreOffice "fresh" installed. If you prefer the "still" branch, replace libreoffice-fresh with libreoffice-still.
- To change the display manager later: systemctl disable lightdm && pacman -S sddm && systemctl enable sddm
- If you enabled Fcitx5, log out and back in. Language data (e.g., mozc) is included.

Reboot when ready: sudo reboot
NOTE
}

#----------------------------
# Main
#----------------------------
main() {
  require_root
  log_setup
  check_arch_based
  check_internet

  msg "This will install the MATE desktop and desktop apps on an Arch-based system."
  echo
  echo "Selected package groups:"
  echo " - Xorg:            ${PKG_XORG[*]}"
  echo " - Display manager: ${PKG_DISPLAY_MANAGER[*]}"
  echo " - MATE:            ${PKG_MATE_BASE[*]}"
  echo " - Network:         ${PKG_NETWORK[*]}"
  echo " - Apps:            ${PKG_APPS[*]}"
  echo " - Utils:           ${PKG_UTILS[*]}"
  echo " - Fonts:           ${PKG_FONTS[*]}"
  if (( ENABLE_FCITX5 == 1 )); then
    echo " - Fcitx5:          ${PKG_FCITX5[*]}"
  fi
  echo

  if ! confirm "Proceed with installation"; then
    die "Installation cancelled."
  fi

  pacman_refresh

  install_packages "${ALL_PACKAGES[@]}"
  if (( ENABLE_FCITX5 == 1 )); then
    install_packages "${PKG_FCITX5[@]}"
    setup_fcitx5_env
  fi

  configure_lightdm
  enable_services
  configure_locales_hint

  msg "Installation complete."
  post_install_notes
}

main "$@"

