---
description: Research-first development workflow
globs: ["**/*"]
---

# Development Workflow: Research → Plan → Test → Code → Review

## 1. Research Before Writing Code (Mandatory)

Before implementing anything non-trivial:
- Search for existing solutions: `gh search repos` and `gh search code` for prior art.
- Read official docs via Context7 or Cloudflare Docs MCPs — verify API behavior before assuming.
- Check package registries (npm, PyPI, crates.io) before building utilities from scratch.
- Look at GitHub issues/discussions for known gotchas and edge cases.

## 2. Plan Before Implementing

- For anything touching >3 files, outline the approach and confirm before coding.
- Identify dependencies, risks, and the order of changes.
- Use the planner agent for complex features.

## 3. Test-Driven Development

- Write a failing test that describes the expected behavior.
- Implement the minimum code to pass the test.
- Refactor for clarity while keeping tests green.
- Target 80%+ meaningful coverage (behavior, not lines).

## 4. Code Review Before Merge

- Use the code-reviewer agent for automated review of diffs.
- Address CRITICAL and HIGH issues before merging.
- Follow conventional commit format in all commits.
