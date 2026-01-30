# Hard reset Neovim cache/data/config on Windows
# Save this as Reset-Nvim.ps1 and run in PowerShell

# Paths
$Config = Join-Path $env:LOCALAPPDATA "nvim"
$Data   = Join-Path $env:LOCALAPPDATA "nvim-data"
$Cache  = Join-Path $Data "cache"

Write-Host "Removing Neovim directories:"
Write-Host "  Config: $Config"
Write-Host "  Data:   $Data"
Write-Host "  Cache:  $Cache"

# Delete data and cache
if (Test-Path $Data)  { Remove-Item -Recurse -Force $Data }
if (Test-Path $Cache) { Remove-Item -Recurse -Force $Cache }

# Optional: also nuke config (comment out if you want to keep init.lua/init.vim)
if (Test-Path $Config) { Remove-Item -Recurse -Force $Config }

Write-Host "Neovim reset complete."

