# Define paths
$wezConfig   = "$env:USERPROFILE\.wezterm.lua"
$gitBashPath = "C:\\Program Files\\Git\\bin\\bash.exe"
$bashProfile = "$env:USERPROFILE\\.bash_profile"
$bashrc      = "$env:USERPROFILE\\.bashrc"

# --- Step 1: Backup existing WezTerm config if present ---
if (Test-Path $wezConfig) {
    $backupPath = "$wezConfig.bak"
    Copy-Item $wezConfig $backupPath -Force
    Write-Host "Existing WezTerm config backed up to $backupPath"
}

# --- Step 2: Write new WezTerm config to use Git Bash ---
$configContent = @"
local wezterm = require 'wezterm'

return {
  default_prog = { "$gitBashPath", "-l" },
}
"@

Set-Content -Path $wezConfig -Value $configContent -Encoding UTF8
Write-Host "WezTerm config updated. Git Bash is now the default shell."

# --- Step 3: Ensure ~/.bash_profile exists and sources ~/.bashrc ---
if (-not (Test-Path $bashProfile)) {
    $profileContent = @"
# ~/.bash_profile created by PowerShell script
# Ensures login shells also load ~/.bashrc

if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
"@
    Set-Content -Path $bashProfile -Value $profileContent -Encoding UTF8
    Write-Host "Created ~/.bash_profile to source ~/.bashrc (fixes Bash warning)."
} else {
    Write-Host "~/.bash_profile already exists. No changes made."
}

# --- Step 4: Inform user if ~/.bashrc is missing ---
if (-not (Test-Path $bashrc)) {
    Write-Host "Note: ~/.bashrc not found. You may want to create one for your shell settings."
}

