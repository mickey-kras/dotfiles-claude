# dotfiles-claude

AI toolchain configuration synced across all machines with [chezmoi](https://chezmoi.io). One command sets up Claude Code, Cursor, and Codex with shared MCPs, rules, and instructions. No API keys to manage — OAuth MCPs authorize in the browser on first use.

## Quick start — new machine

**macOS / Linux / WSL:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/mickey-kras/dotfiles-claude/main/scripts/bootstrap.sh)
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/mickey-kras/dotfiles-claude/main/scripts/bootstrap.ps1 | iex
```

The bootstrap script installs chezmoi, clones this repo, prompts for email and machine type, then configures all detected AI tools. OAuth MCPs (Context7, GitHub) will prompt you to authorize in the browser the first time you use them.

**If chezmoi is already installed:**
```bash
chezmoi init --apply git@github.com:mickey-kras/dotfiles-claude.git
```

## What gets configured

| Tool | MCP config | AI instructions |
|------|-----------|-----------------|
| Claude Code | `~/.claude.json` (via `claude mcp add`) | `~/.claude/CLAUDE.md` + `settings.json` + `rules/` |
| Cursor | `~/.cursor/mcp.json` | `~/.cursor/rules/global.mdc` |
| Codex | `~/.codex/config.toml` | Inline in `config.toml` |

## MCP servers

| Server | Transport | Auth | What it does |
|--------|-----------|------|-------------|
| Sequential Thinking | stdio (npx) | None | Structured step-by-step problem solving |
| Playwright | stdio (npx) | None | Browser automation and testing |
| Context7 | Remote HTTP | OAuth | Up-to-date library docs and code context |
| GitHub | Remote HTTP | OAuth | Repos, issues, PRs, code search |

OAuth servers open your browser to authorize on first use. Each machine can use a different account (personal vs work GitHub, etc.) with no extra config.

## How it works

chezmoi manages dotfiles as templates in a git repo. When you run `chezmoi apply`:

1. Writes `~/.cursor/mcp.json` and `~/.codex/config.toml` with all MCPs
2. Runs `claude mcp add` to register MCPs in Claude Code's runtime config
3. Copies instruction files (CLAUDE.md, Cursor rules) to the right locations

Templates use chezmoi variables (`.chezmoi.os`, `.machine`) so you can add machine-specific behavior if needed.

## Updating

After changing templates in the repo:
```bash
chezmoi apply       # Apply locally
```

On other machines:
```bash
chezmoi update      # Pull + apply in one step
```

## Adding a new MCP

1. Add it to `dot_cursor/mcp.json.tmpl` (JSON format)
2. Add it to `dot_codex/config.toml.tmpl` (TOML format)
3. Add the `claude mcp add` command to `run_onchange_after_install-claude-mcps.sh.tmpl` (and `.ps1.tmpl`)
4. Commit, push, `chezmoi update` on other machines

## Changing machine config

```bash
chezmoi edit-config    # Opens ~/.config/chezmoi/chezmoi.toml
chezmoi apply          # Re-render templates with new values
```

## File structure

```
.chezmoi.toml.tmpl                    # Machine config prompts (email, type)
.chezmoiignore                        # Files chezmoi skips
dot_cursor/
  mcp.json.tmpl                       # → ~/.cursor/mcp.json
  rules/global.mdc                    # → ~/.cursor/rules/global.mdc
dot_codex/
  config.toml.tmpl                    # → ~/.codex/config.toml
dot_claude/
  CLAUDE.md                           # → ~/.claude/CLAUDE.md
  settings.json                       # → ~/.claude/settings.json
  rules/                              # → ~/.claude/rules/
run_onchange_after_install-claude-mcps.sh.tmpl   # Unix: claude mcp add
run_onchange_after_install-claude-mcps.ps1.tmpl  # Windows: claude mcp add
scripts/
  bootstrap.sh                        # macOS/Linux one-liner
  bootstrap.ps1                       # Windows one-liner
```

## Platform support

| Platform | Status |
|----------|--------|
| macOS (ARM/Intel) | Full |
| Linux (Debian/Ubuntu/Fedora/Arch) | Full |
| WSL2 | Full |
| Windows 11 | Full |

## Dependencies

**Required:** git, chezmoi

**For local MCPs:** node, npx (Sequential Thinking, Playwright)

**Optional:** jq (debugging)
