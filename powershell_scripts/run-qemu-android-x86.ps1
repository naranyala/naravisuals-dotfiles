param(
    [Parameter(Mandatory = $true)]
    [string]$IsoPath
)

# -------------------------------
# Validate ISO file
# -------------------------------
if (!(Test-Path $IsoPath)) {
    Write-Error "The ISO file '$IsoPath' does not exist. Please check the path."
    exit 1
}

# -------------------------------
# Locate QEMU executables
# -------------------------------
$qemuPath = "C:\Program Files\qemu\qemu-system-x86_64.exe"
$qemuImgPath = "C:\Program Files\qemu\qemu-img.exe"

if (!(Test-Path $qemuPath)) {
    Write-Error "qemu-system-x86_64.exe not found at '$qemuPath'. Install QEMU or update the script path."
    exit 1
}

if (!(Test-Path $qemuImgPath)) {
    Write-Error "qemu-img.exe not found at '$qemuImgPath'. Install QEMU or update the script path."
    exit 1
}

# -------------------------------
# Create virtual disk if missing
# -------------------------------
$disk = "android.img"

if (!(Test-Path $disk)) {
    Write-Host "Creating virtual disk ($disk)..."
    & $qemuImgPath create -f qcow2 $disk 8G

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create virtual disk. qemu-img returned error code $LASTEXITCODE."
        exit 1
    }
}

# -------------------------------
# Launch QEMU
# -------------------------------
Write-Host "Launching Android-x86 in QEMU..."

& $qemuPath `
    -m 2048 `
    -smp 4 `
    -cdrom $IsoPath `
    -hda $disk `
    -boot d `
    -net nic `
    -net user `
    -vga virtio `
    -device virtio-mouse-pci `
    -device virtio-keyboard-pci

if ($LASTEXITCODE -ne 0) {
    Write-Error "QEMU exited with error code $LASTEXITCODE."
    exit 1
}

