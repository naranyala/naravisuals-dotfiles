
#!/usr/bin/env bash

### 🔍 Session Type Detection
session_type="${XDG_SESSION_TYPE:-}"
case "$session_type" in
  x11) session="X11" ;;
  wayland) session="Wayland" ;;
  *) session="Unknown" ;;
esac

### 🖼️ Desktop Environment Detection
desktop_env="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-unknown}}"

### 🔑 Login Manager Detection
login_mgr="Unknown"
if [[ -f /etc/systemd/system/display-manager.service ]]; then
  login_mgr="$(readlink /etc/systemd/system/display-manager.service | awk -F'/' '{print $NF}' | sed 's/.service$//')"
elif pgrep -x sddm >/dev/null; then
  login_mgr="sddm"
elif pgrep -x gdm >/dev/null; then
  login_mgr="gdm"
elif pgrep -x lightdm >/dev/null; then
  login_mgr="lightdm"
fi

### 📋 Summary Output
echo "Session Type     : $session"
echo "Desktop Env      : $desktop_env"
echo "Login Manager    : $login_mgr"
