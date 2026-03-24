#Requires -Version 5.1
<#
.SYNOPSIS
    Step 4 - Design Tools (Windows)
.DESCRIPTION
    Installs UI/UX Pro Max Skill and 21st.dev Magic MCP on Windows
.USAGE
    irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-4/step-4-install.ps1 | iex
#>

$ErrorActionPreference = "Continue"
$script:Errors = 0

function Write-Info    { param([string]$Msg) Write-Host "[INFO] $Msg" -ForegroundColor Blue }
function Write-Ok      { param([string]$Msg) Write-Host "[OK]   $Msg" -ForegroundColor Green }
function Write-Warn    { param([string]$Msg) Write-Host "[WARN] $Msg" -ForegroundColor Yellow }
function Write-Fail    { param([string]$Msg) Write-Host "[FAIL] $Msg" -ForegroundColor Red; exit 1 }
function Write-SoftFail { param([string]$Msg) Write-Host "[FAIL] $Msg (non-critical, continuing...)" -ForegroundColor Red; $script:Errors++ }

function Test-Prerequisites {
    if (!(Get-Command node -ErrorAction SilentlyContinue)) { Write-Fail "Node.js not found. Run Step 1 first." }
    if (!(Get-Command claude -ErrorAction SilentlyContinue)) { Write-Fail "Claude Code not found. Run Step 1 first." }
    Write-Ok "Prerequisites verified"
}

function Install-UIUXSkill {
    $skillDir = "$env:USERPROFILE\.claude\skills\ui-ux-pro-max"
    $skillFile = "$skillDir\SKILL.md"

    if (Test-Path $skillFile) {
        Write-Ok "UI/UX Pro Max Skill already installed"
        return
    }

    Write-Info "Installing UI/UX Pro Max Skill..."
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null

    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nextlevelbuilder/ui-ux-pro-max-skill/main/SKILL.md" -OutFile $skillFile -UseBasicParsing
        if (Test-Path $skillFile) {
            Write-Ok "UI/UX Pro Max Skill installed"
        } else {
            Write-SoftFail "Could not download skill. Install manually from: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill"
        }
    } catch {
        Write-SoftFail "Could not download skill. Install manually from: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill"
    }
}

function Install-21stMagic {
    $mcpList = claude mcp list 2>$null
    if ($mcpList -match "magic|21st") {
        Write-Ok "21st.dev Magic MCP already configured"
        return
    }

    Write-Info "Adding 21st.dev Magic MCP to Claude Code..."
    claude mcp add magic -- npx -y @21st-dev/magic@latest 2>$null

    $mcpList2 = claude mcp list 2>$null
    if ($mcpList2 -match "magic|21st") {
        Write-Ok "21st.dev Magic MCP configured"
    } else {
        Write-Warn "Could not auto-configure Magic MCP. Set up manually at https://21st.dev"
    }
}

function Test-AllTools {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host "    Running Self-Test" -ForegroundColor Blue
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host ""

    $pass = 0; $fail = 0

    if (Test-Path "$env:USERPROFILE\.claude\skills\ui-ux-pro-max\SKILL.md") {
        Write-Ok "TEST: UI/UX Pro Max Skill installed"; $pass++
    } else { Write-SoftFail "TEST: UI/UX Pro Max Skill not found"; $fail++ }

    $mcpList = claude mcp list 2>$null
    if ($mcpList -match "magic|21st") {
        Write-Ok "TEST: 21st.dev Magic MCP configured"; $pass++
    } else {
        Write-Warn "TEST: 21st.dev Magic MCP may need manual setup"; $pass++
    }

    Write-Host ""
    if ($fail -eq 0) { Write-Host "  All $pass tests passed." -ForegroundColor Green }
    else { Write-Host "  $pass passed, $fail failed." -ForegroundColor Yellow }
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
}

function Show-Summary {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host "    Step 4 Complete - Design Tools Ready" -ForegroundColor Green
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Don't forget to set up your free 21st.dev account at https://21st.dev"
    Write-Host "  and follow their MCP setup instructions."
    Write-Host ""
    Write-Host "  Check the README for more steps as they're added."
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Green
}

function Main {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host "    Step 4 - Design Tools (Windows)" -ForegroundColor Blue
    Write-Host "    UI/UX Pro Max + 21st.dev Magic" -ForegroundColor Blue
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host ""

    Test-Prerequisites
    Install-UIUXSkill
    Install-21stMagic
    Test-AllTools
    Show-Summary
}

Main
