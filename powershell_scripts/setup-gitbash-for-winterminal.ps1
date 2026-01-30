# Path to Windows Terminal settings.json
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

# Read existing JSON
$json = Get-Content $settingsPath -Raw | ConvertFrom-Json

# Generate a new GUID for the profile
$newGuid = [guid]::NewGuid().ToString()

# Define Git Bash profile
$gitBashProfile = @{
    guid = $newGuid
    name = "Git Bash"
    commandline = "C:/Program Files/Git/bin/bash.exe -l"
    icon = "C:/Program Files/Git/mingw64/share/git/git-for-windows.ico"
    startingDirectory = "%USERPROFILE%"
}

# Add profile to list
$json.profiles.list += $gitBashProfile

# Convert back to JSON and save
$json | ConvertTo-Json -Depth 5 | Set-Content $settingsPath -Encoding UTF8

Write-Host "Git Bash profile added to Windows Terminal."

