#Requires -Version 5.1
<#
.SYNOPSIS
    Script 0 — Client Environment Setup (Windows)
.DESCRIPTION
    Installs all prerequisites + Claude Code on Windows 10/11
    Uses winget (built into Windows 10 1709+ and Windows 11)
.USAGE
    irm https://raw.githubusercontent.com/lorecraft-io/client-setup/main/script-0-install.ps1 | iex
#>

$ErrorActionPreference = "Continue"
$script:Errors = 0

# --- Output helpers ---
function Write-Info    { param([string]$Msg) Write-Host "[INFO] $Msg" -ForegroundColor Blue }
function Write-Ok      { param([string]$Msg) Write-Host "[OK]   $Msg" -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host "[WARN] $Msg" -ForegroundColor Yellow }
function Write-Fail    { param([string]$Msg) Write-Host "[FAIL] $Msg" -ForegroundColor Red; exit 1 }
function Write-SoftFail { param([string]$Msg) Write-Host "[FAIL] $Msg (non-critical, continuing...)" -ForegroundColor Red; $script:Errors++ }

# --- Refresh PATH within this session ---
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# ==========================================================================
# 1. Preflight checks
# ==========================================================================
function Test-Preflight {
    # Block running as admin — matches the bash script's no-root policy
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Fail "Do not run this script as Administrator. Run as your normal user account."
    }

    # Check Windows version (need Windows 10 1709+ for winget)
    $build = [System.Environment]::OSVersion.Version.Build
    if ($build -lt 16299) {
        Write-Fail "Windows 10 version 1709 or later is required (build 16299+). Current build: $build"
    }
    Write-Ok "Windows build $build meets requirements"

    # Check internet
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
            # winget is part of App Installer — try to get it from the Store
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
            Write-Warn "Node.js $(node -v) found but too old — need v18+. Installing LTS..."
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
# 5. Python 3
# ==========================================================================
function Install-Python {
    if (Get-Command python3 -ErrorAction SilentlyContinue) {
        Write-Ok "Python 3 already installed ($(python3 --version))"
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        $pyVer = (python --version 2>&1).ToString()
        if ($pyVer -match "Python 3") {
            Write-Ok "Python 3 already installed ($pyVer)"
        } else {
            Write-Info "Installing Python 3..."
            winget install --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent 2>$null
            Refresh-Path
        }
    } else {
        Write-Info "Installing Python 3..."
        winget install --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent 2>$null
        Refresh-Path
    }

    # Verify
    $pyCmd = if (Get-Command python3 -ErrorAction SilentlyContinue) { "python3" }
             elseif (Get-Command python -ErrorAction SilentlyContinue) { "python" }
             else { $null }

    if ($pyCmd) {
        Write-Ok "Python available ($pyCmd)"
        # Ensure pip
        & $pyCmd -m pip --version 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Info "Installing pip..."
            & $pyCmd -m ensurepip --upgrade 2>$null
        }
        Write-Ok "pip available"
    } else {
        Write-Fail "Python 3 installation failed"
    }

    # Store which python command works for later use
    $script:PythonCmd = $pyCmd
}

# ==========================================================================
# 6. Pandoc
# ==========================================================================
function Install-Pandoc {
    Install-WithWinget -PackageId "JohnMacFarlane.Pandoc" -DisplayName "Pandoc" -TestCommand "pandoc"
}

# ==========================================================================
# 7. xlsx2csv (pip package)
# ==========================================================================
function Install-Xlsx2csv {
    $check = & $script:PythonCmd -c "import xlsx2csv" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "xlsx2csv already installed"
        return
    }

    Write-Info "Installing xlsx2csv..."
    & $script:PythonCmd -m pip install xlsx2csv --quiet 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Try with --break-system-packages for newer Python
        & $script:PythonCmd -m pip install --break-system-packages xlsx2csv --quiet 2>$null
    }

    $check2 = & $script:PythonCmd -c "import xlsx2csv" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "xlsx2csv installed"
    } else {
        Write-SoftFail "xlsx2csv installation failed"
    }
}

# ==========================================================================
# 8. pdftotext (poppler)
# ==========================================================================
function Install-Pdftotext {
    if (Get-Command pdftotext -ErrorAction SilentlyContinue) {
        Write-Ok "pdftotext already installed"
        return
    }

    Write-Info "Installing poppler (pdftotext)..."
    # winget doesn't have poppler — try chocolatey if available, otherwise skip
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install poppler -y --no-progress 2>$null
        Refresh-Path
        if (Get-Command pdftotext -ErrorAction SilentlyContinue) {
            Write-Ok "pdftotext installed"
        } else {
            Write-SoftFail "pdftotext installation failed — install Chocolatey and run: choco install poppler"
        }
    } else {
        Write-SoftFail "pdftotext requires Chocolatey (choco install poppler) or manual install from: https://github.com/oschwartz10612/poppler-windows/releases"
    }
}

