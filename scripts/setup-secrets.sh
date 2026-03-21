#!/usr/bin/env bash
set -euo pipefail

# Interactive setup for a new machine.
# Walks through: API keys → cloud connectors → verification.
# Run once after install.sh on each new machine.

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${CLAUDE_HOME:-$HOME/.claude}"
SECRETS_FILE="$TARGET/settings.local.json"
MANIFEST="$REPO_DIR/claude/connectors.json"

# --- Colors (if terminal supports them) ---
if [ -t 1 ]; then
  BOLD="\033[1m" DIM="\033[2m" GREEN="\033[32m" YELLOW="\033[33m" RED="\033[31m" RESET="\033[0m"
else
  BOLD="" DIM="" GREEN="" YELLOW="" RED="" RESET=""
fi

echo -e "${BOLD}Claude Code — new machine setup${RESET}"
echo "This walks you through everything needed to get fully connected."
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 1: API keys
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BOLD}Step 1/3: API keys${RESET}"
echo "These go into settings.local.json (gitignored, machine-local only)."
echo ""

# Load existing secrets
if [ -f "$SECRETS_FILE" ]; then
  EXISTING_ENV=$(jq -r '.env // {}' "$SECRETS_FILE" 2>/dev/null || echo "{}")
else
  EXISTING_ENV="{}"
fi

# Read required secrets from manifest
NEW_ENV="$EXISTING_ENV"
if [ -f "$MANIFEST" ]; then
  for name in $(jq -r '.local | keys[]' "$MANIFEST" 2>/dev/null); do
    req_secret=$(jq -r ".local[\"$name\"].requires_secret // empty" "$MANIFEST")
    [ -z "$req_secret" ] && continue

    desc=$(jq -r ".local[\"$name\"].description" "$MANIFEST")
    secret_url=$(jq -r ".local[\"$name\"].secret_url // empty" "$MANIFEST")
    existing=$(echo "$EXISTING_ENV" | jq -r --arg k "$req_secret" '.[$k] // empty' 2>/dev/null || true)

    echo -e "  ${BOLD}$req_secret${RESET} — $desc"
    [ -n "$secret_url" ] && echo -e "  ${DIM}Get from: $secret_url${RESET}"

    if [ -n "$existing" ]; then
      masked="${existing:0:4}****${existing: -4}"
      read -p "  Current: [$masked] New value (Enter to keep): " -r value
      value="${value:-$existing}"
    else
      read -p "  Value (Enter to skip): " -r value
    fi

    if [ -n "$value" ]; then
      NEW_ENV=$(echo "$NEW_ENV" | jq --arg k "$req_secret" --arg v "$value" '. + {($k): $v}')
      echo -e "  ${GREEN}Set${RESET}"
    else
      echo -e "  ${YELLOW}Skipped${RESET}"
    fi
    echo ""
  done
fi

# Write secrets file
jq -n --argjson env "$NEW_ENV" '{"env": $env}' > "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"
echo -e "  ${GREEN}Saved to $SECRETS_FILE${RESET}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 2: Cloud connectors
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BOLD}Step 2/3: Cloud connectors${RESET}"
echo "These are OAuth-based and need to be enabled in the Claude app."
echo "I'll open each one — just sign in and authorize."
echo ""

