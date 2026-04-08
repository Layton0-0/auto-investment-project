#!/usr/bin/env node
/** Subagent stop: completion log to stderr; stdout pass-through. */
const { readStdin } = require('./adapter');
readStdin().then(raw => {
  try {
    const input = JSON.parse(raw);
    const agent = input.agent_name || input.agent || 'unknown';
    console.error(`[ECC] Agent completed: ${agent}`);
  } catch {}
  process.stdout.write(raw);
}).catch(() => process.exit(0));
