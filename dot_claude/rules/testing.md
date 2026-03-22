---
description: Testing standards
globs: ["**/*.test.*", "**/*.spec.*", "**/*Tests.*", "**/*Test.*"]
---

- TDD workflow: red → green → refactor. Write the test before the implementation.
- Unit tests: fast, isolated, no I/O. Mock external dependencies.
- Integration tests: test real interactions with test containers or in-memory providers.
- One logical assertion per test. Arrange-Act-Assert pattern.
- Name tests clearly: what is being tested, under what conditions, what is expected.
- Aim for meaningful coverage, not a number. Test behavior, not implementation details.
