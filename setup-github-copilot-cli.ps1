<#
.SYNOPSIS
    Setup script for GitHub Copilot CLI integration with Spring MCP Server.

.DESCRIPTION
    Copies MCP configuration files to the user's global Copilot directory.

.EXAMPLE
    .\setup-github-copilot-cli.ps1 -Force
#>

param(
    [switch]$Force
)

$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Red = [System.ConsoleColor]::Red

function Write-SuccessMessage {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Green
}

function Write-WarningMessage {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Yellow
}

function Write-ErrorMessage {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Red
}

Write-Host "================================"
Write-Host "GitHub Copilot CLI Setup Script"
Write-Host "================================"
Write-Host ""

Write-Host "Checking prerequisites..."
try {
    $nodeVersion = node --version
    Write-SuccessMessage ("[OK] Node.js is installed: {0}" -f $nodeVersion)
}
catch {
    Write-ErrorMessage "[ERROR] Node.js is not installed or not in PATH."
    Write-Host "Please install Node.js from https://nodejs.org/ and run again."
    exit 1
}

$mcpConfigDir = Join-Path $env:USERPROFILE ".copilot"
Write-Host ("Creating/verifying Copilot directory: {0}" -f $mcpConfigDir)

if (-not (Test-Path -Path $mcpConfigDir)) {
    New-Item -ItemType Directory -Path $mcpConfigDir -Force | Out-Null
    Write-SuccessMessage "[OK] Created .copilot directory"
}
else {
    Write-SuccessMessage "[OK] .copilot directory already exists"
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$requiredFiles = @("mcp-config.json", "mcp-spring-proxy.js")

foreach ($file in $requiredFiles) {
    $sourcePath = Join-Path $scriptDir $file
    if (-not (Test-Path -Path $sourcePath)) {
        Write-ErrorMessage ("[ERROR] Required file not found: {0}" -f $sourcePath)
        exit 1
    }
}

Write-Host ""
Write-Host "Installing MCP configuration files..."

$configSource = Join-Path $scriptDir "mcp-config.json"
$configDest = Join-Path $mcpConfigDir "mcp-config.json"

if ((Test-Path -Path $configDest) -and (-not $Force)) {
    Write-WarningMessage ("[WARN] {0} already exists" -f $configDest)
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -eq "y") {
        Copy-Item -Path $configSource -Destination $configDest -Force
        Write-SuccessMessage "[OK] Updated mcp-config.json"
    }
    else {
        Write-Host "Skipped mcp-config.json"
    }
}
else {
    Copy-Item -Path $configSource -Destination $configDest -Force
    Write-SuccessMessage "[OK] Installed mcp-config.json"
}

$proxySource = Join-Path $scriptDir "mcp-spring-proxy.js"
$proxyDest = Join-Path $mcpConfigDir "mcp-spring-proxy.js"

if ((Test-Path -Path $proxyDest) -and (-not $Force)) {
    Write-WarningMessage ("[WARN] {0} already exists" -f $proxyDest)
    $response = Read-Host "Overwrite? (y/n)"
    if ($response -eq "y") {
        Copy-Item -Path $proxySource -Destination $proxyDest -Force
        Write-SuccessMessage "[OK] Updated mcp-spring-proxy.js"
    }
    else {
        Write-Host "Skipped mcp-spring-proxy.js"
    }
}
else {
    Copy-Item -Path $proxySource -Destination $proxyDest -Force
    Write-SuccessMessage "[OK] Installed mcp-spring-proxy.js"
}

Write-Host ""
Write-SuccessMessage "[OK] Setup complete"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1) Start Spring MCP server:"
Write-Host ("   cd '{0}'" -f $scriptDir)
Write-Host "   .\mvnw.cmd spring-boot:run"
Write-Host ""
Write-Host "2) Verify endpoint manually:"
Write-Host "   `$body = '{""jsonrpc"":""2.0"",""method"":""tools/list"",""params"":{},""id"":""1""}'"
Write-Host "   Invoke-RestMethod -Uri 'http://localhost:8080/mcp' -Method POST -ContentType 'application/json' -Body `$body"
Write-Host ""
Write-Host "Configuration path:"
Write-Host ("   {0}" -f $mcpConfigDir)
Write-Host ""
Write-Host "For details see SETUP.md"


