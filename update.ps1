#Requires -Version 5.1
<#
.SYNOPSIS
    AI Super User Setup — Update (Windows)
.DESCRIPTION
    Re-runs all steps, skips anything already installed, picks up anything new.
.USAGE
    irm https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main/update.ps1 | iex
#>

$BaseUrl = "https://raw.githubusercontent.com/lorecraft-io/ai-super-user-setup/main"

Write-Host ""
Write-Host "  ==========================================================" -ForegroundColor Blue
Write-Host "    AI Super User Setup - Update" -ForegroundColor Blue
Write-Host "    Running all steps, skipping what's already installed" -ForegroundColor Blue
Write-Host "  ==========================================================" -ForegroundColor Blue
Write-Host ""

# Step 1
Write-Host ">>> Running Step 1 - Get Claude Running" -ForegroundColor Yellow
Write-Host ""
Invoke-Expression (Invoke-RestMethod "$BaseUrl/step-1/step-1-install.ps1")
Write-Host ""

# Step 2
Write-Host ">>> Running Step 2 - Dev Tools" -ForegroundColor Yellow
Write-Host ""
Invoke-Expression (Invoke-RestMethod "$BaseUrl/step-2/step-2-install.ps1")
Write-Host ""

# Step 3
Write-Host ">>> Running Step 3 - ClaudeFlow" -ForegroundColor Yellow
Write-Host ""
Invoke-Expression (Invoke-RestMethod "$BaseUrl/step-3/step-3-install.ps1")
Write-Host ""

# Add new steps here as they're created
# Write-Host ">>> Running Step 4 - ..." -ForegroundColor Yellow
# Invoke-Expression (Invoke-RestMethod "$BaseUrl/step-4/step-4-install.ps1")

Write-Host ""
Write-Host "  ==========================================================" -ForegroundColor Green
Write-Host "    Update complete. Everything is current." -ForegroundColor Green
Write-Host "  ==========================================================" -ForegroundColor Green
Write-Host ""
