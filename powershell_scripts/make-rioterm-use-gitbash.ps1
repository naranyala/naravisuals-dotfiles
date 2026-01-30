$rioConfigDir  = Join-Path $env:USERPROFILE "AppData\Local\rio"
$rioConfigFile = Join-Path $rioConfigDir "config.toml"
$gitBashExe    = "C:\\Program Files\\Git\\git-bash.exe"

if (-not (Test-Path $rioConfigDir)) {
    New-Item -ItemType Directory -Path $rioConfigDir -Force | Out-Null
}

if (-not (Test-Path $gitBashExe)) {
    Write-Error "Git Bash not found at $gitBashExe"
    exit 1
}

# Backup existing config
if (Test-Path $rioConfigFile) {
    $backupFile = $rioConfigFile + ".bak_" + (Get-Date -Format "yyyyMMddHHmmss")
    Copy-Item $rioConfigFile $backupFile
    Write-Output "Backup created: $backupFile"
}

# Write corrected config
$configContent = @"
[shell]
program = "$gitBashExe"
args = []

[profiles.gitbash]
program = "$gitBashExe"
args = []

[bindings]
"ctrl+shift+t" = "new_tab:gitbash"
"@

Set-Content -Path $rioConfigFile -Value $configContent -Encoding UTF8
Write-Output "Rio config fixed. Git Bash is now default and bound to Ctrl+Shift+T."

