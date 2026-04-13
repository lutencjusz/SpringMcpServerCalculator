# GitHub Copilot CLI Integration Setup

This guide explains how to integrate the Spring MCP Server with GitHub Copilot CLI so it's available across all your projects.

## Prerequisites

Before starting, ensure you have:

- **GitHub Copilot CLI** installed ([Installation Guide](https://github.com/github/gh-copilot))
- **Node.js** installed (v18 or higher)
- **Java 25 JDK** installed
- **This repository** cloned locally

## Step 1: Start the Spring MCP Server

Open a PowerShell terminal and run:

```powershell
cd C:\Data\Java\SpringMcpServer
.\mvnw.cmd spring-boot:run
```

The server will start on `http://localhost:8080`. You should see output like:

```
...
Started McpServerApplication in X seconds
```

**Keep this terminal running** while using GitHub Copilot CLI.

## Step 2: Configure GitHub Copilot CLI

The configuration files are already set up in your home directory at `~/.copilot/`:

- **mcp-config.json** - MCP server configuration
- **mcp-spring-proxy.js** - STDIO proxy that converts requests to HTTP calls

These files are automatically installed when you run through the setup below.

### Option A: Manual Setup (Windows)

1. Create the configuration directory:
```powershell
$mcpConfigDir = "$env:USERPROFILE\.copilot"
if (-not (Test-Path $mcpConfigDir)) {
    New-Item -ItemType Directory -Path $mcpConfigDir -Force > $null
}
```

2. Create the proxy script at `~/.copilot/mcp-spring-proxy.js`:
```powershell
# Copy the content from the SpringMcpServer project at root
Copy-Item "path\to\SpringMcpServer\mcp-spring-proxy.js" "$env:USERPROFILE\.copilot\mcp-spring-proxy.js"
```

3. Create the MCP config at `~/.copilot/mcp-config.json`:
```powershell
# Copy the content from the SpringMcpServer project at root
Copy-Item "path\to\SpringMcpServer\mcp-config.json" "$env:USERPROFILE\.copilot\mcp-config.json"
```

### Option B: Automatic Setup (PowerShell Script)

```powershell
# Run from the SpringMcpServer root directory
$mcpConfigDir = "$env:USERPROFILE\.copilot"
if (-not (Test-Path $mcpConfigDir)) {
    New-Item -ItemType Directory -Path $mcpConfigDir -Force > $null
}

# Copy configuration files
Copy-Item ".\mcp-config.json" "$mcpConfigDir\mcp-config.json" -Force
Copy-Item ".\mcp-spring-proxy.js" "$mcpConfigDir\mcp-spring-proxy.js" -Force

Write-Host "✅ GitHub Copilot CLI configuration complete!"
Write-Host "Configuration files installed at: $mcpConfigDir"
```

## Step 3: Verify the Integration

1. Open a new PowerShell terminal (keep the server running in the first one)
2. Test the MCP server with a direct HTTP request:

```powershell
$body = @{
    jsonrpc = "2.0"
    method = "tools/list"
    params = @{}
    id = "1"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/mcp" -Method POST -ContentType "application/json" -Body $body
```

You should see the available tools listed.

3. Test with GitHub Copilot CLI:

```powershell
copilot -v
```

This verifies that GitHub Copilot CLI can find the MCP server configuration.

## Step 4: Use the Calculator Tool

Once configured, you can use the calculator tool in GitHub Copilot CLI sessions. For example:

```powershell
copilot help
```

Look for the `spring-mcp-server` server and the `calculator` tool in the available tools.

## Troubleshooting

### Server not responding
- **Problem**: Connection refused on localhost:8080
- **Solution**: Ensure the Spring Boot server is running in a terminal and displaying "Started"

### MCP proxy not working
- **Problem**: "mcp-spring-proxy.js" not found
- **Solution**: Verify the proxy script is in `~/.copilot/` and path is correct

### Configuration not being read
- **Problem**: GitHub Copilot CLI doesn't find the server
- **Solution**: 
  - Check that `mcp-config.json` is in `~/.copilot/`
  - Verify the JSON syntax is valid
  - Restart GitHub Copilot CLI

### Node.js issues
- **Problem**: "node" command not found
- **Solution**: Ensure Node.js is installed and in your PATH

## Architecture Overview

```
┌─────────────────────────────────────┐
│  GitHub Copilot CLI (STDIO)         │
└────────────────┬────────────────────┘
                 │
                 │ JSON-RPC (STDIO)
                 ▼
┌─────────────────────────────────────┐
│  mcp-spring-proxy.js (Node.js)      │
│  Converts STDIO ↔ HTTP              │
└────────────────┬────────────────────┘
                 │
                 │ JSON-RPC (HTTP POST)
                 ▼
┌─────────────────────────────────────┐
│  Spring MCP Server                  │
│  http://localhost:8080/mcp          │
│                                     │
│  - Initialize                       │
│  - List Tools                       │
│  - Call Tools (e.g., calculator)    │
└─────────────────────────────────────┘
```

## Available Tools

### Calculator Tool

Performs arithmetic operations on a list of numbers.

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "numbers": {
      "type": "array",
      "items": { "type": "number" },
      "description": "List of numbers to sum"
    }
  },
  "required": ["numbers"]
}
```

**Example:**
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "calculator",
    "arguments": {
      "numbers": [10, 20, 30]
    }
  },
  "id": "1"
}
```

**Response:**
```json
{
  "jsonrpc": "2.0",
  "result": {
    "result": 60.0
  },
  "id": "1"
}
```

## Project Repository

GitHub: https://github.com/lutencjusz/SpringMcpServerCalculator.git

## Support

For issues or questions:
1. Check the [main README.md](./README.md)
2. Review troubleshooting section above
3. Check GitHub repository issues

