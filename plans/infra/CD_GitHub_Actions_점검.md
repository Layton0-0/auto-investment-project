# CD(Continuous Deployment) GitHub Actions 점검

**점검일:** 2026-02-21  
**대상:** 프로젝트 내 모든 CD 관련 GitHub Actions 워크플로우.

---

## 1. CD 워크플로우 목록

| 저장소(경로) | 파일 | 설명 |
|--------------|------|------|
| investment-infra | `.github/workflows/cd.yml` | **유일한 CD 워크플로우.** Oracle 1/2/3, AWS 배포 및 AWS 배포 후 헬스 검증. |

**참고:** 다른 워크플로우는 모두 **CI** (빌드·테스트·이미지 푸시)이며, CD는 investment-infra의 `cd.yml` 하나만 존재함.

---

## 2. cd.yml 상세 점검

### 2.1 트리거

| 트리거 | 조건 |
|--------|------|
| `workflow_dispatch` | 수동 실행. 입력: `image_tag` (기본값 `latest`, 예: `sha-abc1234`). |
| `push` | 브랜치 `main`, 단 `**.md`, `docs/**` 경로 변경 시 제외. |

### 2.2 Concurrency

- `group: cd-deploy-${{ github.ref }}` — 동일 ref에 대해 동시 실행 1건만 허용, 새 실행 시 진행 중인 이전 실행 취소.

### 2.3 Job: deploy

- **runner:** `ubuntu-latest`
- **timeout:** 20분
- **env:** `IMAGE_TAG` (input 또는 `latest`), `DEPLOY_USER` (vars 또는 `ubuntu`)

### 2.4 스텝별 점검

| 스텝 | 조건 | Secrets | Variables | 스크립트 | 비고 |
|------|------|---------|-----------|----------|------|
| Deploy Oracle 1 (Osaka) | `vars.DEPLOY_HOST_ORACLE_OSAKA != ''` | SSH_PRIVATE_KEY_ORACLE_OSAKA | DEPLOY_HOST_ORACLE_OSAKA, DEPLOY_USER | deploy-oracle1.sh | continue-on-error: true. 노드에 .env(POSTGRES_*) 필요. |
| Deploy Oracle 2 (Korea, Edge) | `vars.DEPLOY_HOST_ORACLE_KOREA != ''` | SSH_PRIVATE_KEY_ORACLE_KOREA, GHCR_PULL_TOKEN | DEPLOY_HOST_ORACLE_KOREA, DEPLOY_USER | set-env-tags.sh, deploy-oracle2-edge.sh | FRONTEND_TAG, REGISTRY 전달. GHCR 비공개 이미지 시 토큰 필요. |
| Deploy Oracle 3 (Mumbai) | `vars.DEPLOY_HOST_ORACLE_MUMBAI != ''` | SSH_PRIVATE_KEY_ORACLE_MUMBAI | DEPLOY_HOST_ORACLE_MUMBAI, DEPLOY_USER | deploy-oracle3-mumbai.sh | 앱 스택 down + image prune만 수행. |
| Deploy AWS (API stack) | `vars.DEPLOY_HOST_AWS != ''` | SSH_PRIVATE_KEY_AWS, GHCR_PULL_TOKEN | DEPLOY_HOST_AWS, DEPLOY_USER, (선택) DEPLOY_USER_AWS | set-env-tags.sh, deploy-aws-api.sh | BACKEND_TAG, PREDICTION_TAG, DATA_COLLECTOR_TAG 전달. 노드 .env 필수. |
| Verify AWS (Backend health) | `vars.DEPLOY_HOST_AWS != ''` | SSH_PRIVATE_KEY_AWS | DEPLOY_HOST_AWS, DEPLOY_USER, DEPLOY_USER_AWS | 인라인: curl localhost:8080/actuator/health 최대 240초 대기 | continue-on-error: true. |

### 2.5 배포 스크립트·파일 존재 여부

| 스크립트 | 용도 | 의존 Compose 파일 | 상태 |
|----------|------|-------------------|------|
| deploy-oracle1.sh | Oracle 1: TimescaleDB, Redis | docker-compose.oracle1.yml | ✅ 존재 |
| deploy-oracle2-edge.sh | Oracle 2: Frontend, nginx(edge) | docker-compose.oracle2-edge.yml, docker-compose.oracle2.yml | ✅ 존재 |
| deploy-oracle3-mumbai.sh | Oracle 3: 앱 스택 제거·이미지 정리 | docker-compose.oracle2.yml | ✅ 존재 |
| deploy-aws-api.sh | AWS: Backend, prediction-service, data-collector, nginx | docker-compose.aws-api.yml | ✅ 존재 |
| set-env-tags.sh | BACKEND_TAG, FRONTEND_TAG 등 .env 반영 | — | ✅ 존재 |

필요한 compose 파일 모두 존재: docker-compose.oracle1.yml, docker-compose.oracle2.yml, docker-compose.oracle2-edge.yml, docker-compose.aws-api.yml.

### 2.6 보안·설정 요약

- **Secrets (Actions에 등록):** SSH_PRIVATE_KEY_ORACLE_OSAKA, SSH_PRIVATE_KEY_ORACLE_KOREA, SSH_PRIVATE_KEY_ORACLE_MUMBAI, SSH_PRIVATE_KEY_AWS, GHCR_PULL_TOKEN(선택, 비공개 이미지용).
- **Variables:** DEPLOY_HOST_ORACLE_OSAKA, DEPLOY_HOST_ORACLE_KOREA, DEPLOY_HOST_ORACLE_MUMBAI, DEPLOY_USER, DEPLOY_HOST_AWS. 선택: DEPLOY_USER_AWS.
- 모든 배포 스텝은 `continue-on-error: true` — 한 노드 실패 시 나머지 스텝은 계속 실행됨.

---

## 3. 수정 사항 (점검 시 반영)

| 파일 | 내용 |
|------|------|
| investment-infra/.github/workflows/cd.yml | 주석 수정: "Oracle 3 (Mumbai): Deploy and Verify failure fail the workflow (no continue-on-error)" → 실제와 맞게 "All deploy steps use continue-on-error: true" 로 변경. |

---

## 4. 점검 결론

- **CD 워크플로우:** 1개 (investment-infra/cd.yml).
- **트리거:** 수동(workflow_dispatch) 및 main push(paths-ignore 적용).
- **스크립트·compose:** 모두 존재하며 경로·이름 일치.
- **Secrets/Variables:** 문서화됨; 미설정 시 해당 스텝은 `if` 조건으로 스킵됨.
- **동작:** 모든 배포 스텝이 continue-on-error 이므로, 부분 실패 시에도 워크플로우는 성공으로 끝나며, 실패한 스텝은 로그 확인 후 수정·재실행 필요.
