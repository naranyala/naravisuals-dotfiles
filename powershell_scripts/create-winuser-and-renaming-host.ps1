# Run as Administrator
$newUser = "NewUser"
$password = Read-Host -AsSecureString "Enter password for $newUser"

New-LocalUser -Name $newUser -Password $password -FullName $newUser -Description "Renamed account"
Add-LocalGroupMember -Group "Administrators" -Member $newUser

