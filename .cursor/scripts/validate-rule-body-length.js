#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const dir = path.join(__dirname, "..", "rules");
const max = 300;
let bad = 0;
for (const f of fs.readdirSync(dir).filter((x) => x.endsWith(".md") && x !== "README.md")) {
  const t = fs.readFileSync(path.join(dir, f), "utf8");
  const parts = t.split(/^---\s*$/m);
  if (parts.length < 3) {
    console.log("SKIP (no frontmatter):", f);
    continue;
  }
  const body = parts.slice(2).join("---").trim();
  const n = [...body].length;
  if (n > max) {
    console.log("FAIL", f, "body chars:", n);
    bad++;
  } else {
    console.log("OK", f, n);
  }
}
process.exit(bad ? 1 : 0);
