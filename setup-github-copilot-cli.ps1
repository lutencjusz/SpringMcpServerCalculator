#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup script for GitHub Copilot CLI integration with Spring MCP Server

.DESCRIPTION
    This script copies necessary configuration files to ~/.copilot/ directory
    for GitHub Copilot CLI integration.

.EXAMPLE
    .\setup-github-copilot-cli.ps1
#>

param(
    [switch]$Force
)

# Colors for output
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Red = [System.ConsoleColor]::Red

function Write-Success {
    Write-Host $args[0] -ForegroundColor $Green
}

function Write-Warning {
    Write-Host $args[0] -ForegroundColor $Yellow
}

function Write-Error {
    Write-Host $args[0] -ForegroundColor $Red
}

Write-Host "================================"
Write-Host "GitHub Copilot CLI Setup Script"
Write-Host "================================"
Write-Host ""

# Check if Node.js is installed
Write-Host "Checking prerequisites..."
try {
    $nodeVersion = node --version
    Write-Success "✓ Node.js is installed: $nodeVersion"
} catch {
    Write-Error "✗ Node.js is not installed or not in PATH"
    Write-Host "  Please install Node.js from: https://nodejs.org/"
    exit 1
}

# Create .copilot directory
$mcpConfigDir = "$env:USERPROFILE\.copilot"
Write-Host "Creating/verifying .copilot directory: $mcpConfigDir"

if (-not (Test-Path $mcpConfigDir)) {
    New-Item -ItemType Directory -Path $mcpConfigDir -Force > $null
    Write-Success "✓ Created .copilot directory"
} else {
    Write-Success "✓ .copilot directory already exists"
}

# Get the script directory (where this setup script is located)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check for required files in the project
$requiredFiles = @(
    "mcp-config.json",
    "mcp-spring-proxy.js"
)

foreach ($file in $requiredFiles) {
    $sourcePath = Join-Path $scriptDir $file
    if (-not (Test-Path $sourcePath)) {
        Write-Error "✗ Required file not found: $file"
        Write-Host "  Looking in: $sourcePath"
        exit 1
    }
}

Write-Host ""
Write-Host "Installing MCP configuration files..."

# Copy mcp-config.json
$configSource = Join-Path $scriptDir "mcp-config.json"
$configDest = Join-Path $mcpConfigDir "mcp-config.json"

if ((Test-Path $configDest) -and -not $Force) {
    Write-Warning "⚠ $configDest already exists"
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -ne "y") {
        Write-Host "Skipping..."
    } else {
        Copy-Item $configSource $configDest -Force
        Write-Success "✓ Updated mcp-config.json"
    }
} else {
    Copy-Item $configSource $configDest -Force
    Write-Success "✓ Installed mcp-config.json"
}

# Copy mcp-spring-proxy.js
$proxySource = Join-Path $scriptDir "mcp-spring-proxy.js"
$proxyDest = Join-Path $mcpConfigDir "mcp-spring-proxy.js"

if ((Test-Path $proxyDest) -and -not $Force) {
    Write-Warning "⚠ $proxyDest already exists"
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -ne "y") {
        Write-Host "Skipping..."
    } else {
        Copy-Item $proxySource $proxyDest -Force
        Write-Success "✓ Updated mcp-spring-proxy.js"
    }
} else {
    Copy-Item $proxySource $proxyDest -Force
    Write-Success "✓ Installed mcp-spring-proxy.js"
}

Write-Host ""
Write-Success "✅ Setup complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Start the Spring MCP Server in one terminal:"
Write-Host "   cd '$scriptDir'"
Write-Host "   .\mvnw.cmd spring-boot:run"
Write-Host ""
Write-Host "2. In another terminal, verify the setup:"
Write-Host "   `$body = @{'jsonrpc'='2.0';'method'='tools/list';'params'=@{};'id'='1'} | ConvertTo-Json"
Write-Host "   Invoke-RestMethod -Uri 'http://localhost:8080/mcp' -Method POST -ContentType 'application/json' -Body `$body"
Write-Host ""
Write-Host "3. Configuration files are installed at:"
Write-Host "   $mcpConfigDir"
Write-Host ""
Write-Host "For more information, see SETUP.md"
Write-Host ""
Write-Host "⚠️  Remember:"
Write-Host "  - Keep the Spring MCP Server running"
Write-Host "  - The configuration is now available in all projects"
Write-Host "  - GitHub Copilot CLI will auto-discover the spring-mcp-server"


