#!/usr/bin/env bash
# ===================================================================
# Tauri + GTK3 + WebKitGTK development environment setup for Fedora
# Works on Fedora Workstation, Silverblue, Kinoite, Sericea, etc.
# Run as normal user (it will use sudo when needed)
# ===================================================================

set -euo pipefail

echo "Detecting Fedora variant and installing required packages for Tauri + GTK3 + webkit2gtk..."

# Core GTK3 + GLib + GObject development libraries
GTK_DEV_PACKAGES=(
  gtk3-devel           # GTK3 headers + libs
  glib2-devel          # GLib + GObject
  cairo-devel          # Cairo
  pango-devel          # Pango
  gdk-pixbuf2-devel    # GdkPixbuf
  atk-devel            # ATK (accessibility)
  at-spi2-atk-devel    # ATK bridge
  libxkbcommon-devel   # Often needed by newer webkit2gtk
  libepoxy-devel       # OpenGL abstraction (webkit2gtk dependency)
  enchant2-devel       # Spell checking (webkit2gtk)
  harfbuzz-devel       # Text shaping
  libjpeg-turbo-devel  # JPEG support
  libpng-devel         # PNG support
  libtiff-devel        # TIFF support
  libsoup-devel        # HTTP (used by webkit2gtk)
  libxml2-devel        # XML parsing
  sqlite-devel         # SQLite (webkit2gtk)
  gstreamer1-plugins-base-devel  # Multimedia (optional but common)
  gstreamer1-devel
)

# WebKitGTK – the big one that pulls in half the system
WEBKIT_PACKAGES=(
  webkit2gtk4.1-devel   # Tauri v2 default (WebView2 on Windows, Cocoa on macOS, this on Linux)
  # webkit2gtk4.0-devel # fallback for older projects – uncomment if needed
)

# Build essentials (almost always already there, but be safe)
BUILD_ESSENTIALS=(
  gcc gcc-c++ make cmake
  clang                    # sometimes needed by bindgen
  pkgconf-pkg-config       # pkg-config (critical!)
  rust cargo               # Rust toolchain (in case you don't have it)
  openssl-devel            # for rustls/tls in many crates
)

# Optional but very common for Tauri desktop apps
OPTIONAL_PACKAGES=(
  dbus-devel               # D-Bus (global shortcuts, notifications)
  libappindicator-gtk3-devel  # System tray (tauri-plugin-system-tray)
  librsvg2-devel           # SVG rendering
  nodejs npm               # If you use npm/yarn/pnpm for frontend
)

ALL_PACKAGES=(
  "${BUILD_ESSENTIALS[@]}"
  "${GTK_DEV_PACKAGES[@]}"
  "${WEBKIT_PACKAGES[@]}"
  "${OPTIONAL_PACKAGES[@]}"
)

echo "Installing/Updating $(wc -w <<< "${ALL_PACKAGES[*]}") packages via dnf..."

# Use --skip-broken and --setopt=strict=0 to be resilient in minimal/CI environments
sudo dnf install -y "${ALL_PACKAGES[@]}" --setopt=strict=0 --skip-broken

# Silverblue / Universal Blue / Bazzite users: layer the packages if needed
if command -v rpm-ostree >/dev/null; then
  echo "rpm-ostree system detected (Silverblue / Atomic variant)"
  echo "Layering packages permanently..."
  sudo rpm-ostree install -y --idempotent "${ALL_PACKAGES[@]}" || true
  echo "Packages layered. Please REBOOT now so the new libraries are available."
  echo "After reboot, run your cargo build again."
  exit 0
fi

# Set pkg-config path just in case (helps in some container setups)
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:${PKG_CONFIG_PATH:-}"

echo "========================================"
echo "All GTK3 + WebKitGTK dependencies installed!"
echo "You should now be able to compile any Tauri project that uses:"
echo "  - glib-sys / gio-sys / gobject-sys / gdk-sys"
echo "  - webkit2gtk / tauri-plugin-* / custom titlebars"
echo ""
echo "Just run: cargo build"
echo "========================================"

# Optional: show versions
echo "Quick verification:"
echo "  GTK3:     $(pkg-config --modversion gtk+-3.0 2>/dev/null || echo 'not found')"
echo "  WebKit:   $(pkg-config --modversion webkit2gtk-4.1 2>/dev/null || echo 'not found')"
echo "  GLib:     $(pkg-config --modversion glib-2.0)"
