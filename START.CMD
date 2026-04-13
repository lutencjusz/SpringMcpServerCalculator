@echo off
setlocal

set "ROOT=%~dp0"
cd /d "%ROOT%"

if not exist "%ROOT%mvnw.cmd" (
  echo [ERROR] File not found: mvnw.cmd
  exit /b 1
)

if not exist "%ROOT%setup-github-copilot-cli.ps1" (
  echo [ERROR] File not found: setup-github-copilot-cli.ps1
  exit /b 1
)

start "Spring MCP Server" cmd /k "cd /d "%ROOT%" && call .\mvnw.cmd spring-boot:run"
start "GitHub Copilot CLI Setup" powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -Command "Set-Location -LiteralPath '%ROOT%'; .\setup-github-copilot-cli.ps1 -Force"

exit /b 0

