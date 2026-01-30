# Activate-WindowsViaKMS.ps1
# Requires Administrator privileges

# Self-elevate if not running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Not running as Administrator. Attempting to relaunch with elevated privileges..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Installing KMS client setup key..." -ForegroundColor Cyan
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX

Write-Host "Setting KMS host..." -ForegroundColor Cyan
slmgr /skms kms8.msguides.com

Write-Host "Activating Windows..." -ForegroundColor Cyan
slmgr /ato

Write-Host "Activation process completed. Check status with 'slmgr /dlv' if needed." -ForegroundColor Green


# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser  # If needed
# .\Activate-WindowsViaKMS.ps1
