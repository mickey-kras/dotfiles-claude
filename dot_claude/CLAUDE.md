# Global Claude Code Instructions

## About Me
- My name is Misha.
- I work across multiple machines — config is synced via chezmoi + dotfiles-claude.
- I prefer concise, direct responses. Skip excessive caveats and preambles.

## Engineering Principles
- TDD: always write a failing test first, then the minimal implementation to pass it, then refactor. No skipping steps.
- SOLID: single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion. Apply consistently.
- DRY: if logic appears twice, extract it. If three files share a pattern, abstract it.
- Design patterns: use them where they reduce coupling and improve clarity (Factory, Strategy, Repository, Observer, etc.). Never force a pattern where a simpler solution works.
- Readable > clever. Meaningful names. No single-letter vars except loop counters.
- Always add error handling — no happy-path-only code.

## Git Conventions
- Commit messages: imperative mood, <72 char subject, Conventional Commits format.
- Always create a feature branch; never commit directly to main.
- Squash-merge PRs. Delete branches after merge.

## Workflow
- Use /clear between unrelated tasks to keep context clean.
- Use /compact when context gets heavy (50%+ usage).
- Don't create documentation files unless I explicitly ask.
- When I say "ship it" — commit, push, and open a PR.
- When editing files, preserve existing patterns and style. Match surrounding code.
- Before making big changes, outline the plan and confirm.

## Tools
- Prefer CLI tools (gh, jq, curl, ripgrep) over browser when possible.
- When I ask about calendar, tasks, or messages — use the appropriate MCP if available.

## Security
- Never commit secrets. API keys, tokens, passwords go in environment variables or gitignored files.
- Never run sudo or modify system files.
- Never force-push to main/master.
- Never log or echo secrets, not even in debug mode.

## Project-Specific
- Stack, frameworks, and language-specific rules go in each project's .claude/CLAUDE.md — not here.
- This file is for global preferences and engineering principles only.
