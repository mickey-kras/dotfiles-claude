#!/usr/bin/env node
// Saves a session summary for cross-session persistence.
// Hook: Stop — reads transcript, extracts key info, writes to ~/.claude/sessions/.

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const sessionsDir = path.join(os.homedir(), '.claude', 'sessions');

const chunks = [];
process.stdin.on('data', (c) => chunks.push(c));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(Buffer.concat(chunks).toString());
    const transcriptPath = input.transcript_path;
    const sessionId = input.session_id || process.env.CLAUDE_SESSION_ID || 'unknown';
    const cwd = input.cwd || process.cwd();

    if (!transcriptPath || !fs.existsSync(transcriptPath)) {
      process.exit(0);
      return;
    }

    const lines = fs.readFileSync(transcriptPath, 'utf8').trim().split('\n');
    const userMessages = [];
    const toolsUsed = new Set();
    const filesModified = new Set();

    for (const line of lines) {
      try {
        const entry = JSON.parse(line);
        if (entry.role === 'user' && entry.content) {
          const text = typeof entry.content === 'string'
            ? entry.content
            : entry.content.map((c) => c.text || '').join('');
          if (text.trim()) userMessages.push(text.trim().slice(0, 200));
        }
        if (entry.tool_name) toolsUsed.add(entry.tool_name);
        if (entry.tool_input?.file_path) filesModified.add(entry.tool_input.file_path);
        if (entry.tool_input?.path) filesModified.add(entry.tool_input.path);
      } catch {}
    }

    if (userMessages.length === 0) {
      process.exit(0);
      return;
    }

    const lastMessages = userMessages.slice(-5);
    const summary = [
      `# Session: ${sessionId.slice(0, 8)}`,
      `- **Directory**: ${cwd}`,
      `- **Date**: ${new Date().toISOString().split('T')[0]}`,
      '',
      '## Key requests',
      ...lastMessages.map((m) => `- ${m.split('\n')[0]}`),
      '',
      '## Tools used',
      `${[...toolsUsed].join(', ') || 'none'}`,
      '',
      '## Files touched',
      ...[...filesModified].slice(0, 20).map((f) => `- ${f}`),
    ].join('\n');

    fs.mkdirSync(sessionsDir, { recursive: true });
    const filename = `${new Date().toISOString().replace(/[:.]/g, '-')}.md`;
    fs.writeFileSync(path.join(sessionsDir, filename), summary + '\n');
  } catch {
    // Never block on session save errors
  }
  process.exit(0);
});
