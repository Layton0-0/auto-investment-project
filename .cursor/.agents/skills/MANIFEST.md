# `.cursor/.agents/skills` — canonical source

Cursor and this repo treat **`.cursor/skills/*/SKILL.md`** as the single editable source for agent skills.

This directory previously held an ECC/OpenAI duplicate tree (`SKILL.md` + `agents/openai.yaml`). That copy was removed to avoid drift. To restore OpenAI/Codex packaging, copy or symlink from `.cursor/skills/` per your harness docs.

See also: [`.cursor/archived-skills/MANIFEST.md`](../../archived-skills/MANIFEST.md), [`.cursor/CURSOR_HARNESS.md`](../../CURSOR_HARNESS.md).
