# Run this script as Administrator

Write-Host "=== Rename Computer Hostname Tool ==="

# Show current hostname
$currentName = $env:COMPUTERNAME
Write-Host "Current hostname: $currentName"

# Ask for new hostname
$newName = Read-Host "Enter the new hostname"

# Confirm action
Write-Host "You are about to rename '$currentName' to '$newName'."
$confirm = Read-Host "Type YES to confirm"

if ($confirm -eq "YES") {
    try {
        Rename-Computer -NewName $newName -Force
        Write-Host "Hostname successfully changed to $newName."
        $restart = Read-Host "Restart now to apply changes? (y/n)"
        if ($restart -eq "y") {
            Restart-Computer
        } else {
            Write-Host "Please restart manually later to apply the new hostname."
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
} else {
    Write-Host "Operation cancelled."
}

