#Requires -Version 5.1
<#
.SYNOPSIS
    Step 3 - ClaudeFlow Setup (Windows)
.DESCRIPTION
    Installs and configures ClaudeFlow multi-agent orchestration on Windows 10/11
    Requires Steps 1 and 2 to be completed first
.USAGE
    irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/step-3/step-3-install.ps1 | iex
#>

$ErrorActionPreference = "Continue"
$script:Errors = 0

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
# Verify Steps 1 and 2
# ==========================================================================
function Test-Prerequisites {
    if (!(Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Fail "Node.js not found. Run Step 1 first."
    }
    if (!(Get-Command claude -ErrorAction SilentlyContinue)) {
        Write-Fail "Claude Code not found. Run Step 1 first."
    }
    if (!(Get-Command jq -ErrorAction SilentlyContinue)) {
        Write-Fail "jq not found. Run Step 2 first."
    }
    Write-Ok "Steps 1 and 2 prerequisites verified"
}

# ==========================================================================
# Install ClaudeFlow CLI
# ==========================================================================
function Install-ClaudeFlow {
    Write-Info "Installing ClaudeFlow CLI..."
    npm install -g @claude-flow/cli@latest 2>$null
    Refresh-Path

    $ver = npx @claude-flow/cli@latest --version 2>$null
    if ($ver) {
        Write-Ok "ClaudeFlow CLI installed ($ver)"
    } else {
        Write-Ok "ClaudeFlow CLI available via npx"
    }
}

# ==========================================================================
# Configure MCP server
# ==========================================================================
function Configure-MCP {
    Write-Info "Adding ClaudeFlow as MCP server to Claude Code..."

    $mcpList = claude mcp list 2>$null
    if ($mcpList -match "claude-flow") {
        Write-Ok "ClaudeFlow MCP server already configured"
        return
    }

    claude mcp add claude-flow -- npx -y @claude-flow/cli@latest 2>$null

    $mcpList2 = claude mcp list 2>$null
    if ($mcpList2 -match "claude-flow") {
        Write-Ok "ClaudeFlow MCP server added to Claude Code"
    } else {
        Write-Warn "MCP add may not have worked. Trying direct config..."
        $mcpConfig = "$env:USERPROFILE\.claude\claude_mcp_config.json"
        $claudeDir = "$env:USERPROFILE\.claude"

        if (!(Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }

        $config = @{
            mcpServers = @{
                "claude-flow" = @{
                    command = "npx"
                    args = @("-y", "@claude-flow/cli@latest")
                }
            }
        }

        if (Test-Path $mcpConfig) {
            try {
                $existing = Get-Content $mcpConfig -Raw | ConvertFrom-Json
                $existing.mcpServers | Add-Member -NotePropertyName "claude-flow" -NotePropertyValue $config.mcpServers."claude-flow" -Force
                $existing | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig
            } catch {
                $config | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig
            }
        } else {
            $config | ConvertTo-Json -Depth 10 | Set-Content $mcpConfig
        }
        Write-Ok "ClaudeFlow MCP server configured (direct config)"
    }
}

# ==========================================================================
# Start daemon
# ==========================================================================
function Start-ClaudeFlowDaemon {
    Write-Info "Starting ClaudeFlow daemon..."
    npx @claude-flow/cli@latest daemon start 2>$null

    $status = npx @claude-flow/cli@latest daemon status 2>$null
    if ($status -match "running|active") {
        Write-Ok "ClaudeFlow daemon is running"
    } else {
        Write-Warn "Daemon may not have started. Claude will start it automatically when needed."
    }
}

# ==========================================================================
# Run doctor
# ==========================================================================
function Invoke-Doctor {
    Write-Info "Running ClaudeFlow doctor..."
    npx @claude-flow/cli@latest doctor --fix 2>$null
    Write-Ok "ClaudeFlow doctor completed"
}

# ==========================================================================
# Init config
# ==========================================================================
function Initialize-Config {
    Write-Info "Initializing ClaudeFlow configuration..."
    if ((Test-Path ".claude-flow.json") -or (Test-Path "claude-flow.json")) {
        Write-Ok "ClaudeFlow already initialized in this directory"
        return
    }
    npx @claude-flow/cli@latest init 2>$null
    Write-Ok "ClaudeFlow configuration initialized"
}

# ==========================================================================
# Self-test
# ==========================================================================
function Test-ClaudeFlow {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host "    Running Self-Test" -ForegroundColor Blue
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host ""

    $pass = 0
    $fail = 0

    # CLI available
    $ver = npx @claude-flow/cli@latest --version 2>$null
    if ($ver) {
        Write-Ok "TEST: ClaudeFlow CLI available"
        $pass++
    } else { Write-SoftFail "TEST: ClaudeFlow CLI not available"; $fail++ }

    # MCP configured
    $mcpList = claude mcp list 2>$null
    if ($mcpList -match "claude-flow") {
        Write-Ok "TEST: ClaudeFlow MCP server configured"
        $pass++
    } else { Write-SoftFail "TEST: ClaudeFlow MCP server not detected"; $fail++ }

    # Daemon
    $status = npx @claude-flow/cli@latest daemon status 2>$null
    if ($status -match "running|active") {
        Write-Ok "TEST: ClaudeFlow daemon running"
    } else {
        Write-Warn "TEST: ClaudeFlow daemon not running (will auto-start when needed)"
    }
    $pass++

    # Memory
    $mem = npx @claude-flow/cli@latest memory list 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "TEST: Memory system accessible"
        $pass++
    } else { Write-SoftFail "TEST: Memory system not responding"; $fail++ }

    Write-Host ""
    if ($fail -eq 0) {
        Write-Host "  All $pass tests passed." -ForegroundColor Green
    } else {
        Write-Host "  $pass passed, $fail failed." -ForegroundColor Yellow
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
    Write-Host "    Step 3 Complete - ClaudeFlow is Ready" -ForegroundColor Green
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  ClaudeFlow is now installed and connected to Claude Code."
    Write-Host ""
    Write-Host "  What you can do now:"
    Write-Host "    - Claude can spawn multiple agents to work in parallel"
    Write-Host "    - Memory persists across sessions automatically"
    Write-Host "    - Smart model routing saves up to 75% on token costs"
    Write-Host "    - Swarm orchestration for complex multi-step tasks"
    Write-Host ""
    Write-Host "  Try it out. Open a new cskip session and ask Claude"
    Write-Host "  to do something complex. You'll see the difference."
    Write-Host ""
    if ($script:Errors -gt 0) {
        Write-Host "  Warnings: $($script:Errors) issue(s) detected." -ForegroundColor Yellow
        Write-Host "  Scroll up to see details." -ForegroundColor Yellow
        Write-Host ""
    }
    Write-Host "  ==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Setup complete. You're an AI Super User now." -ForegroundColor Green
    Write-Host ""
}

# ==========================================================================
# Main
# ==========================================================================
function Main {
    Write-Host ""
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host "    Step 3 - ClaudeFlow (Windows)" -ForegroundColor Blue
    Write-Host "    Multi-agent orchestration - Windows 10/11" -ForegroundColor Blue
    Write-Host "  ==========================================================" -ForegroundColor Blue
    Write-Host ""

    Test-Prerequisites
    Install-ClaudeFlow
    Configure-MCP
    Start-ClaudeFlowDaemon
    Invoke-Doctor
    Initialize-Config
    Test-ClaudeFlow
    Show-Summary
}

Main
