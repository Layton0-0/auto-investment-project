#!/usr/bin/env node
/**
 * Warn if YAML frontmatter `description:` in project skills/agents exceeds max length.
 * Does not enforce on archived trees. Exit 0 always (stdout warnings only).
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..', '..');
const MAX = 320;
const paths = [
  path.join(ROOT, '.cursor', 'skills'),
  path.join(ROOT, '.cursor', 'agents'),
];

function extractDescription(content) {
  if (!content.startsWith('---')) return null;
  const end = content.indexOf('\n---', 3);
  if (end === -1) return null;
  const fm = content.slice(3, end);
  const m = fm.match(/^description:\s*(.+)$/m);
  if (!m) return null;
  let v = m[1].trim();
  if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
    v = v.slice(1, -1);
  }
  return v;
}

let warnings = 0;
for (const base of paths) {
  if (!fs.existsSync(base)) continue;
  const entries = fs.statSync(base).isDirectory()
    ? fs.readdirSync(base, { withFileTypes: true })
    : [];
  for (const ent of entries) {
    const file = ent.isDirectory()
      ? path.join(base, ent.name, 'SKILL.md')
      : path.join(base, ent.name);
    if (!file.endsWith('.md')) continue;
    if (!fs.existsSync(file)) continue;
    const content = fs.readFileSync(file, 'utf8');
    const desc = extractDescription(content);
    if (desc && desc.length > MAX) {
      console.warn(`[validate-skill-agent-description] ${path.relative(ROOT, file)}: description ${desc.length} chars (max ${MAX})`);
      warnings++;
    }
  }
}

if (warnings) {
  console.warn(`[validate-skill-agent-description] ${warnings} file(s) over limit (advisory).`);
} else {
  console.log('[validate-skill-agent-description] OK (no descriptions over ' + MAX + ' chars).');
}
