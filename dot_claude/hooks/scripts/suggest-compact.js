#!/usr/bin/env node
// Suggests /compact after a threshold of tool calls per session.
// Hook: PostToolUse — always exits 0 (non-blocking).

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const THRESHOLD = parseInt(process.env.ECC_COMPACT_THRESHOLD, 10) || 50;
const REMINDER_INTERVAL = 25;
const sessionId = process.env.CLAUDE_SESSION_ID || 'default';
const counterDir = path.join(os.tmpdir(), 'claude-hooks');
const counterFile = path.join(counterDir, `compact-${sessionId}.count`);

try {
  fs.mkdirSync(counterDir, { recursive: true });

  let count = 0;
  try {
    count = parseInt(fs.readFileSync(counterFile, 'utf8'), 10) || 0;
  } catch {}

  count++;
  fs.writeFileSync(counterFile, String(count));

  if (count === THRESHOLD) {
    process.stderr.write(
      `\n💡 You've made ${count} tool calls this session. Consider running /compact to free up context.\n`
    );
  } else if (count > THRESHOLD && (count - THRESHOLD) % REMINDER_INTERVAL === 0) {
    process.stderr.write(
      `\n💡 ${count} tool calls this session. Running /compact would help preserve context quality.\n`
    );
  }
} catch {
  // Counter errors should never block work
}

// Consume stdin
process.stdin.resume();
process.stdin.on('end', () => process.exit(0));
