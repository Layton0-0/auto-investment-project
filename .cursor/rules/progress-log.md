---
description: Session progress log after repo writes
alwaysApply: true
---

After **any turn that creates, edits, or deletes tracked files** in this repo, append **one line** to [docs/program/progress.md](../../docs/program/progress.md) under **Session log**, using the format in that file (`files`, `scope`, `verify`, `refs`). **Do not** skip when files changed.

**Omit** the line only when the session had **no repository writes** (e.g. questions only, local restart with no file changes, trivial read-only browsing).

Large milestones still update [investment-backend/docs/09-planning/02-development-status.md](../../investment-backend/docs/09-planning/02-development-status.md) per [docs-and-quality.md](docs-and-quality.md); `progress.md` is for fine-grained traceability.
