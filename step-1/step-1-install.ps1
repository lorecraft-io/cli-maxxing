#Requires -Version 5.1
<#
.SYNOPSIS
    Step 1 - Get Claude Running (Windows)
.DESCRIPTION
    Installs Git, Node.js, Warp Terminal, and Claude Code on Windows 10/11
    Uses winget (built into Windows 10 1709+ and Windows 11)
.USAGE
    irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-1/step-1-install.ps1 | iex
#>

$ErrorActionPreference = "Continue"
$script:Errors = 0

# --- Output helpers ---
function Write-Info    { param([string]$Msg) Write-Host "[INFO] $Msg" -ForegroundColor Blue }
function Write-Ok      { param([string]$Msg) Write-Host "[OK]   $Msg" -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host "[WARN] $Msg" -ForegroundColor Yellow }
function Write-Fail    { param([string]$Msg) Write-Host "[FAIL] $Msg" -ForegroundColor Red; exit 1 }
function Write-SoftFail { param([string]$Msg) Write-Host "[FAIL] $Msg (non-critical, continuing...)" -ForegroundColor Red; $script:Errors++ }

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ==========================================================================
# 1. Preflight checks
# ==========================================================================
function Test-Preflight {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Fail "Do not run this script as Administrator. Run as your normal user account."
    }

    $build = [System.Environment]::OSVersion.Version.Build
    if ($build -lt 16299) {
        Write-Fail "Windows 10 version 1709 or later is required (build 16299+). Current build: $build"
    }
    Write-Ok "Windows build $build meets requirements"

    try {
        $null = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/" -UseBasicParsing -TimeoutSec 5
        Write-Ok "Internet connectivity verified"
    } catch {
        Write-Fail "No internet connection detected. This script requires internet access."
    }
}

# ==========================================================================
# 2. winget
# ==========================================================================
function Install-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Ok "winget already available"
    } else {
        Write-Info "winget not found. Attempting to install..."
        try {
            Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
            Refresh-Path
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                Write-Ok "winget installed"
            } else {
                Write-Fail "Could not install winget. Install 'App Installer' from the Microsoft Store, then re-run."
            }
        } catch {
            Write-Fail "Could not install winget. Install 'App Installer' from the Microsoft Store, then re-run."
        }
    }
}

# --- Generic winget install helper ---
function Install-WithWinget {
    param(
        [string]$PackageId,
        [string]$DisplayName,
        [string]$TestCommand,
        [bool]$Critical = $false
    )

    if (Get-Command $TestCommand -ErrorAction SilentlyContinue) {
        Write-Ok "$DisplayName already installed"
        return
    }

    Write-Info "Installing $DisplayName..."
    winget install --id $PackageId --accept-source-agreements --accept-package-agreements --silent 2>$null
    Refresh-Path

    if (Get-Command $TestCommand -ErrorAction SilentlyContinue) {
        Write-Ok "$DisplayName installed"
    } elseif ($Critical) {
        Write-Fail "$DisplayName installation failed"
    } else {
        Write-SoftFail "$DisplayName installation failed"
    }
}

# ==========================================================================
# 3. Git
# ==========================================================================
function Install-Git {
    Install-WithWinget -PackageId "Git.Git" -DisplayName "Git" -TestCommand "git" -Critical $true
}

# ==========================================================================
# 4. Node.js (LTS)
# ==========================================================================
function Install-Node {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeMajor = (node -v) -replace 'v(\d+)\..*', '$1'
        if ([int]$nodeMajor -ge 18) {
            Write-Ok "Node.js $(node -v) already installed (meets v18+ requirement)"
            return
        } else {
            Write-Warn "Node.js $(node -v) found but too old. Need v18+. Installing LTS..."
        }
    }

    Write-Info "Installing Node.js LTS..."
    winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements --silent 2>$null
    Refresh-Path

    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Ok "Node.js $(node -v) installed"
    } else {
        Write-Fail "Node.js installation failed"
    }
}

