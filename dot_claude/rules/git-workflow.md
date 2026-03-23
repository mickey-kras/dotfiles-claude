---
description: Git conventions and PR workflow
globs: ["**/*"]
---

# Git Workflow

## Commit Messages

Format: `<type>(<scope>): <description>`

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

- Subject line: imperative mood, <72 characters.
- Body (optional): explain *why*, not *what*. The diff shows *what*.
- Breaking changes: add `BREAKING CHANGE:` footer.

## Branch Naming

- `feat/<short-description>` — new features
- `fix/<short-description>` — bug fixes
- `chore/<short-description>` — maintenance

## Pull Requests

- Examine the complete commit history (`git diff main...HEAD`), not just the latest commit.
- Write a summary covering: what changed, why, and how to test.
- Include a test plan with checkboxes.
- Push with `-u` flag on newly created branches.
- Squash-merge PRs. Delete branches after merge.

## Rules

- Never commit directly to main. Always use feature branches.
- Never force-push to main/master.
- Never use `--no-verify` to skip pre-commit hooks.
- Never commit secrets, even temporarily.
