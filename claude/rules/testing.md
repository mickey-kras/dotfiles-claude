## Testing Standards

- Every new module gets a test file: `foo.ts` → `foo.test.ts`.
- Test behavior, not implementation. Tests should survive refactors.
- Use descriptive test names: `should return 404 when user not found` not `test1`.
- Arrange-Act-Assert pattern.
- Mock external services, never real APIs in tests.
- Run the full test suite before pushing.
