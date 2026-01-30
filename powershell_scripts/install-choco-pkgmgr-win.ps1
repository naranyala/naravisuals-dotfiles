# Chocolatey Installation Script
# This script installs Chocolatey package manager on Windows.
# Run in an elevated PowerShell prompt (Run as Administrator).

# 1. Allow script execution for this process only
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# 2. Ensure TLS 1.2 is enabled for secure downloads
[System.Net.ServicePointManager]::SecurityProtocol = `
    [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# 3. Download and execute the Chocolatey installation script
$chocoInstallScript = 'https://community.chocolatey.org/install.ps1'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($chocoInstallScript))

