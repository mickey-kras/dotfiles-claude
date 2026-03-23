---
description: Model routing and context management guidance
globs: ["**/*"]
---

# Performance & Model Routing

## Model Selection

- **Haiku**: Use for lightweight tasks — formatting, simple transformations, boilerplate generation, pair programming suggestions. ~90% of Sonnet capability at 3x cost savings.
- **Sonnet**: Primary development engine — standard coding, multi-file changes, debugging, multi-agent orchestration.
- **Opus**: Reserve for complex architectural decisions, research-level analysis, ambiguous requirements, and critical code review.

## Context Window Management

- Use `/compact` proactively when context reaches ~50% (don't wait for the limit).
- Avoid starting large-scale refactoring or multi-file debugging in the final 20% of context.
- Use `/clear` between unrelated tasks to start fresh.
- When context is heavy, prefer single-file modifications over cross-file changes.

## Extended Thinking

- Enable for complex problems: architecture decisions, tricky bugs, security analysis.
- Not needed for: simple edits, formatting, straightforward implementations.

## Build Troubleshooting

- Analyze the full error output before attempting fixes.
- Apply incremental fixes with verification between each step.
- Don't retry the same failing approach — investigate root cause.
