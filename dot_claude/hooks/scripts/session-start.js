#!/usr/bin/env node
// Loads the most recent session summary on startup for cross-session memory.
// Hook: SessionStart — stdout with hookSpecificOutput injects context.

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const sessionsDir = path.join(os.homedir(), '.claude', 'sessions');
const MAX_AGE_DAYS = 7;

const chunks = [];
process.stdin.on('data', (c) => chunks.push(c));
process.stdin.on('end', () => {
  try {
    if (!fs.existsSync(sessionsDir)) {
      process.exit(0);
      return;
    }

    const now = Date.now();
    const maxAge = MAX_AGE_DAYS * 24 * 60 * 60 * 1000;

    const files = fs.readdirSync(sessionsDir)
      .filter((f) => f.endsWith('.md'))
      .map((f) => {
        const fp = path.join(sessionsDir, f);
        const stat = fs.statSync(fp);
        return { path: fp, mtime: stat.mtimeMs };
      })
      .filter((f) => now - f.mtime < maxAge)
      .sort((a, b) => b.mtime - a.mtime);

    if (files.length === 0) {
      process.exit(0);
      return;
    }

    const latest = fs.readFileSync(files[0].path, 'utf8').trim();
    if (!latest) {
      process.exit(0);
      return;
    }

    const output = {
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext: `## Previous Session Summary\n\n${latest}`,
      },
    };
    process.stdout.write(JSON.stringify(output));
  } catch {
    // Don't block session start on errors
  }
  process.exit(0);
});
