---
description: Bitwarden CLI setup guide for secret-backed MCPs
globs: ["**/chezmoi*", "**/.chezmoi*"]
---

# Bitwarden CLI Setup for Secret-Backed MCPs

The dotfiles can render secret-backed MCP configuration through Bitwarden CLI.
Whether those MCPs are enabled depends on the selected runtime profile and any
custom MCP selections.

If the Bitwarden vault is locked or the required items do not exist, `chezmoi
apply` or MCP registration steps may fail.

## Install Bitwarden CLI

```bash
# macOS
brew install bitwarden-cli

# Any platform with Node.js
npm install -g @bitwarden/cli
```

## Login and unlock

```bash
bw login
export BW_SESSION=$(bw unlock --raw)
```

`BW_SESSION` must be available in the shell where you run `chezmoi apply` or
Claude MCP reconciliation.

## Required Bitwarden items

Use **Login** items with the secret stored in the **Password** field unless
noted otherwise.

Core items used by the current MCP catalog:

| Bitwarden item name | Purpose | Notes |
|---------------------|---------|-------|
| `mcp-github` | GitHub token | Password = PAT |
| `mcp-aws` | AWS API access | Custom fields: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` |
| `mcp-tailscale` | Tailscale API access | Password = API key, custom field `TAILSCALE_TAILNET` |
| `exa-api-key` | Exa API key | Password = API key |
| `firecrawl-api-key` | Firecrawl API key | Password = API key |
| `fal-api-key` | fal.ai API key | Password = API key |

Only create the items required by the MCPs you actually enable.

## Verify

```bash
bw get password mcp-github
bw get item mcp-aws
bw get password exa-api-key
```

## Apply

```bash
chezmoi apply
```

## Troubleshooting

- **`bw: command not found`**: install Bitwarden CLI first.
- **unlock or auth errors**: export a fresh `BW_SESSION` in the same shell and retry.
- **item not found**: the Bitwarden item name must match the expected name exactly.
- **do not want secret-backed MCPs on this machine**: choose a runtime profile that omits them, or disable them in custom mode and re-run setup.
