# 03 — Database

Database technology, schema, migrations, and access rules.

**Primary sources:**
- [investment-backend/docs/05-database/](../../investment-backend/docs/05-database/) — Schema, migrations, DB docs.
- TimescaleDB (PostgreSQL) for main data; Redis for cache/sessions.
- Rule: No manual DML on production; SQLcl SELECT only. See `.cursor/rules` and security docs.

Add DB-specific orchestration or runbook docs here; keep schema in backend docs.
