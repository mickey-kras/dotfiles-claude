---
description: Security rules for all projects
globs: ["**/*"]
---

- Never commit secrets, API keys, tokens, or passwords. Use environment variables.
- Never run sudo, su, or modify system files.
- Never force-push to main/master. Never use --no-verify.
- Never log, echo, or print secrets — not even in debug mode.
- Validate all user input. Sanitize for SQL injection, XSS, path traversal.
- Use parameterized queries. Never concatenate user input into SQL.
- HTTPS only. No HTTP endpoints in production.
- Dependencies: prefer well-maintained packages with recent commits and no known CVEs.
