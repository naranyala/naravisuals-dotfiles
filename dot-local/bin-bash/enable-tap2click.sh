#!/usr/bin/env bash
set -euo pipefail

log()   { echo -e "\e[1;32m[+] $*\e[0m"; }
warn()  { echo -e "\e[1;33m[!] $*\e[0m"; }
error() { echo -e "\e[1;31m[-] $*\e[0m" >&2; }

enable_gnome_wayland() {
  log "Enabling tap-to-click for GNOME on Wayland..."
  gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
  gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
}

enable_kde_wayland() {
  log "Enabling tap-to-click for KDE on Wayland..."
  kwriteconfig5 --file kcm_touchpadrc --group Touchpad --key TapToClick true
  qdbus org.kde.KWin /KWin reconfigure || warn "KWin reconfigure failed"
}

main() {
  DE=$(echo "${XDG_CURRENT_DESKTOP:-unknown}" | tr '[:upper:]' '[:lower:]')
  log "Detected DE: $DE (Wayland session)"

  case "$DE" in
    *gnome*) enable_gnome_wayland ;;
    *kde*) enable_kde_wayland ;;
    *)
      warn "Unknown or unsupported DE for Wayland: $DE"
      warn "Try enabling tap-to-click manually via your DE's settings UI"
      ;;
  esac

  log "Tap-to-click should now be active. You may need to log out and back in."
}

main "$@"

