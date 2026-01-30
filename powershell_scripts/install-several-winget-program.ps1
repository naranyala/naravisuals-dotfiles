#requires -Version 5.1
[CmdletBinding()]
param()

# ---------- package list (only non-commented items) ----------
$Packages = @(
    'Microsoft.VisualStudio.VCRedist.2015+.x64'
    'Microsoft.VisualStudio.2022.BuildTools'
    'LLVM.LLVM'
    'Rustlang.Rust'
    'Ziglang.Zig'
    'OpenJS.NodeJS.LTS'
    'Python.Python.3'
    'CMake.CMake'
    'Ninja.Ninja'
    'Microsoft.WindowsTerminal'
    'Microsoft.PowerShell'
    'Git.Git'
    'Microsoft.Sysinternals.ProcessExplorer'
    'Microsoft.Sysinternals.ProcessMonitor'
    'Microsoft.Sysinternals.DebugView'
    'Microsoft.VisualStudio.2022.Debugger'
    'GnuWin32.CoreUtils'
    'BurntSushi.ripgrep'
    'sharkdp.fd'
    'sharkdp.bat'
    'dandavison.delta'
    'junegunn.fzf'
    'Ghidra.Ghidra'
    'x64dbg.x64dbg'
    'RadareOrg.Radare2'
    'PE-bear.PE-bear'
    'Vivisect.Vivisect'
    'WiresharkFoundation.Wireshark'
    'Microsoft.Sysinternals.TCPView'
    'Nmap.Nmap'
    'OpenSSH.OpenSSH.Beta'
    'IPFS.kubo'
    'Docker.DockerCLI'
    'Oracle.VirtualBox'
    'ScoopInstaller.Scoop'
    'Cargo.Cargo'
    'Npm.Npm'
)

# ---------- helper ----------
function Test-WingetAvailable {
    if (-not (Get-Command -Name winget -ErrorAction SilentlyContinue)) {
        Write-Error 'winget not found. Install ''App Installer'' from the Microsoft Store and retry.'
        exit 1
    }
}

function Install-WingetPackage ([string]$id) {
    Write-Host "`n➡️  Checking $id" -ForegroundColor Yellow
    $installed = & winget list --id $id --accept-source-agreements --disable-interactivity 2>$null |
                 Select-String -Pattern [regex]::Escape($id.Split('.')[0])
    if ($installed) {
        Write-Host "✅ Already installed: $id" -ForegroundColor Green
        return
    }

    Write-Host "📦 Installing $id ..." -ForegroundColor Magenta
    & winget install --id $id --accept-package-agreements --accept-source-agreements --silent --disable-interactivity
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✔️  Success: $id" -ForegroundColor Green
    } else {
        Write-Warning "⚠️  Failed: $id (exit code $LASTEXITCODE)"
    }
}

# ---------- main ----------
Test-WingetAvailable
Write-Host '🚀 Setting up system-programming toolkit via winget' -ForegroundColor Cyan

foreach ($pkg in $Packages) { Install-WingetPackage -id $pkg }

# Optional WSL hint
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    Write-Host "`n✅ WSL detected. Optionally run:  wsl --install -d Ubuntu" -ForegroundColor Green
} else {
    Write-Host "`nℹ️  WSL not present. If desired, install WSL with:  wsl --install" -ForegroundColor Yellow
}

Write-Host "`n🎯 Install run complete. Restart your terminal to refresh PATH." -ForegroundColor Cyan
