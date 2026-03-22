# One-command bootstrap for Windows
# Usage: irm https://raw.githubusercontent.com/mickey-kras/dotfiles-claude/main/scripts/bootstrap.ps1 | iex

$ErrorActionPreference = "Stop"
$Repo = "mickey-kras/dotfiles-claude"

Write-Host "=== AI Toolchain Bootstrap ===" -ForegroundColor Cyan
Write-Host ""

# --- Install chezmoi if missing ---
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    Write-Host "Installing chezmoi..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install twpayne.chezmoi --accept-package-agreements --accept-source-agreements
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install chezmoi -y
    } else {
        Invoke-Expression (Invoke-WebRequest -Uri "https://get.chezmoi.io/ps1" -UseBasicParsing).Content
    }
    Write-Host "  chezmoi installed"
}

# --- Check dependencies ---
$missing = @()
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { $missing += "git" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { $missing += "node" }
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { $missing += "npx" }

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Host "Missing dependencies: $($missing -join ', ')" -ForegroundColor Yellow
    Write-Host "Some MCPs require node/npx. Install them for full functionality."
    Write-Host ""
}

# --- Check for AI tools ---
Write-Host "Detected AI tools:"
if (Get-Command claude -ErrorAction SilentlyContinue) { Write-Host "  + Claude Code" } else { Write-Host "  - Claude Code (not found)" -ForegroundColor DarkGray }
if (Test-Path "$env:LOCALAPPDATA\Programs\cursor") { Write-Host "  + Cursor" } else { Write-Host "  - Cursor (not found)" -ForegroundColor DarkGray }
if (Get-Command codex -ErrorAction SilentlyContinue) { Write-Host "  + Codex" } else { Write-Host "  - Codex (not found)" -ForegroundColor DarkGray }
Write-Host ""

# --- Init + apply ---
Write-Host "Running chezmoi init + apply..."
Write-Host "You'll be prompted for your email and machine type."
Write-Host "No API keys needed - OAuth MCPs authorize in the browser on first use."
Write-Host ""
chezmoi init --apply "git@github.com:${Repo}.git"

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Your AI tools are configured. OAuth MCPs (Context7, GitHub) will"
Write-Host "prompt you to authorize in the browser the first time you use them."
Write-Host ""
Write-Host "Verify with:"
Write-Host "  claude mcp list"
Write-Host "  Get-Content ~/.cursor/mcp.json"
Write-Host "  Get-Content ~/.codex/config.toml"
Write-Host ""
Write-Host "To update later:  chezmoi update"
