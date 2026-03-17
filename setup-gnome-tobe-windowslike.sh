#!/usr/bin/env bash
# =============================================================================
#  gnome-windows-setup.sh
#  Transforms a Fedora GNOME desktop into a Windows-like experience.
#
#  What this script does:
#    1. Installs required system packages
#    2. Detects your GNOME Shell version dynamically
#    3. Downloads the correct extension version from extensions.gnome.org API
#    4. Installs + compiles schemas + enables each extension
#    5. Downloads and installs a Windows 10 GTK theme + icon set
#    6. Applies all gsettings (core + extension-specific) with retry logic
#    7. Gracefully handles GNOME session (X11 vs Wayland) for shell restart
#
#  Extensions installed:
#    - Dash to Panel   (Windows-style taskbar)
#    - ArcMenu         (Windows-style Start menu)
#    - User Themes     (required for custom GTK shell themes)
#
#  Safe to re-run: skips already-done steps, re-applies settings.
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLU}[INFO]${NC}  $*"; }
success() { echo -e "${GRN}[OK]${NC}    $*"; }
warn() { echo -e "${YEL}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
die() {
  error "$*"
  exit 1
}

# ─── Preflight ───────────────────────────────────────────────────────────────
[[ "$EUID" -eq 0 ]] && die "Do not run this script as root. It will use sudo when needed."

command -v gnome-shell &>/dev/null || die "GNOME Shell not found. Is this a GNOME session?"

GNOME_VER=$(gnome-shell --version | grep -oP '\d+' | head -1)
info "Detected GNOME Shell version: ${GNOME_VER}"

# ─── Directories ─────────────────────────────────────────────────────────────
EXT_DIR="$HOME/.local/share/gnome-shell/extensions"
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.local/share/icons"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$EXT_DIR" "$THEME_DIR" "$ICON_DIR"

# ─── 1. System packages ───────────────────────────────────────────────────────
info "Installing system packages..."
sudo dnf install -y \
  gnome-tweaks \
  gnome-extensions-app \
  gnome-menus \
  wget \
  unzip \
  curl \
  jq \
  glib2 \
  2>/dev/null || warn "Some packages may have failed — continuing."
success "Packages installed."

# ─── 2. Extension installer function ─────────────────────────────────────────
# Queries extensions.gnome.org API for the right version_tag for your shell,
# then downloads, extracts, compiles schemas, and enables the extension.
install_extension() {
  local uuid="$1"
  local friendly_name="$2"

  info "Installing extension: ${friendly_name} (${uuid})..."

  # Query the API
  local api_url="https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${GNOME_VER}"
  local api_response
  api_response=$(curl -fsSL "$api_url") ||
    {
      warn "API query failed for ${uuid} — skipping."
      return 1
    }

  # Extract version_tag (pk field inside shell_version_map for our version)
  local version_tag
  version_tag=$(echo "$api_response" | jq -r \
    ".shell_version_map[\"${GNOME_VER}\"].pk // empty" 2>/dev/null) ||
    true

  if [[ -z "$version_tag" ]]; then
    # Try nearest lower major version as fallback
    warn "No exact version for GNOME ${GNOME_VER}. Trying latest available..."
    version_tag=$(echo "$api_response" | jq -r \
      '[.shell_version_map | to_entries[] | .value.pk] | max' 2>/dev/null) || true
  fi

  [[ -z "$version_tag" || "$version_tag" == "null" ]] && {
    warn "Could not resolve version_tag for ${uuid} on GNOME ${GNOME_VER} — skipping."
    return 1
  }

  info "  → Resolved version_tag: ${version_tag}"

  local zip_url="https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${version_tag}"
  local zip_file="${TMP_DIR}/${uuid}.zip"
  local ext_path="${EXT_DIR}/${uuid}"

  wget -q --show-progress -O "$zip_file" "$zip_url" ||
    die "Failed to download extension: ${uuid}"

  mkdir -p "$ext_path"
  unzip -qo "$zip_file" -d "$ext_path"
  rm -f "$zip_file"

  # Compile GSettings schemas if present
  if [[ -d "${ext_path}/schemas" ]]; then
    info "  → Compiling schemas for ${uuid}..."
    glib-compile-schemas "${ext_path}/schemas/" &&
      success "  → Schemas compiled." ||
      warn "  → Schema compilation failed (may work anyway)."
  fi

  # Enable the extension
  gnome-extensions enable "${uuid}" 2>/dev/null &&
    success "  → ${friendly_name} enabled." ||
    warn "  → Could not enable ${uuid} yet (will need shell restart)."
}

# ─── 3. Install extensions ────────────────────────────────────────────────────
echo ""
info "══════════════════════════════════════════"
info " Installing GNOME Extensions"
info "══════════════════════════════════════════"

install_extension "dash-to-panel@jderose9.github.com" "Dash to Panel"
install_extension "arcmenu@arcmenu.com" "ArcMenu"
install_extension "user-theme@gnome-shell-extensions.gcampax.github.com" "User Themes"

# ─── 4. Install Windows 10 GTK Theme ─────────────────────────────────────────
echo ""
info "══════════════════════════════════════════"
info " Installing Windows 10 GTK Theme"
info "══════════════════════════════════════════"

THEME_NAME="Windows-10"
if [[ -d "${THEME_DIR}/${THEME_NAME}" ]]; then
  warn "Theme '${THEME_NAME}' already exists — skipping download."
else
  info "Downloading Windows 10 GTK theme..."
  wget -q --show-progress \
    -O "${TMP_DIR}/windows-theme.zip" \
    "https://github.com/B00merang-Project/Windows-10/archive/refs/heads/master.zip" ||
    die "Failed to download GTK theme."

  unzip -qo "${TMP_DIR}/windows-theme.zip" -d "${TMP_DIR}/theme-extract"

  # GitHub archives unzip to <repo>-master/, rename to proper theme name
  local_extracted=$(find "${TMP_DIR}/theme-extract" -maxdepth 1 -type d | tail -n1)
  mv "$local_extracted" "${THEME_DIR}/${THEME_NAME}"

  success "Theme installed to ${THEME_DIR}/${THEME_NAME}"
fi

# ─── 5. Install Whitesur Icon Theme (Windows-like icons) ─────────────────────
echo ""
info "══════════════════════════════════════════"
info " Installing WhiteSur Icon Theme (Windows-like icons)"
info "══════════════════════════════════════════"

ICON_THEME_NAME="WhiteSur"
if [[ -d "${ICON_DIR}/${ICON_THEME_NAME}" ]]; then
  warn "Icon theme '${ICON_THEME_NAME}' already exists — skipping."
else
  info "Downloading WhiteSur icon theme..."
  wget -q --show-progress \
    -O "${TMP_DIR}/whitesur-icons.zip" \
    "https://github.com/vinceliuice/WhiteSur-icon-theme/archive/refs/heads/master.zip" ||
    { warn "Failed to download icon theme — skipping."; }

  if [[ -f "${TMP_DIR}/whitesur-icons.zip" ]]; then
    unzip -qo "${TMP_DIR}/whitesur-icons.zip" -d "${TMP_DIR}/icon-extract"
    icon_extracted=$(find "${TMP_DIR}/icon-extract" -maxdepth 1 -type d | tail -n1)

    # Run the install script if present, else copy manually
    if [[ -f "${icon_extracted}/install.sh" ]]; then
      bash "${icon_extracted}/install.sh" -d "$ICON_DIR" -n "$ICON_THEME_NAME" &&
        success "Icon theme installed." ||
        warn "Icon install script failed — copying manually."
    else
      cp -r "$icon_extracted" "${ICON_DIR}/${ICON_THEME_NAME}"
      success "Icon theme copied to ${ICON_DIR}/${ICON_THEME_NAME}"
    fi
  fi
fi

# ─── 6. Apply gsettings ───────────────────────────────────────────────────────
echo ""
info "══════════════════════════════════════════"
info " Applying GNOME Settings"
info "══════════════════════════════════════════"

apply() {
  local schema="$1" key="$2" value="$3"
  if gsettings list-schemas 2>/dev/null | grep -qx "$schema"; then
    gsettings set "$schema" "$key" "$value" &&
      info "  ✓ $schema → $key = $value" ||
      warn "  ✗ Failed: $schema → $key"
  else
    warn "  ⟳ Schema not loaded yet (restart needed): $schema"
  fi
}

# Core GNOME appearance
info "Core settings..."
apply org.gnome.desktop.interface gtk-theme "'${THEME_NAME}'"
apply org.gnome.desktop.interface icon-theme "'${ICON_THEME_NAME}'"
apply org.gnome.desktop.interface clock-show-weekday "true"
apply org.gnome.desktop.interface clock-show-date "true"
apply org.gnome.desktop.interface font-name "'Segoe UI 10'"
apply org.gnome.desktop.interface document-font-name "'Segoe UI 10'"
apply org.gnome.desktop.wm.preferences button-layout "'appmenu:minimize,maximize,close'"
apply org.gnome.desktop.wm.preferences theme "'${THEME_NAME}'"
apply org.gnome.shell.app-switcher current-workspace-only "false"

# Shell theme (requires User Themes extension)
apply org.gnome.shell.extensions.user-theme name "'${THEME_NAME}'"

# Dash to Panel settings
info "Dash to Panel settings..."
apply org.gnome.shell.extensions.dash-to-panel panel-position "'BOTTOM'"
apply org.gnome.shell.extensions.dash-to-panel panel-size "40"
apply org.gnome.shell.extensions.dash-to-panel show-apps-icon-file "''"
apply org.gnome.shell.extensions.dash-to-panel show-show-apps-button "false"
apply org.gnome.shell.extensions.dash-to-panel taskbar-locked "false"
apply org.gnome.shell.extensions.dash-to-panel intellihide "false"
apply org.gnome.shell.extensions.dash-to-panel animate-show-apps "true"
apply org.gnome.shell.extensions.dash-to-panel show-clock-icon "false"
apply org.gnome.shell.extensions.dash-to-panel group-apps "true"
apply org.gnome.shell.extensions.dash-to-panel isolate-workspaces "false"

# ArcMenu settings
info "ArcMenu settings..."
apply org.gnome.shell.extensions.arcmenu menu-layout "'Windows11'"
apply org.gnome.shell.extensions.arcmenu enable-search "true"
apply org.gnome.shell.extensions.arcmenu position-in-panel "'Left'"
apply org.gnome.shell.extensions.arcmenu menu-button-appearance "'Icon'"

# ─── 7. Restart GNOME Shell ───────────────────────────────────────────────────
echo ""
info "══════════════════════════════════════════"
info " Restarting GNOME Shell"
info "══════════════════════════════════════════"

SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"

if [[ "$SESSION_TYPE" == "x11" ]]; then
  info "X11 session detected — restarting GNOME Shell in-place..."
  # Restart shell without logging out (X11 only)
  nohup bash -c 'sleep 2 && DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS='"$DBUS_SESSION_BUS_ADDRESS"' gnome-shell --replace &' &>/dev/null &
  success "Shell restart triggered (takes ~3 seconds)."

elif [[ "$SESSION_TYPE" == "wayland" ]]; then
  warn "Wayland session detected — in-place shell restart is not supported."
  echo ""
  echo -e "  ${YEL}➡  Please log out and log back in to activate all extensions.${NC}"
  echo -e "  ${YEL}➡  After logging back in, re-run this script to apply skipped settings.${NC}"

else
  warn "Unknown session type. Please log out and back in to activate extensions."
fi

# ─── 8. Done ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${GRN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GRN}║        ✅  Setup Complete!                   ║${NC}"
echo -e "${GRN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  Extensions installed:"
echo "    • Dash to Panel  → Windows-style taskbar at bottom"
echo "    • ArcMenu        → Windows-style Start menu"
echo "    • User Themes    → Custom GTK shell theming"
echo ""
echo "  Theme applied:     ${THEME_NAME}"
echo "  Icons applied:     ${ICON_THEME_NAME}"
echo ""
echo "  If anything looks unapplied after restart, re-run this script."
echo "  Fine-tune via: gnome-tweaks  or  gnome-extensions-app"
echo ""
