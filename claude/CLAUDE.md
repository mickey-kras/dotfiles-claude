# Global Claude Code Instructions

## About Me
- My name is Misha.
- I work across two MacBooks — config is synced via the dotfiles-claude repo.
- I prefer concise, direct responses. Skip excessive caveats and preambles.
- Default to TypeScript for new projects unless I specify otherwise.

## Coding Standards
- Readable > clever. Meaningful variable names; no single-letter vars except loop counters.
- Always add error handling — no happy-path-only code.
- Async/await over raw promises. Explicit types over `any`.
- 2-space indent for JS/TS/JSON/YAML, 4-space for Python.
- Prefer `const` over `let`; never use `var`.
- Write tests when creating new functions or modules.

## Git Conventions
- Commit messages: imperative mood, <72 char subject, Conventional Commits format.
  Examples: `feat: add auth middleware`, `fix: handle null user in dashboard`
- Always create a feature branch; never commit directly to main.
- Squash-merge PRs. Delete branches after merge.

## Claude Code Workflow
- Use /clear between unrelated tasks to keep context clean.
- Use /compact when context gets heavy (50%+ usage).
- Don't create documentation files unless I explicitly ask.
- When I say "ship it" — commit, push, and open a PR.
- When editing files, preserve existing patterns and style. Match surrounding code.
- Before making big changes, outline the plan and confirm.

## MCP & Tools
- Prefer CLI tools (gh, jq, curl, ripgrep) over browser when possible.
- When I ask about calendar, tasks, or messages — use the appropriate MCP if available.

## Security
- Never commit secrets. API keys, tokens, passwords go in .env.local or settings.local.json (gitignored).
- Never run sudo or modify system files.
- Never force-push to main/master.
- Never log or echo secrets, not even in debug mode.

## Project-Specific Instructions
- Add project-specific rules to that project's own .claude/CLAUDE.md — not here.
- This file is for global preferences only. Keep it under 200 lines.
