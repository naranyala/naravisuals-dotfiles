#!/usr/bin/env bash
set -euo pipefail

echo "📁 Common .desktop shortcut paths on Linux systems:"
echo ""

echo "🔹 System-wide application shortcuts:"
echo "  - /usr/share/applications/"
echo "  - /usr/local/share/applications/"
echo ""

echo "🔹 User-specific application shortcuts:"
echo "  - ~/.local/share/applications/"
echo ""

echo "🔹 Snap applications:"
echo "  - /var/lib/snapd/desktop/applications/"
echo ""

echo "🔹 Flatpak applications:"
echo "  - /var/lib/flatpak/exports/share/applications/"
echo ""

echo "🔹 Wine application shortcuts:"
echo "  - ~/.local/share/applications/wine/Programs/"
echo ""

echo "📌 These paths contain .desktop files that define how applications appear in your system launcher."

