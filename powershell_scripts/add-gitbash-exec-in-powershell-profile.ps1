# === Auto-launch Git Bash when PowerShell starts ===
# Run this script once to add Git Bash auto-launch to your PowerShell profile

# 1. Ensure PowerShell profile exists
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    Write-Host "Creating PowerShell profile at: $profilePath" -ForegroundColor Cyan
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

# 2. Define Git Bash path (adjust if installed elsewhere)
$gitBashExe = "C:\Program Files\Git\bin\bash.exe"

# Verify Git Bash exists
if (-not (Test-Path $gitBashExe)) {
    Write-Warning "Git Bash not found at $gitBashExe"
    Write-Host "Please install Git for Windows: https://git-scm.com/download/win" -ForegroundColor Yellow
    return
}

# 3. Content to add to profile
$profileContentToAdd = @"

# ===== Auto-launch Git Bash (Added on $(Get-Date -Format 'yyyy-MM-dd HH:mm')) =====
& "C:\Program Files\Git\bin\bash.exe" --login -i
# =============================================================================

"@

# 4. Read existing profile content
$existingContent = ""
if (Test-Path $profilePath) {
    $existingContent = Get-Content $profilePath -Raw
}

# 5. Check if already added
if ($existingContent -like "*Auto-launch Git Bash*") {
    Write-Host "[INFO] Git Bash auto-launch already exists in your profile." -ForegroundColor Gray
} else {
    # Append to profile
    Add-Content -Path $profilePath -Value $profileContentToAdd -Encoding UTF8
    Write-Host "[SUCCESS] Git Bash will now launch automatically when you open PowerShell!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Profile location: $profilePath" -ForegroundColor Cyan
Write-Host "To disable: Edit the profile and remove the Git Bash line" -ForegroundColor Gray
