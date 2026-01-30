#!/usr/bin/env bash

set -e

echo "Checking for choco..."
if ! command -v choco.exe >/dev/null 2>&1; then
    echo "Chocolatey not found. Installing Chocolatey..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass \
        "Set-ExecutionPolicy Bypass -Scope Process; \
         [System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'; \
         iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
fi

echo "Installing Node.js LTS..."
choco.exe install nodejs-lts -y

echo "Node.js installation complete."
node -v
npm -v