if [ -f "$MANIFEST" ]; then
  OPEN_CMD="open"
  case "$(uname -s)" in
    Linux*)  OPEN_CMD="xdg-open" ;;
    MINGW*|MSYS*|CYGWIN*)  OPEN_CMD="start" ;;
  esac

  # Check which connectors are already enabled on this machine
  ENABLED_FILE="$TARGET/.connectors-enabled"
  touch "$ENABLED_FILE"

  CLOUD_KEYS=$(jq -r '.cloud | keys[]' "$MANIFEST" 2>/dev/null)
  CLOUD_COUNT=$(echo "$CLOUD_KEYS" | wc -l | tr -d ' ')
  PENDING=()

  for name in $CLOUD_KEYS; do
    if ! grep -q "^$name$" "$ENABLED_FILE" 2>/dev/null; then
      PENDING+=("$name")
    fi
  done

  if [ ${#PENDING[@]} -eq 0 ]; then
    echo -e "  ${GREEN}All cloud connectors already enabled on this machine.${RESET}"
  else
    echo "  ${#PENDING[@]} connector(s) need setup on this machine."
    echo ""

    IDX=1
    TOTAL=${#PENDING[@]}
    for name in "${PENDING[@]}"; do
      desc=$(jq -r ".cloud[\"$name\"].description" "$MANIFEST")
      setup=$(jq -r ".cloud[\"$name\"].setup" "$MANIFEST")
      added_from=$(jq -r ".cloud[\"$name\"].added_from // \"another machine\"" "$MANIFEST")

      echo -e "  ${BOLD}($IDX/$TOTAL) $desc${RESET}"
      echo "  Added from: $added_from"
      echo "  Setup: $setup"
      read -p "  Enable now? (y/N/skip remaining with 's') " -n 1 -r
      echo ""

      case "$REPLY" in
        [Yy])
          if [ "$(uname -s)" = "Darwin" ]; then
            open "claude://settings" 2>/dev/null || open "https://claude.ai/settings" 2>/dev/null || true
          else
            $OPEN_CMD "https://claude.ai/settings" 2>/dev/null || true
          fi
          echo -e "  ${GREEN}Opened Claude settings — enable $name, then come back${RESET}"
          read -p "  Press Enter when done (or 'x' if you didn't enable it)..." -r
          if [[ ! "$REPLY" =~ ^[Xx]$ ]]; then
            echo "$name" >> "$ENABLED_FILE"
            echo -e "  ${GREEN}✓ Marked $name as enabled${RESET}"
          fi
          ;;
        [Ss])
          echo -e "  ${DIM}Skipping remaining connectors${RESET}"
          break
          ;;
        *)
          echo -e "  ${YELLOW}Skipped — will remind on next startup${RESET}"
          ;;
      esac
      echo ""
      IDX=$((IDX + 1))
    done
  fi
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# STEP 3: Verify
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${BOLD}Step 3/3: Verification${RESET}"
echo ""

# Check local MCPs
echo "  Local MCPs:"
if [ -f "$TARGET/.mcp.json" ]; then
  for name in $(jq -r '.mcpServers | keys[]' "$TARGET/.mcp.json" 2>/dev/null); do
    echo -e "    ${GREEN}✓${RESET} $name"
  done
  if [ "$(jq '.mcpServers | length' "$TARGET/.mcp.json" 2>/dev/null)" = "0" ]; then
    echo -e "    ${YELLOW}(none configured)${RESET}"
  fi
else
  echo -e "    ${RED}✗ .mcp.json not found${RESET}"
fi

# Check secrets
echo ""
echo "  API keys:"
if [ -f "$SECRETS_FILE" ]; then
  for key in $(jq -r '.env // {} | keys[]' "$SECRETS_FILE" 2>/dev/null); do
    val=$(jq -r ".env[\"$key\"]" "$SECRETS_FILE" 2>/dev/null)
    if [ -n "$val" ] && [ "$val" != "null" ]; then
      echo -e "    ${GREEN}✓${RESET} $key"
    else
      echo -e "    ${RED}✗${RESET} $key (empty)"
    fi
  done
else
  echo -e "    ${YELLOW}No settings.local.json${RESET}"
fi

# Check cloud connectors
echo ""
echo "  Cloud connectors:"
echo -e "    ${DIM}(verify in Claude app: /mcp to see connected servers)${RESET}"

echo ""
echo -e "${GREEN}Setup complete!${RESET} Start a new Claude Code session to activate everything."
echo "The startup hooks will handle syncing from here."
