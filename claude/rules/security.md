## Security Rules

- All secrets live in .env.local or settings.local.json (both gitignored).
- Never log, print, or echo secrets — not even in debug mode.
- Use environment variables for credentials, never hardcoded strings.
- Validate and sanitize all user input.
- Use parameterized queries for databases, never string interpolation.
- HTTPS only for external API calls.