# ==========================================================================
# 5. Warp Terminal
# ==========================================================================
function Install-Warp {
    $warpPath = "$env:LOCALAPPDATA\Programs\Warp\Warp.exe"
    if (Test-Path $warpPath) {
        Write-Ok "Warp Terminal already installed"
        return
    }
    if (Get-Command warp -ErrorAction SilentlyContinue) {
        Write-Ok "Warp Terminal already installed"
        return
    }

    Write-Info "Installing Warp Terminal..."
    winget install --id Warp.Warp --accept-source-agreements --accept-package-agreements --silent 2>$null
    Refresh-Path

    if ((Test-Path $warpPath) -or (Get-Command warp -ErrorAction SilentlyContinue)) {
        Write-Ok "Warp Terminal installed"
        Write-Host ""
        Write-Host "  ==========================================================" -ForegroundColor Blue
        Write-Host "    Why Warp?" -ForegroundColor Blue
        Write-Host "  ==========================================================" -ForegroundColor Blue
        Write-Host ""
        Write-Host "  Warp is your new terminal for working with Claude."
        Write-Host ""
        Write-Host "  The key feature: press " -NoNewline
        Write-Host "Shift+Tab" -ForegroundColor Green -NoNewline
        Write-Host " while Claude is"
        Write-Host "  running to toggle permissions on and off."
        Write-Host ""
        Write-Host "  After this script finishes, open Warp and run all"
        Write-Host "  future commands from there."
        Write-Host ""
        Write-Host "  ==========================================================" -ForegroundColor Blue
    } else {
        Write-SoftFail "Warp Terminal installation failed. Install manually: https://www.warp.dev"
    }
}

# ==========================================================================
# 6. Claude Code
# ==========================================================================
function Install-ClaudeCode {
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Write-Ok "Claude Code already installed"
    } else {
        Write-Info "Installing Claude Code..."
        npm install -g @anthropic-ai/claude-code 2>$null
        Refresh-Path

        if (Get-Command claude -ErrorAction SilentlyContinue) {
            Write-Ok "Claude Code installed"
        } else {
            Write-Fail "Claude Code installation failed"
        }
    }

    # Add cskip function to PowerShell profile
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path $profilePath -Parent
    if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    if (!(Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }

    if (!(Select-String -Path $profilePath -Pattern "cskip" -Quiet -ErrorAction SilentlyContinue)) {
        Write-Info "Adding 'cskip' shortcut to PowerShell profile..."
        Add-Content -Path $profilePath -Value "`n# Claude Code shortcuts`nfunction cskip { claude --dangerously-skip-permissions @args }"
        Write-Ok "Shortcut added: type 'cskip' to launch Claude (auto-approve mode)"
    } else {
        Write-Ok "cskip shortcut already configured"
    }
}

# ==========================================================================
# Self-test
# ==========================================================================
function Test-AllTools {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host "    Running Self-Test" -ForegroundColor Blue
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host ""

    $pass = 0
    $fail = 0

    # Git
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Ok "TEST: Git - $(git --version)"
        $pass++
    } else { Write-SoftFail "TEST: Git - not found"; $fail++ }

    # Node
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeMajor = (node -v) -replace 'v(\d+)\..*', '$1'
        if ([int]$nodeMajor -ge 18) {
            Write-Ok "TEST: Node.js $(node -v) - meets v18+ requirement"
            $pass++
        } else { Write-SoftFail "TEST: Node.js $(node -v) - too old, need v18+"; $fail++ }
    } else { Write-SoftFail "TEST: Node.js - not found"; $fail++ }

    # npm
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        Write-Ok "TEST: npm v$(npm -v)"
        $pass++
    } else { Write-SoftFail "TEST: npm - not found"; $fail++ }

    # Warp
    $warpPath = "$env:LOCALAPPDATA\Programs\Warp\Warp.exe"
    if ((Test-Path $warpPath) -or (Get-Command warp -ErrorAction SilentlyContinue)) {
        Write-Ok "TEST: Warp Terminal - installed"
        $pass++
    } else { Write-SoftFail "TEST: Warp Terminal - not found"; $fail++ }

    # Claude
    if (Get-Command claude -ErrorAction SilentlyContinue) {
        Write-Ok "TEST: Claude Code - $(claude --version 2>$null)"
        $pass++
    } else { Write-SoftFail "TEST: Claude Code - not found"; $fail++ }

    # cskip
    $profilePath = $PROFILE.CurrentUserAllHosts
    if ((Test-Path $profilePath) -and (Select-String -Path $profilePath -Pattern "cskip" -Quiet -ErrorAction SilentlyContinue)) {
        Write-Ok "TEST: cskip shortcut - configured"
        $pass++
    } else { Write-SoftFail "TEST: cskip shortcut - not found in profile"; $fail++ }

    Write-Host ""
    if ($fail -eq 0) {
        Write-Host "  All $pass tests passed." -ForegroundColor Green
    } else {
        Write-Host "  $pass passed, $fail failed." -ForegroundColor Yellow
        Write-Host "  Scroll up to see what went wrong." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
}

