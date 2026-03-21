#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$REPO_DIR/claude"
TARGET="$HOME/.claude"
BACKUP="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

echo "Claude Code dotfiles installer"
echo "  Source: $SOURCE"
echo "  Target: $TARGET"
echo ""

mkdir -p "$TARGET"

ITEMS=("CLAUDE.md" "settings.json" ".mcp.json" "rules" "skills" "agents")
backed_up=false

for item in "${ITEMS[@]}"; do
  src="$SOURCE/$item"
  dst="$TARGET/$item"

  [ ! -e "$src" ] && continue

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    if [ "$backed_up" = false ]; then
      mkdir -p "$BACKUP"
      backed_up=true
      echo "Backing up existing files to $BACKUP"
    fi
    cp -r "$dst" "$BACKUP/"
    rm -rf "$dst"
  elif [ -L "$dst" ]; then
    rm "$dst"
  fi

  ln -s "$src" "$dst"
  echo "  Linked $item -> $dst"
done

if [ ! -f "$TARGET/settings.local.json" ]; then
  cat > "$TARGET/settings.local.json" << 'EOF'
{
  "env": {}
}
EOF
  chmod 600 "$TARGET/settings.local.json"
  echo "  Created settings.local.json template (local-only, gitignored)"
fi

echo ""
echo "Done! ~/.claude/ now points to your dotfiles repo."
echo "Any edits to CLAUDE.md, settings.json, rules, etc. are git-tracked."
