#!/usr/bin/env node
// Tracks estimated API costs per session to ~/.claude/metrics/costs.jsonl.
// Hook: Stop — always exits 0 (non-blocking, async-safe).

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const PRICING = {
  'haiku':  { input: 0.80,  output: 4.00  },
  'sonnet': { input: 3.00,  output: 15.00 },
  'opus':   { input: 15.00, output: 75.00 },
};

function getRate(model) {
  const m = (model || '').toLowerCase();
  for (const [key, rate] of Object.entries(PRICING)) {
    if (m.includes(key)) return rate;
  }
  return PRICING.sonnet; // default
}

const chunks = [];
process.stdin.on('data', (c) => chunks.push(c));
process.stdin.on('end', () => {
  try {
    const input = JSON.parse(Buffer.concat(chunks).toString());
    const model = input.model || 'unknown';
    const inputTokens = input.input_tokens || input.usage?.input_tokens || 0;
    const outputTokens = input.output_tokens || input.usage?.output_tokens || 0;
    const rate = getRate(model);

    const cost = (inputTokens / 1e6) * rate.input + (outputTokens / 1e6) * rate.output;

    const metricsDir = path.join(os.homedir(), '.claude', 'metrics');
    fs.mkdirSync(metricsDir, { recursive: true });

    const record = JSON.stringify({
      timestamp: new Date().toISOString(),
      session_id: process.env.CLAUDE_SESSION_ID || 'unknown',
      model,
      input_tokens: inputTokens,
      output_tokens: outputTokens,
      estimated_cost_usd: Math.round(cost * 10000) / 10000,
    });

    fs.appendFileSync(path.join(metricsDir, 'costs.jsonl'), record + '\n');
  } catch {
    // Never block on tracking errors
  }
  process.exit(0);
});
