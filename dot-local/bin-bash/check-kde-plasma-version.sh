#!/usr/bin/env bash

echo "📦 Checking KDE package versions via APT..."

# Frameworks version via core packages
fw_pkg="libkf5coreaddons5"
if apt show "$fw_pkg" &>/dev/null; then
    fw_ver=$(apt show "$fw_pkg" 2>/dev/null | awk '/Version:/{print $2}')
    echo "KDE Frameworks (via $fw_pkg): $fw_ver"
else
    echo "KDE Frameworks: Package $fw_pkg not found"
fi

# Plasma version via desktop shell package
plasma_pkg="plasma-desktop"
if apt show "$plasma_pkg" &>/dev/null; then
    plasma_ver=$(apt show "$plasma_pkg" 2>/dev/null | awk '/Version:/{print $2}')
    echo "Plasma Desktop (via $plasma_pkg): $plasma_ver"
else
    echo "Plasma Desktop: Package $plasma_pkg not found"
fi
