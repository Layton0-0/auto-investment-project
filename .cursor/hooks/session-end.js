#!/usr/bin/env node
/**
 * Session end: optional ECC session-end when adapter enables it. Pass-through JSON on stdout.
 */
const { readStdin, runExistingHook, transformToClaude, hookEnabled } = require('./adapter');
readStdin().then(raw => {
  const input = JSON.parse(raw || '{}');
  const claudeInput = transformToClaude(input);
  if (hookEnabled('session:end:marker', ['minimal', 'standard', 'strict'])) {
    runExistingHook('session-end-marker.js', claudeInput);
  }
  process.stdout.write(raw);
}).catch(() => process.exit(0));
