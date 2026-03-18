# Skill: Docker Workflow

**When to use**: Running or changing local or deployment Docker setup (Compose, Dockerfile) in investment-infra or subprojects.

## Procedure

1. **Environment**: Prefer existing Compose files. Full local stack: `investment-infra/docker-compose.local-full.yml` (TimescaleDB, Redis, backend, frontend, Nginx, Python services). DB-only (for local backend run): `docker-compose.local-db-only.yml`. Do not commit production secrets or host-specific paths in Compose.
2. **Ports**: Backend 8080 (Compose); 8084 for agent/local bootRun. Frontend 5173; data-collector 8001; prediction-service 8000; DB 5432; Redis 6379. Document any new ports.
3. **Backend .env**: Backend container uses `investment-backend/.env` via env_file; do not commit `.env`. Use `.env.example` or placeholders in docs.
4. **Changes**: When changing Dockerfile or Compose, ensure build and up/down work; update scripts (e.g. local-up.ps1) and docs if needed.
5. **Agent**: If agent starts backend with bootRun-agent (8084), stop the process when done (agent-cleanup). Prefer Compose for full-stack verification.
6. **Logs**: Backend logs under `investment-infra/logs/backend` or configured path; avoid committing log contents.
7. **Python services**: data-collector and prediction-service are built/run per their Dockerfiles; ensure requirements and env are consistent with backend client expectations.

## Validation

- `docker compose -f <chosen compose> up -d --build` succeeds; health checks pass where defined.  
- Backend can connect to DB and Redis; frontend can reach backend API if applicable.  
- No secrets or production URLs in committed Compose or Dockerfiles.  
- Down cleans up; no leftover volumes with sensitive data unless documented.

## Commit

- Type: `chore(infra): ...` or `fix(infra): ...`.  
- Do not commit `.env` or secret overrides.  
- TASK_LOG/CHANGELOG per hooks if required.
