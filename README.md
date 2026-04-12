# Spring MCP Server

A simple Spring Boot implementation of an MCP-style JSON-RPC server.

## Overview

This project exposes a single HTTP endpoint:

- `POST /mcp`

Supported methods:

- `initialize`
- `tools/list`
- `tools/call`

The server currently provides one tool:

- `calculator` - returns the sum of provided numbers.

## Tech Stack

- Java 25
- Spring Boot 4.1.0-SNAPSHOT
- Maven (with Maven Wrapper)

## Requirements

- JDK 25 installed and available on `PATH`
- Internet access for downloading Maven dependencies

## Run (Windows PowerShell)

```powershell
Set-Location "C:\Data\Java\SpringMcpServer"
.\mvnw.cmd spring-boot:run
```

By default, the server starts on port `8080` (see `src/main/resources/application.yaml`).

## Build and Test

```powershell
Set-Location "C:\Data\Java\SpringMcpServer"
.\mvnw.cmd clean test
```

## API Usage

### Endpoint

- URL: `http://localhost:8080/mcp`
- Method: `POST`
- Content-Type: `application/json`

### 1) Initialize

Request:

```json
{
  "jsonrpc": "2.0",
  "method": "initialize",
  "params": {},
  "id": "1"
}
```

Example response:

```json
{
  "jsonrpc": "2.0",
  "result": {
    "name": "Spring Boot MCP Server",
    "version": "1.0.0",
    "protocolVersion": "2024-11-05"
  },
  "id": "1"
}
```

### 2) List tools

Request:

```json
{
  "jsonrpc": "2.0",
  "method": "tools/list",
  "params": {},
  "id": "2"
}
```

Example response:

```json
{
  "jsonrpc": "2.0",
  "result": {
    "tools": [
      {
        "name": "calculator",
        "description": "Oblicza sume podanych liczb",
        "inputSchema": {
          "type": "object",
          "properties": {
            "numbers": {
              "type": "array",
              "items": { "type": "number" },
              "description": "Lista liczb do zsumowania"
            }
          },
          "required": ["numbers"]
        }
      }
    ]
  },
  "id": "2"
}
```

### 3) Call calculator

Request:

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
  "id": "3"
}
```

Example response:

```json
{
  "jsonrpc": "2.0",
  "result": {
    "result": 60.0
  },
  "id": "3"
}
```

## PowerShell request examples

Use `curl.exe` (not `curl` alias) in PowerShell to avoid command parsing issues:

```powershell
curl.exe -X POST "http://localhost:8080/mcp" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"calculator","arguments":{"numbers":[10,20,30]}},"id":"3"}'
```

Or use `Invoke-RestMethod`:

```powershell
$body = @'
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "calculator",
    "arguments": {
      "numbers": [10, 20, 30]
    }
  },
  "id": "3"
}
'@

Invoke-RestMethod -Uri "http://localhost:8080/mcp" -Method POST -ContentType "application/json" -Body $body
```

## Project Structure

- `src/main/java/com/example/mcpserver/controllers/MCPController.java` - JSON-RPC HTTP endpoint
- `src/main/java/com/example/mcpserver/services/MCPService.java` - method dispatch and tool execution
- `src/main/java/com/example/mcpserver/tools/MCPTool.java` - tool contract
- `src/main/java/com/example/mcpserver/tools/CalculatorTool.java` - sample calculator tool
- `src/main/resources/application.yaml` - app configuration

