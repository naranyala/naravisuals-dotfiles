#!/bin/bash

# Complete XFCE Desktop Suite Installation Script for Fedora
# Includes --skip-unavailable and fixes display manager symlink

echo "Updating system packages..."
sudo dnf update -y --skip-unavailable

echo "Installing core XFCE desktop group..."
sudo dnf groupinstall -y "Xfce Desktop" --skip-unavailable

echo "Installing XFCE plugins, themes, and utilities..."
sudo dnf install -y --skip-unavailable \
xfce4-whiskermenu-plugin xfce4-weather-plugin xfce4-battery-plugin xfce4-cpugraph-plugin \
xfce4-netload-plugin xfce4-sensors-plugin xfce4-systemload-plugin xfce4-xkb-plugin \
xfce4-dict xfce4-screenshooter xfce4-taskmanager xfce4-power-manager xfce4-volumed \
xfce4-notes xfce4-timer-plugin \
gtk-xfce-engine xfce4-themes arc-theme elementary-xfce-icon-theme gnome-themes-extra

echo "Installing LightDM display manager..."
sudo dnf install -y --skip-unavailable lightdm lightdm-gtk-greeter

echo "Switching display manager to LightDM..."
sudo ln -sf /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service
sudo systemctl daemon-reexec
sudo systemctl enable lightdm

echo "Setting system to boot into graphical target..."
sudo systemctl set-default graphical.target

echo "XFCE installation complete. Reboot to start your XFCE session."

