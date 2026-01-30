# Define paths
$wezConfigDir = "$env:USERPROFILE\.wezterm"
$wezConfigFile = Join-Path $wezConfigDir "wezterm.lua"

# Ensure config directory exists
if (!(Test-Path $wezConfigDir)) {
    New-Item -ItemType Directory -Path $wezConfigDir | Out-Null
}

# Path to Git Bash
$gitBashPath = "C:/Program Files/Git/bin/bash.exe"

# Lua config content
$configContent = @"
local wezterm = require 'wezterm'

return {
  default_prog = { "$gitBashPath", "-l" }
}
"@

# Write to wezterm.lua
Set-Content -Path $wezConfigFile -Value $configContent -Encoding UTF8

Write-Host "WezTerm default shell set to Git Bash."

