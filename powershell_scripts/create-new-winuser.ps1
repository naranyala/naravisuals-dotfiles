# Run this script as Administrator

Write-Host "=== Create New Local User Account ==="

# Ask for new username
$newUser = Read-Host "Enter the new username"

# Ask for password securely
$password = Read-Host "Enter password for $newUser" -AsSecureString

# Ask if the user should be an Administrator
$isAdmin = Read-Host "Should this user be an Administrator? (y/n)"

# Create the new local user
New-LocalUser -Name $newUser -Password $password -FullName $newUser -Description "Created via PowerShell script"

Write-Host "User account $newUser created successfully."

# Add to Administrators group if requested
if ($isAdmin -eq "y") {
    Add-LocalGroupMember -Group "Administrators" -Member $newUser
    Write-Host "$newUser added to Administrators group."
} else {
    Write-Host "$newUser is a standard user."
}

Write-Host "You can now log in as $newUser. A profile folder will be created at first login."

