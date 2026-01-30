
# Fix-System32Path.ps1
# Ensures C:\Windows\System32 is in PATH for Scoop to work

Write-Host "Checking PATH for C:\Windows\System32..."

# Get current PATH from system environment variables
$path = [Environment]::GetEnvironmentVariable("Path", "Machine")

if ($path -like "*C:\Windows\System32*") {
    Write-Host "✅ System32 is already in PATH."
} else {
    Write-Host "⚠️ System32 not found in PATH. Adding it now..."

    # Append System32 to PATH
    $newPath = $path + ";C:\Windows\System32"

    # Update system PATH permanently
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

    Write-Host "✅ System32 has been added to PATH."
    Write-Host "ℹ️ Please restart your shell or computer for changes to take effect."
}

# Quick test
if (Test-Path "C:\Windows\System32\Robocopy.exe") {
    Write-Host "Robocopy.exe exists at C:\Windows\System32."
} else {
    Write-Host "❌ Robocopy.exe not found — check your Windows installation."
}
