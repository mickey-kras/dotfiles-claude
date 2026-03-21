#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

for f in "CLAUDE.md" "settings.json" ".mcp.json"; do
  live="$HOME/.claude/$f"
  repo="$REPO_DIR/claude/$f"
  if [ -L "$live" ]; then
    echo "  $f — symlinked (always in sync)"
  elif [ ! -f "$live" ]; then
    echo "  $f — not in ~/.claude/"
  elif [ ! -f "$repo" ]; then
    echo "  $f — not in repo"
  elif diff -q "$live" "$repo" > /dev/null 2>&1; then
    echo "  $f — identical"
  else
    echo "  $f — DIFFERS:"
    diff --color "$repo" "$live" || true
  fi
done
