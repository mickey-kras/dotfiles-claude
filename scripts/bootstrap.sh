#!/usr/bin/env bash
set -euo pipefail

# One-command bootstrap for macOS / Linux / WSL
# Usage: curl -sL https://raw.githubusercontent.com/mickey-kras/dotfiles-claude/main/scripts/bootstrap.sh | bash

REPO="mickey-kras/dotfiles-claude"

echo "=== AI Toolchain Bootstrap ==="
echo ""

# --- Install chezmoi if missing ---
if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Installing chezmoi..."
  if [[ "$(uname -s)" == "Darwin" ]]; then
    brew install chezmoi
  elif command -v apt-get >/dev/null 2>&1; then
    sudo sh -c 'curl -fsLS get.chezmoi.io | sh' && sudo mv ./bin/chezmoi /usr/local/bin/
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y chezmoi
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S chezmoi
  else
    sh -c "$(curl -fsLS get.chezmoi.io)"
    export PATH="$HOME/bin:$PATH"
  fi
  echo "  chezmoi installed"
fi

# --- Check dependencies ---
MISSING=()
command -v git  >/dev/null 2>&1 || MISSING+=("git")
command -v node >/dev/null 2>&1 || MISSING+=("node/nodejs")
command -v npx  >/dev/null 2>&1 || MISSING+=("npx")

if [ ${#MISSING[@]} -gt 0 ]; then
  echo ""
  echo "Missing dependencies: ${MISSING[*]}"
  echo "Some MCPs require node/npx. Install them for full functionality."
  echo ""
fi

# --- Check for AI tools ---
echo "Detected AI tools:"
command -v claude >/dev/null 2>&1 && echo "  + Claude Code" || echo "  - Claude Code (not found)"
[ -d "$HOME/.cursor" ] || [ -d "/Applications/Cursor.app" ] && echo "  + Cursor" || echo "  - Cursor (not found)"
command -v codex >/dev/null 2>&1 && echo "  + Codex" || echo "  - Codex (not found)"
echo ""

# --- Init + apply ---
echo "Running chezmoi init + apply..."
echo "You'll be prompted for your email and machine type."
echo "No API keys needed — OAuth MCPs authorize in the browser on first use."
echo ""
chezmoi init --apply "git@github.com:${REPO}.git"

echo ""
echo "=== Done! ==="
echo ""
echo "Your AI tools are configured. OAuth MCPs (Context7, GitHub) will"
echo "prompt you to authorize in the browser the first time you use them."
echo ""
echo "Verify with:"
echo "  claude mcp list          # Claude Code MCPs"
echo "  cat ~/.cursor/mcp.json   # Cursor MCPs"
echo "  cat ~/.codex/config.toml # Codex MCPs"
echo ""
echo "To update later:  chezmoi update"