# ==========================================================================
# Summary
# ==========================================================================
function Show-Summary {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host "    Step 1 Complete - Claude is Ready" -ForegroundColor Green
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Installed:"
    Write-Host "    Git            $(git --version 2>$null)"
    Write-Host "    Node.js        $(node -v 2>$null)"
    Write-Host "    npm            v$(npm -v 2>$null)"

    $warpPath = "$env:LOCALAPPDATA\Programs\Warp\Warp.exe"
    if ((Test-Path $warpPath) -or (Get-Command warp -EA Silent)) {
        Write-Host "    Warp Terminal  installed"
    } else {
        Write-Host "    Warp Terminal  -" -ForegroundColor DarkGray
    }
    Write-Host "    Claude Code    $(claude --version 2>$null)"

    Write-Host ""
    if ($script:Errors -gt 0) {
        Write-Host "  Warnings: $($script:Errors) non-critical tool(s) failed to install." -ForegroundColor Yellow
        Write-Host "  Scroll up to see which ones and install them manually." -ForegroundColor Yellow
        Write-Host ""
    }
    Write-Host "  ==========================================================" -ForegroundColor Green
}

# ==========================================================================
# Next steps
# ==========================================================================
function Show-NextSteps {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Yellow
    Write-Host "    NEXT: Set Up Warp, Then Move to Step 2" -ForegroundColor Yellow
    Write-Host "  ==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Press " -NoNewline
    Write-Host "Ctrl+C" -ForegroundColor Green -NoNewline
    Write-Host " if anything is still running,"
    Write-Host "     then close this window."
    Write-Host ""
    Write-Host "  2. Open " -NoNewline
    Write-Host "Warp" -ForegroundColor Green -NoNewline
    Write-Host " (it was just installed)."
    Write-Host ""
    Write-Host "  3. If Warp asks to create an account, sign up."
    Write-Host "     The free plan is all you need."
    Write-Host ""
    Write-Host "  4. Go to Warp settings (Ctrl+Comma):"
    Write-Host "     -> Features -> Default Mode -> set to " -NoNewline
    Write-Host "Terminal" -ForegroundColor Green
    Write-Host ""
    Write-Host "     If you see 'Agent Oz' instead of a terminal,"
    Write-Host "     just press " -NoNewline
    Write-Host "Esc" -ForegroundColor Green -NoNewline
    Write-Host " to switch to the terminal view."
    Write-Host ""
    Write-Host "  5. Set up your Claude account at claude.ai"
    Write-Host "     (you need a paid subscription, see the README)."
    Write-Host ""
    Write-Host "  6. Continue to Step 2 in the README."
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Yellow
}

# ==========================================================================
# Main
# ==========================================================================
function Main {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host "    Step 1 - Get Claude Running (Windows)" -ForegroundColor Blue
    Write-Host "    5 tools - Windows 10/11" -ForegroundColor Blue
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  Note: This script installs everything automatically, but" -ForegroundColor Yellow
    Write-Host "  the steps AFTER it finishes (Warp setup, Claude login) are" -ForegroundColor Yellow
    Write-Host "  manual. Claude won't be helping in your terminal yet." -ForegroundColor Yellow
    Write-Host "  That starts after you complete the setup steps below." -ForegroundColor Yellow
    Write-Host ""

    Test-Preflight
    Install-Winget
    Install-Git
    Install-Node
    Install-Warp
    Install-ClaudeCode
    Test-AllTools
    Show-Summary
    Show-NextSteps
}

Main
