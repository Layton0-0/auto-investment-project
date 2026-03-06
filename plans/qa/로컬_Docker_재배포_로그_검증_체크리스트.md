# 로컬 Docker 재배포·로그 검증 체크리스트 (C-1 / C-2)

**목적**: Shrimp Phase C-1(로컬 풀스택 기동·backend/nginx 로그 확인), C-2(로컬 로그인·API 호출·로그 에러 없음) 수행 시 사용하는 체크리스트.

**참조**: [20260226-1600_로컬_docker_로그_검증_자동투자_점검.md](./20260226-1600_로컬_docker_로그_검증_자동투자_점검.md), [docker-compose.local-full.yml](../../investment-infra/docker-compose.local-full.yml).

---

## C-1: Docker local 재배포·로그 검증

| 순서 | 항목 | 명령·확인 |
|------|------|-----------|
| 1 | **풀스택 기동** | `cd investment-infra && .\scripts\local-up.ps1` (또는 프로젝트 루트에서 `.\investment-infra\scripts\local-up.ps1`). JAR 없으면 bootJar 후 up. |
| 2 | **컨테이너 Up** | `docker compose -f docker-compose.local-full.yml ps` — timescaledb, redis, backend, prediction-service, data-collector, frontend, nginx 모두 Up. |
| 3 | **Backend 로그** | `docker compose -f docker-compose.local-full.yml logs backend` — Spring Boot 기동, Flyway, Batch 스케줄 등록(`Scheduled batch job: id=auto-buy` 등), ERROR 없음 확인. |
| 4 | **Nginx 로그** | `docker compose -f docker-compose.local-full.yml logs nginx` — proxy 200, 치명적 ERROR 없음. |
| 5 | **Health** | `curl -s http://localhost:8080/actuator/health` — status UP. `curl -s http://localhost/actuator/health` (Nginx 경유) 동일. |

**로그 영구 보관**: backend는 `investment-infra/logs/backend/` 에 파일 로그 보관. 상세 로그 조회 방법은 [20260226-1600_로컬_docker_로그_검증_자동투자_점검.md §3](./20260226-1600_로컬_docker_로그_검증_자동투자_점검.md) 참조.

---

## C-2: 로컬 풀스택 E2E 로그 검증

| 순서 | 항목 | 확인 |
|------|------|------|
| 1 | **로그인** | `POST /api/v1/auth/login` → 200, token 수신. (run-api-qa.ps1 또는 브라우저 로그인) |
| 2 | **API 호출** | `.\scripts\run-api-qa.ps1` — 62건 전부 PASS. 또는 주요 API(settings, pipeline/summary, ops/auto-trading-readiness) 수동 호출. |
| 3 | **Backend 로그 에러 없음** | `docker compose -f docker-compose.local-full.yml logs backend --tail 200` — 500 스택트레이스·연결 실패 등 ERROR 없음. |
| 4 | **Nginx 로그** | proxy 5xx·502 없음. |

실패 시 [자동투자_E2E_검증_체크리스트.md §4](./자동투자_E2E_검증_체크리스트.md)에 결과·원인 기록.
