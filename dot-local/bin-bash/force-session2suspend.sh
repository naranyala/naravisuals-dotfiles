#!/bin/bash
# suspend-any.sh
# Force suspend Arch Linux using multiple methods
# Ordered from lowest-level kernel to highest-level systemd

set -euo pipefail

log() { echo "[suspend-any] $*"; }

STATE_FILE="/sys/power/state"

# 1. Kernel sysfs interface (direct)
suspend_sysfs() {
  if [[ -w "$STATE_FILE" ]]; then
    log "Trying kernel sysfs interface..."
    echo "mem" | sudo tee "$STATE_FILE" > /dev/null
    return 0
  fi
  return 1
}

# 2. pm-utils (legacy)
suspend_pmutils() {
  if command -v pm-suspend >/dev/null 2>&1; then
    log "Trying pm-utils (pm-suspend)..."
    sudo pm-suspend
    return 0
  fi
  return 1
}

# 3. uswsusp (s2ram)
suspend_uswsusp() {
  if command -v s2ram >/dev/null 2>&1; then
    log "Trying uswsusp (s2ram)..."
    sudo s2ram
    return 0
  fi
  return 1
}

# 4. elogind (systemd-free login manager)
suspend_elogind() {
  if command -v loginctl >/dev/null 2>&1; then
    log "Trying elogind (loginctl suspend)..."
    loginctl suspend
    return 0
  fi
  return 1
}

# 5. dbus (direct call)
suspend_dbus() {
  if command -v dbus-send >/dev/null 2>&1; then
    log "Trying D-Bus call to logind..."
    dbus-send --system --type=method_call \
      --dest=org.freedesktop.login1 \
      /org/freedesktop/login1 \
      "org.freedesktop.login1.Manager.Suspend" boolean:true
    return 0
  fi
  return 1
}

# 6. systemd (last resort)
suspend_systemd() {
  if command -v systemctl >/dev/null 2>&1; then
    log "Trying systemd (systemctl suspend)..."
    systemctl suspend
    return 0
  fi
  return 1
}

# Run through all options in order
main() {
  suspend_sysfs    && exit 0
  suspend_pmutils  && exit 0
  suspend_uswsusp  && exit 0
  suspend_elogind  && exit 0
  suspend_dbus     && exit 0
  suspend_systemd  && exit 0

  log "Error: No suspend method succeeded."
  exit 1
}

main "$@"