# ==========================================================================
# 9. jq
# ==========================================================================
function Install-Jq {
    Install-WithWinget -PackageId "jqlang.jq" -DisplayName "jq" -TestCommand "jq"
}

# ==========================================================================
# 10. ripgrep
# ==========================================================================
function Install-Ripgrep {
    Install-WithWinget -PackageId "BurntSushi.ripgrep.MSVC" -DisplayName "ripgrep" -TestCommand "rg"
}

# ==========================================================================
# 11. GitHub CLI
# ==========================================================================
function Install-Gh {
    Install-WithWinget -PackageId "GitHub.cli" -DisplayName "GitHub CLI" -TestCommand "gh"
}

# ==========================================================================
# 12. tree (built into Windows)
# ==========================================================================
function Install-Tree {
    # tree.com is built into Windows
    Write-Ok "tree is built into Windows"
}

# ==========================================================================
# 13. fzf
# ==========================================================================
function Install-Fzf {
    Install-WithWinget -PackageId "junegunn.fzf" -DisplayName "fzf" -TestCommand "fzf"
}

# ==========================================================================
# 14. wget
# ==========================================================================
function Install-Wget {
    if (Get-Command wget -ErrorAction SilentlyContinue) {
        Write-Ok "wget already installed"
        return
    }

    # PowerShell aliases wget to Invoke-WebRequest — check for real wget
    $realWget = Get-Command wget.exe -ErrorAction SilentlyContinue
    if ($realWget) {
        Write-Ok "wget already installed"
        return
    }

    Install-WithWinget -PackageId "JernejSimoncic.Wget" -DisplayName "wget" -TestCommand "wget"
}

# ==========================================================================
# 15. Claude Code
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
}

# ==========================================================================
# Auth prompt
# ==========================================================================
function Show-AuthPrompt {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Yellow
    Write-Host "    ACTION REQUIRED: Claude Code Login" -ForegroundColor Yellow
    Write-Host "  ==========================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Run this command to log in:"
    Write-Host ""
    Write-Host "    claude auth login" -ForegroundColor Green
    Write-Host ""
    Write-Host "  This will open a browser window. Sign in with your"
    Write-Host "  Anthropic account and approve the connection."
    Write-Host ""
    Write-Host "  After logging in, verify it worked with:"
    Write-Host ""
    Write-Host "    claude --version" -ForegroundColor Green
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Yellow
}

# ==========================================================================
# Summary
# ==========================================================================
function Show-Summary {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host "    Script 0 Complete - Environment Ready" -ForegroundColor Green
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Installed:"

    $tools = @(
        @("Git",        { git --version 2>$null }),
        @("Node.js",    { node -v 2>$null }),
        @("npm",        { npm -v 2>$null }),
        @("Python",     { & $script:PythonCmd --version 2>$null }),
        @("Pandoc",     { pandoc --version 2>$null | Select-Object -First 1 }),
        @("xlsx2csv",   { & $script:PythonCmd -c "import xlsx2csv; print('installed')" 2>$null }),
        @("pdftotext",  { if (Get-Command pdftotext -EA Silent) { "installed" } else { $null } }),
        @("jq",         { jq --version 2>$null }),
        @("ripgrep",    { rg --version 2>$null | Select-Object -First 1 }),
        @("GitHub CLI", { gh --version 2>$null | Select-Object -First 1 }),
        @("tree",       { "built-in" }),
        @("fzf",        { fzf --version 2>$null }),
        @("wget",       { if (Get-Command wget.exe -EA Silent) { "installed" } else { $null } }),
        @("Claude Code",{ claude --version 2>$null })
    )

    foreach ($tool in $tools) {
        $name = $tool[0].PadRight(15)
        try {
            $ver = & $tool[1]
            if ($ver) {
                Write-Host "    $name $ver"
            } else {
                Write-Host "    $name -" -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "    $name -" -ForegroundColor DarkGray
        }
    }

    Write-Host ""
    if ($script:Errors -gt 0) {
        Write-Host "  Warnings: $($script:Errors) non-critical tool(s) failed to install." -ForegroundColor Yellow
        Write-Host "  Scroll up to see which ones and install them manually." -ForegroundColor Yellow
        Write-Host ""
    }
    Write-Host "  Next steps:"
    Write-Host "    1. Log in to Claude Code (see above)"
    Write-Host "    2. Run Script 1 to set up ClaudeFlow"
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Green
}

# ==========================================================================
# Main
# ==========================================================================
function Main {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host "    Script 0 - Client Environment Setup (Windows)" -ForegroundColor Blue
    Write-Host "    15 tools - Windows 10/11" -ForegroundColor Blue
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host ""

    Test-Preflight
    Install-Winget
    Install-Git
    Install-Node
    Install-Python
    Install-Pandoc
    Install-Xlsx2csv
    Install-Pdftotext
    Install-Jq
    Install-Ripgrep
    Install-Gh
    Install-Tree
    Install-Fzf
    Install-Wget
    Install-ClaudeCode
    Show-AuthPrompt
    Show-Summary
}

Main
