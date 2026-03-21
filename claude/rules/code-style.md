## Code Style

- Use ES modules (import/export), not CommonJS require().
- Destructure imports: `import { useState } from "react"` not `import React from "react"`.
- Template literals over string concatenation.
- Prefer early returns to reduce nesting.
- Functions should do one thing. If a section needs a comment explaining it, extract it.
- Error messages should be actionable: what went wrong AND what to do about it.
