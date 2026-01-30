# Update Windows Terminal settings.json to add duplicateTab shortcut
# Adds PowerShell helper function "new-tab" to profile
# Validates JSON before and after update, shows line numbers for trailing commas

$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Backup first
Copy-Item $settingsPath "$settingsPath.bak" -Force

# Read raw JSON
$jsonLines = Get-Content $settingsPath
$jsonText  = $jsonLines -join "`n"

# --- Validation step ---
$valid = $true
try {
    $null = $jsonText | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Host "❌ JSON is invalid before update"
    Write-Host "Error details:" $_.Exception.Message
    $valid = $false
}

# Regex check for trailing commas, with line numbers
for ($i = 0; $i -lt $jsonLines.Count; $i++) {
    if ($jsonLines[$i] -match ",\s*[\}\]]") {
        Write-Host "⚠️ Possible trailing comma at line $($i+1):"
        Write-Host "    $($jsonLines[$i])"
        $valid = $false
    }
}

if (-not $valid) {
    Write-Host "Aborting update. Please fix JSON first."
    exit 1
}

# --- Safe update ---
$json = $jsonText | ConvertFrom-Json

# Ensure actions is always an array
if (-not $json.PSObject.Properties.Name.Contains("actions")) {
    $json | Add-Member -MemberType NoteProperty -Name actions -Value @()
}
elseif (-not ($json.actions -is [System.Collections.IEnumerable])) {
    $json.actions = @()
}

# Check if duplicateTab already exists
$exists = $json.actions | Where-Object { $_.command -eq "duplicateTab" }

if (-not $exists) {
    $newAction = @{
        command = "duplicateTab"
        keys    = "ctrl+shift+d"
    }
    $json.actions = @($json.actions + $newAction)
}

# Write back clean JSON
$json | ConvertTo-Json -Depth 10 -Compress | Set-Content $settingsPath -Encoding UTF8

# Post-write validation
try {
    $null = (Get-Content $settingsPath -Raw) | ConvertFrom-Json -ErrorAction Stop
    Write-Host "✅ Windows Terminal settings updated successfully. Backup saved as settings.json.bak"
}
catch {
    Write-Host "❌ JSON became invalid after update!"
    Write-Host "Error details:" $_.Exception.Message
    exit 1
}

# --- Add PowerShell helper function ---
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$profileContent = Get-Content $profilePath -Raw
if ($profileContent -notmatch "function\s+new-tab") {
    Add-Content $profilePath @'
function new-tab {
    wt -d $PWD
}
'@
    Write-Host "✅ Added 'new-tab' function to your PowerShell profile."
}
else {
    Write-Host "ℹ️ 'new-tab' function already exists in your profile."
}

