# install-system-dev-tools-scoop.ps1
# System programming toolkit using Scoop.sh (https://scoop.sh)

# Ensure we're in a PowerShell session that supports TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Auto-install Scoop if not present
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "🔍 Scoop not found. Installing..." -ForegroundColor Cyan
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install Scoop." -ForegroundColor Red
        exit 1
    }
}

# Ensure essential buckets are added
$requiredBuckets = @('main', 'extras', 'versions', 'nerd-fonts')
foreach ($bucket in $requiredBuckets) {
    if (-not (scoop bucket list | Select-String -Pattern "^\s*$bucket\b")) {
        Write-Host "📦 Adding bucket: $bucket" -ForegroundColor Yellow
        scoop bucket add $bucket
    }
}

# Optional: Add specialized buckets (uncomment if needed)
# scoop bucket add devtools https://github.com/ScoopInstaller/DevTools
# scoop bucket add sysinternals https://github.com/yeroc/scoop-sysinternals

# Define tools by category
$cliTools = @(
    # -------------------------
    # 🐚 Shell & Terminal
    # -------------------------
    'git',
    'gh',                    # GitHub CLI
    'powershell',
    'windows-terminal',      # from 'extras'
    'starship',              # cross-shell prompt
    'zoxide',                # smarter cd
    'fzf',
    'ripgrep',
    'fd',
    'bat',
    'delta',
    'eza',                   # modern ls (replaces exa)
    'atuin',                 # shell history with sync & search

    # -------------------------
    # ⚙️ Compilers & Runtimes
    # -------------------------
    'gcc',                   # via mingw (from 'main')
    'clang',                 # from 'main'
    'rust',                  # includes cargo
    'zig',                   # from 'versions' or 'extras'
    'go',
    'nodejs-lts',
    'python',
    'openjdk',               # or use 'temurin-jdk' from extras
    'dotnet-sdk',

    # -------------------------
    # 🛠️ Build & Dev Tools
    # -------------------------
    'cmake',
    'ninja',
    'make',
    'nasm',                  # Netwide Assembler
    'yasm',
    'sccache',               # Rust/C++ compilation cache
    'just',                  # command runner (like Make)

    # -------------------------
    # 🔍 Debugging & RE
    # -------------------------
    'gdb',                   # GNU Debugger (via mingw)
    'pdb',                   # Python debugger (via python)
    'radare2',               # from 'extras'
    'pe-bear',               # PE analyzer (if available; else skip)
    # Note: Ghidra/x64dbg not in Scoop (use Winget or manual install)

    # -------------------------
    # 🌐 Networking & System
    # -------------------------
    'nmap',
    'wget',
    'curl',
    'jq',
    'yq',
    'httpie',
    'dnsx',                  # from 'extras' (if added via community buckets)
    'sysinternals',          # from 'extras' — includes procexp, procmon, etc.

    # -------------------------
    # 🐳 Containers & Cloud
    # -------------------------
    'docker-cli',
    'kubernetes-cli',
    'helm',
    'aws-cli',
    'azure-cli',
    'gcloud',                # Google Cloud CLI

    # -------------------------
    # 🎨 Optional: Nerd Fonts (for dev terminals)
    # -------------------------
    # 'firacode-nerd-font',  # Uncomment if you want beautiful dev fonts
)

# Normalize: Remove duplicates and filter out comments
$cliTools = $cliTools | Where-Object { $_ -notmatch '^#' } | Sort-Object -Unique

Write-Host "🚀 Installing system programming tools via Scoop..." -ForegroundColor Cyan

foreach ($tool in $cliTools) {
    Write-Host "`n➡️  Processing: $tool" -ForegroundColor Yellow

    # Check if already installed
    $installed = scoop list | Select-String -Pattern "^\s*$tool\b"
    if ($installed) {
        Write-Host "✅ Already installed: $tool" -ForegroundColor Green
    } else {
        Write-Host "📦 Installing: $tool..." -ForegroundColor Magenta
        scoop install $tool --global 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✔️  Success: $tool" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Failed: $tool (not found or install error)" -ForegroundColor Red
        }
    }
}

# Post-install: Refresh environment
Write-Host "`n🔄 Refreshing environment..." -ForegroundColor Cyan
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "`n🎯 Scoop-based system dev toolkit installed!" -ForegroundColor Cyan
Write-Host "💡 Restart your terminal or run 'refreshenv' (if you have it) to update PATH." -ForegroundColor Gray

# Optional: Install 'refreshenv' if not present
if (-not (Get-Command refreshenv -ErrorAction SilentlyContinue)) {
    Write-Host "ℹ️  Tip: Run 'scoop install sudo' then 'sudo refreshenv' to reload PATH." -ForegroundColor Yellow
}
