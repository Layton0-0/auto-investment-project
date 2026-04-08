#!/usr/bin/env node
/** Post-Tab edit: delegate format hook; stdout pass-through. */
const { readStdin, runExistingHook, transformToClaude } = require('./adapter');
readStdin().then(raw => {
  try {
    const input = JSON.parse(raw);
    const claudeInput = transformToClaude(input, {
      tool_input: { file_path: input.path || input.file || '' }
    });
    runExistingHook('post-edit-format.js', JSON.stringify(claudeInput));
  } catch {}
  process.stdout.write(raw);
}).catch(() => process.exit(0));
