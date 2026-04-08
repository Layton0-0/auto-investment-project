#!/usr/bin/env node
/**
 * Cursor sessionStart hook: when adapter enables session:start, forwards to legacy session-start.
 * Stdout is unchanged pass-through of stdin JSON.
 */
const { readStdin, runExistingHook, transformToClaude, hookEnabled } = require('./adapter');
readStdin().then(raw => {
  const input = JSON.parse(raw || '{}');
  const claudeInput = transformToClaude(input);
  if (hookEnabled('session:start', ['minimal', 'standard', 'strict'])) {
    runExistingHook('session-start.js', claudeInput);
  }
  process.stdout.write(raw);
}).catch(() => process.exit(0));
