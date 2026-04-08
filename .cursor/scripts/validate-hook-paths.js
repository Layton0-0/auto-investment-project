#!/usr/bin/env node
/**
 * Smoke check: adapter getPluginRoot() defaults to .cursor and delegated hook scripts exist.
 * Run from repo root: node .cursor/scripts/validate-hook-paths.js
 */
'use strict';

const fs = require('fs');
const path = require('path');

const scriptsDir = path.resolve(__dirname);
const cursorRoot = path.resolve(scriptsDir, '..');

const adapter = require(path.join(cursorRoot, 'hooks', 'adapter'));

/** Scripts invoked via runExistingHook from .cursor/hooks/*.js */
const REQUIRED_HOOK_SCRIPTS = [
  'session-start.js',
  'session-end.js',
  'session-end-marker.js',
  'evaluate-session.js',
  'cost-tracker.js',
  'check-console-log.js',
  'pre-compact.js',
  'post-edit-format.js',
  'post-edit-accumulator.js',
  'post-edit-console-warn.js',
  'design-quality-check.js',
];

function main() {
  const hooksDir = path.join(cursorRoot, 'scripts', 'hooks');
  let failed = false;

  if (!fs.existsSync(hooksDir)) {
    console.error(`[validate-hook-paths] Missing directory: ${hooksDir}`);
    process.exit(1);
  }

  const envRoot = process.env.CLAUDE_PLUGIN_ROOT && String(process.env.CLAUDE_PLUGIN_ROOT).trim();
  if (!envRoot) {
    const resolved = path.resolve(adapter.getPluginRoot());
    const expected = path.resolve(cursorRoot);
    if (resolved !== expected) {
      console.error(
        `[validate-hook-paths] getPluginRoot() without CLAUDE_PLUGIN_ROOT must be .cursor directory.\n  got:      ${resolved}\n  expected: ${expected}`
      );
      failed = true;
    }
  }

  for (const name of REQUIRED_HOOK_SCRIPTS) {
    const p = path.join(hooksDir, name);
    if (!fs.existsSync(p)) {
      console.error(`[validate-hook-paths] Missing script: ${p}`);
      failed = true;
    }
  }

  if (failed) {
    process.exit(1);
  }

  console.log(
    `[validate-hook-paths] OK — root=${path.resolve(adapter.getPluginRoot())} scripts=${REQUIRED_HOOK_SCRIPTS.length}`
  );
}

main();
