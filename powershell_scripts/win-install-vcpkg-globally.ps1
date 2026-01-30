# Stop on errors
$ErrorActionPreference = "Stop"

# Installation directory
$installDir = "C:\Tools"

# Ensure directory exists
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# Clone vcpkg if missing
if (!(Test-Path "$installDir\vcpkg")) {
    git clone --depth=1 https://github.com/microsoft/vcpkg $installDir\vcpkg
}

# Bootstrap vcpkg
& "$installDir\vcpkg\bootstrap-vcpkg.bat"

# Path to Git Bash ~/.bashrc
$gitBashHome = "$env:USERPROFILE\.bashrc"

# Git Bash style path
$vcpkgPath = "/c/Tools/vcpkg"

# Export lines (single-quoted here-string so $PATH is not parsed by PowerShell)
$exportLines = @'
# vcpkg setup
export VCPKG_ROOT=/c/Tools/vcpkg
export PATH="$VCPKG_ROOT:$PATH"
'@

# Ensure ~/.bashrc exists
if (!(Test-Path $gitBashHome)) {
    New-Item -ItemType File -Path $gitBashHome | Out-Null
}

# Append lines if not already present
if (!(Select-String -Path $gitBashHome -Pattern "VCPKG_ROOT" -Quiet)) {
    Add-Content -Path $gitBashHome -Value $exportLines
}

# Verify installation
& "$installDir\vcpkg\vcpkg.exe" version

