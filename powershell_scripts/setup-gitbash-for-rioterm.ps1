# Define Rio config directory (adjust if installed elsewhere)
$rioConfigDir = "$env:USERPROFILE\.config\rio"
$rioConfigFile = Join-Path $rioConfigDir "config.toml"

# Ensure config directory exists
if (!(Test-Path $rioConfigDir)) {
    New-Item -ItemType Directory -Path $rioConfigDir | Out-Null
}

# Path to Git Bash executable
$gitBashPath = "C:/Program Files/Git/bin/bash.exe"

# TOML config content for Rio
$configContent = @"
[shell]
default = "$gitBashPath"
args = ["-l"]
"@

# Write to config.toml
Set-Content -Path $rioConfigFile -Value $configContent -Encoding UTF8

Write-Host "Rio Terminal default shell set to Git Bash."

