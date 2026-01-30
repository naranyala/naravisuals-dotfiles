# Ensure script runs with TLS 1.2 (required for secure downloads)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Allow PowerShell to run remote scripts temporarily
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Install Scoop
iwr -useb get.scoop.sh | iex

# (Optional) Install recommended buckets
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts

Write-Host "Scoop installation completed successfully!"

