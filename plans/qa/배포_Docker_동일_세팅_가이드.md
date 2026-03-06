# 배포 Docker 동일 세팅 가이드 (D-1 / D-2)

**목적**: 로컬 풀스택(docker-compose.local-full.yml)과 **동일한 설정 원칙**으로 배포용 compose·env를 적용하고, SSH로 각 노드에 .env 세팅 후 기동·헬스 확인하는 절차를 정리한다.

**참조**:
- [investment-infra/README.md](../../investment-infra/README.md) — 노드별 .env·배포 스크립트
- [investment-infra/scripts/README.md](../../investment-infra/scripts/README.md) — deploy 스크립트·.env.example 위치
- [05-multi-vps-oracle-aws-cicd.md](../../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) — 토폴로지·스왑·CI/CD
- [13-manual-operator-tasks.md](../../investment-backend/docs/06-deployment/13-manual-operator-tasks.md) — 수동 작업 목록

---

## D-1: 배포용 Compose·Env 템플릿

### Compose 파일 (로컬 대비 배포)

| 용도 | Compose 파일 | 비고 |
|------|--------------|------|
| 로컬 풀스택 | `docker-compose.local-full.yml` | TimescaleDB, Redis, Backend, prediction, data-collector, frontend, nginx 한꺼번에. |
| Oracle 1 (데이터) | `docker-compose.oracle1.yml` | timescaledb, redis. |
| Oracle 2 (엣지) | `docker-compose.oracle2-edge.yml` | frontend, nginx. /api → AWS proxy. |
| AWS (API) | `docker-compose.aws-api.yml` | backend, prediction-service, data-collector, nginx(api). |

### Env 템플릿 위치

- **investment-infra**: `investment-infra/.env.example` — 노드 공통·노드별 필수 변수 목록(값 없음). 각 노드에서 `cp .env.example .env` 후 값 채움.
- **Backend 소스**: `investment-backend/.env.example` — Backend가 읽는 변수(SUPER_ADMIN_*, KRX_*, DART_*, JWT 등) 참고. AWS API 노드의 `.env`에는 이 값들을 함께 넣으면 됨.

### 노드별 필수 .env 변수

| 노드 | 필수 변수 예시 |
|------|----------------|
| Oracle 1 | `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` |
| Oracle 2 (엣지) | `REGISTRY`, `FRONTEND_TAG` |
| AWS (API) | `REGISTRY`, `BACKEND_TAG`, `PREDICTION_TAG`, `DATA_COLLECTOR_TAG`, `SPRING_DATASOURCE_URL`, `POSTGRES_PASSWORD`, `REDIS_HOST`, `REDIS_PORT` + Backend용(SUPER_ADMIN_*, KRX_AUTH_KEY 등) |

상세: [scripts/README.md §.env.example 및 노드별 필수 변수](../../investment-infra/scripts/README.md).

---

## D-2: SSH 배포 서버 .env 세팅·기동

### 절차 요약

1. **SSH 접속**: 해당 노드에 SSH로 접속 (GitHub Actions CD 또는 수동).
2. **저장소 최신화** (CD 시 자동): `cd ~/investment-infra && git fetch origin && git reset --hard origin/main`
3. **.env 생성/수정**:  
   - `cp .env.example .env` (최초 1회)  
   - `vim .env` 또는 `nano .env`로 위 노드별 필수 변수 및 Backend용 변수 입력. **저장소에 커밋하지 않음.**
4. **배포 스크립트 실행**:
   - Oracle 1: `./scripts/deploy-oracle1.sh`
   - Oracle 2 (엣지): `./scripts/deploy-oracle2-edge.sh`
   - AWS (API): `./scripts/deploy-aws-api.sh`
5. **헬스 확인**:
   - API 노드: `curl -s http://localhost:8080/actuator/health` → status UP
   - 엣지: `curl -s http://localhost/` → 200
   - CD 파이프라인에서는 배포 후 최대 90초 대기·10초 간격 재시도로 health 검증.

### 사전 점검

- **스왑**: [05 §3.0](https://github.com/Layton0-0/investment-infra/blob/main/../../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) — OCI 3대 각 10GB, AWS 2GB 권장. 미설정 시 OOM 위험.
- **check-node-ready.sh**: `./scripts/check-node-ready.sh` — investment-infra 존재·Docker·.env 필수 변수 중 하나라도 설정되었는지 확인.

### 운영자 수동 작업

- Certbot·Cloudflare·Security List·iptables 등: [13-manual-operator-tasks.md](../../investment-backend/docs/06-deployment/13-manual-operator-tasks.md) 참조.
