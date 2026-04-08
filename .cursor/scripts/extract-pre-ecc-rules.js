#!/usr/bin/env node
/**
 * One-off: re-export pre-ECC .cursor/rules from git with UTF-8 (run from repo root).
 */
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const COMMIT = "08a5583ccd84f0f7f8a8fab6e51fa75ce1f737ea";
const outDir = path.join(__dirname, "..", "archived-rules", "pre-ecc-source");

const files = execSync(`git ls-tree -r --name-only ${COMMIT} .cursor/rules`, {
  encoding: "utf8",
})
  .trim()
  .split("\n")
  .filter(Boolean);

fs.mkdirSync(outDir, { recursive: true });
for (const p of files) {
  const leaf = path.basename(p);
  const content = execSync(`git show ${COMMIT}:${p}`, { encoding: "utf8", maxBuffer: 10 * 1024 * 1024 });
  fs.writeFileSync(path.join(outDir, leaf), content, "utf8");
}
console.log("Wrote", files.length, "files to", outDir);
