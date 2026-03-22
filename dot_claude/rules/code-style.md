---
description: Engineering principles for all code
globs: ["**/*"]
---

- TDD: write a failing test → implement to pass → refactor. Every new function or module gets a test.
- SOLID: single responsibility per class/module, depend on abstractions, open for extension.
- DRY: extract shared logic. If you copy-paste, refactor into a helper.
- Use design patterns (Factory, Strategy, Repository, Observer, etc.) where they reduce coupling. Don't over-engineer.
- Readable > clever. Meaningful names. No abbreviations unless universally understood.
- Error handling: never swallow errors silently. Use typed exceptions or Result/Either patterns.
- Keep functions short. If it doesn't fit on one screen, break it up.
