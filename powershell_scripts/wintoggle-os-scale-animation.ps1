<#
.SYNOPSIS
    Toggle all Windows OS-level animations ON or OFF.

.DESCRIPTION
    Forces all known animation-related registry settings to ON or OFF.
    Provides clear before/after state output.
#>

$settings = @(
    # Global UI animation mask
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "UserPreferencesMask"
        On   = "9E,3E,07,80,12,00,00,00"
        Off  = "9E,3E,07,80,10,00,00,00"
    },

    # Menu fade/slide delay
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "MenuShowDelay"
        On   = "200"
        Off  = "0"
    },

    # Cursor blink animation
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "CursorBlinkRate"
        On   = "530"
        Off  = "-1"
    },

    # Window minimize/maximize animation
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop\WindowMetrics"
        Name = "MinAnimate"
        On   = "1"
        Off  = "0"
    },

    # Taskbar animations
    [PSCustomObject]@{
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Name = "TaskbarAnimations"
        On   = 1
        Off  = 0
    },

    # Tooltip fade animation
    [PSCustomObject]@{
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Name = "EnableToolTips"
        On   = 1
        Off  = 0
    },

    # Tooltip fade effect
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "ToolTipAnimation"
        On   = "1"
        Off  = "0"
    },

    # Combo box dropdown animation
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "ComboBoxAnimation"
        On   = "1"
        Off  = "0"
    },

    # List box smooth scrolling
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "ListBoxSmoothScrolling"
        On   = "1"
        Off  = "0"
    },

    # Smooth scroll in general UI
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "SmoothScroll"
        On   = "1"
        Off  = "0"
    },

    # Window fade transitions
    [PSCustomObject]@{
        Path = "HKCU:\Control Panel\Desktop"
        Name = "WindowAnimation"
        On   = "1"
        Off  = "0"
    }
)

function Get-AnimationState {
    $result = @{}

    foreach ($s in $settings) {
        try {
            $value = Get-ItemPropertyValue -Path $s.Path -Name $s.Name -ErrorAction Stop
        }
        catch {
            $value = "<missing>"
        }
        $result["$($s.Path)|$($s.Name)"] = $value
    }

    return $result
}

function Set-AnimationState($mode) {
    foreach ($s in $settings) {
        $value = $s.$mode
        try {
            Set-ItemProperty -Path $s.Path -Name $s.Name -Value $value -ErrorAction Stop
        }
        catch {
            Write-Warning "Failed to set $($s.Name)"
        }
    }

    rundll32.exe user32.dll,UpdatePerUserSystemParameters
}

# Determine current state based on MinAnimate
$current = (Get-ItemPropertyValue -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name MinAnimate) -eq "1"
$mode = if ($current) { "Off" } else { "On" }

Write-Host ""
Write-Host "=== Windows Animation Toggle ===" -ForegroundColor Cyan
Write-Host "Current animation state: " -NoNewline
Write-Host ($(if ($current) { "ON" } else { "OFF" })) -ForegroundColor Yellow
Write-Host "Toggling animations: $mode" -ForegroundColor Green
Write-Host ""

$before = Get-AnimationState
Set-AnimationState $mode
$after = Get-AnimationState

Write-Host "=== Changes Applied ===" -ForegroundColor Cyan
$rows = foreach ($key in $before.Keys) {
    [PSCustomObject]@{
        Setting = $key
        Before  = $before[$key]
        After   = $after[$key]
    }
}

$rows | Format-Table -AutoSize

Write-Host ""
Write-Host "Done. Some changes may require signing out to fully apply." -ForegroundColor Green

