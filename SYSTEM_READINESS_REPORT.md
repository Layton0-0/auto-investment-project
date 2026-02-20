# 헤지펀드급 로보어드바이저 시스템 종합 점검 리포트

**점검일**: 2026-02-20  
**프로젝트 비전**: "나 대신 투자해주는 고수익 로보어드바이저" - 월스트리트 최고의 퀀트 트레이더 수준 (CAGR 30%+, MDD -15% 이내)

---

## 1. 시스템 구성 현황

### 1.1 하위 프로젝트 구조

| 프로젝트 | 역할 | 기술 스택 | 상태 |
|---------|------|----------|------|
| **investment-backend** | 핵심 비즈니스 로직, API 서버 | Spring Boot 3.x, Java 17, JPA | ✅ 완료 |
| **investment-front** | 웹 프론트엔드 | React 18, TypeScript, Vite, Tailwind | ✅ 완료 |
| **investment-data-collector** | 외부 데이터 수집 (US 일봉, DART, SEC) | Python, FastAPI | ✅ 완료 |
| **investment-prediction-service** | AI/ML 예측 서비스 (LSTM) | Python, FastAPI | ✅ 완료 |
| **investment-infra** | 인프라/배포 구성 | Docker, Docker Compose, GitHub Actions | ✅ 완료 |

### 1.2 테스트 현황

| 구성요소 | 테스트 수 | 통과 | 실패 | 커버리지 |
|---------|----------|------|------|---------|
| Backend (Java) | 474 | 474 | 0 | JaCoCo 리포트 생성됨 |
| Frontend (JS/TS) | 46 | 46 | 0 | - |

---

## 2. 구현 완료 기능 (Shrimp Task 기준)

### Phase A: 핵심 리스크 관리 (P0)

| 기능 | 설명 | 상태 |
|------|------|------|
| Monte Carlo VaR/CVaR | 10,000+ 시나리오 시뮬레이션, Student-t 분포(팻테일), Cholesky 분해(상관관계) | ✅ 완료 |
| Transaction Cost Analysis (TCA) | 명시적/암묵적 비용 분석, Implementation Shortfall | ✅ 완료 |
| 매크로 지표 대시보드 | VIX, 금리, 경제지표, 환율 모니터링 | ✅ 완료 |
| Historical Stress Test | 2008 금융위기, 2020 코로나, 2022 금리인상 시나리오 | ✅ 완료 |
| Factor Zoo 프레임워크 | 15개 팩터 테스트/랭킹 (IC, IR, Quantile 분석) | ✅ 완료 |
| TWAP/VWAP/POV 알고리즘 | 대량 주문 분할 집행 | ✅ 완료 |

### Phase B: 고급 기능 (P1)

| 기능 | 설명 | 상태 |
|------|------|------|
| Regime Detection (HMM) | Bull/Bear/Neutral 시장 상태 감지 | ⏳ 대기 |

### Phase C: MLOps/고급 최적화 (P2)

| 기능 | 설명 | 상태 |
|------|------|------|
| Black-Litterman 최적화 | 투자자 뷰 반영 포트폴리오 최적화 | ⏳ 대기 |
| Strategy A/B Test | 전략 비교 테스트 프레임워크 | ⏳ 대기 |
| Live vs Backtest 대시보드 | 모델 드리프트 감지 | ⏳ 대기 |

---

## 3. 실사용을 위한 필수 설정

### 3.1 환경 변수 설정

#### Backend (.env)
```bash
# investment-backend/.env (복사: .env.example → .env)

# 한국투자증권 API (필수)
KOREA_INVESTMENT_APP_KEY=your_app_key_here
KOREA_INVESTMENT_APP_SECRET=your_app_secret_here
KOREA_INVESTMENT_SERVER_TYPE=1  # 1=모의투자, 0=실전투자

# DART API (선택)
DART_API_KEY=your_dart_api_key_here

# 데이터베이스 (필수)
DATABASE_URL=jdbc:postgresql://localhost:5432/investment
DATABASE_USERNAME=investment
DATABASE_PASSWORD=your_db_password_here

# Data Collector (선택)
DATA_COLLECTOR_URL=http://localhost:8001
```

#### Frontend (.env)
```bash
# investment-front/.env (복사: .env.example → .env)
VITE_API_BASE_URL=http://localhost:8080
```

#### Data Collector (Python)
```bash
# investment-data-collector/.env
DART_API_KEY=your_dart_api_key
SEC_API_KEY=your_sec_api_key
SPRING_BASE_URL=http://localhost:8080
DATA_COLLECTION_INTERNAL_KEY=your_internal_key
```

### 3.2 외부 서비스 API 키 발급

| 서비스 | 발급처 | 용도 |
|--------|--------|------|
| **한국투자증권 KIS API** | https://apiportal.koreainvestment.com | 실시간 시세, 주문 |
| **DART Open API** | https://opendart.fss.or.kr | 한국 공시 정보 |
| **SEC EDGAR** | https://data.sec.gov | 미국 공시 정보 |

---

## 4. 로컬 실행 가이드

### 4.1 인프라 (DB, Redis) 실행
```bash
cd investment-infra
docker compose -f docker-compose.local.yml up -d
```
- TimescaleDB: localhost:5432
- Redis: localhost:6379

### 4.2 Backend 실행
```bash
cd investment-backend
# .env 설정 후
./gradlew bootRun
```
- API 서버: http://localhost:8080
- Swagger UI: http://localhost:8080/swagger-ui.html

### 4.3 Frontend 실행
```bash
cd investment-front
npm install
npm run dev
```
- 웹 UI: http://localhost:5173

### 4.4 Python 서비스 (선택)
```bash
# Prediction Service
cd investment-prediction-service
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Data Collector
cd investment-data-collector
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8001
```

---

## 5. UI/UX 시나리오 및 사용자 개입 포인트

### 5.1 주요 화면 구성

| 경로 | 페이지 | 설명 |
|------|--------|------|
| `/` | 랜딩 페이지 | 서비스 소개 |
| `/login` | 로그인 | 사용자 인증 |
| `/signup` | 회원가입 | 계정 생성 |
| `/dashboard` | 대시보드 | 자산 현황, 포지션, 성과 요약 |
| `/auto-invest` | 자동 투자 | 4단계 파이프라인 설정/실행 |
| `/strategies/:market` | 전략 관리 | KR/US 전략 설정 |
| `/portfolio` | 포트폴리오 | 보유 종목, 수익률 |
| `/orders` | 주문 내역 | 주문 이력 조회 |
| `/backtest` | 백테스트 | 전략 검증 |
| `/news` | 뉴스/공시 | DART/SEC 공시, 뉴스 |
| `/settings` | 설정 | 계좌 연동, 알림 설정 |
| `/report/tax` | 세금 리포트 | 양도소득세 계산 |
| `/ops/*` | 운영 대시보드 | 데이터 파이프라인, 알림, 모델 상태, 감사 로그, 헬스체크, 거버넌스 |

### 5.2 사용자 개입 포인트

#### 초기 설정 (필수)
1. **회원가입/로그인**: `/signup` → `/login`
2. **증권사 계좌 연동**: `/settings` → 한국투자증권 API 키 입력
3. **전략 선택**: `/strategies/kr` 또는 `/strategies/us`
   - 변동성 돌파
   - 듀얼 모멘텀
   - Smart Money
   - 이격도
4. **투자 금액 설정**: 총 투자금, 종목당 최대 비중

#### 일상 운영
1. **대시보드 모니터링**: `/dashboard`
   - 자산 현황, 일간 손익, MDD
   - 파이프라인 실행 상태
2. **자동 투자 시작/중지**: `/auto-invest`
   - "자동매매 시작" 버튼
   - Kill Switch (긴급 중단)
3. **백테스트 실행**: `/backtest`
   - 기간, 전략, 시장 선택
   - 결과 분석 (CAGR, MDD, Sharpe)

#### 리스크 관리
1. **리스크 게이트 설정**: `/settings`
   - 일일 손실 한도 (%)
   - VIX 임계값
   - VaR 한도
2. **스트레스 테스트**: API `/api/v1/stress-test/run/{scenarioCode}`
   - 2008 금융위기, 2020 코로나, 2022 금리인상
3. **거버넌스 체크**: `/ops/governance`
   - 전략 열화 감지
   - 자동 거래 중단

### 5.3 자동화 vs 수동 개입

| 구분 | 자동화 | 수동 개입 필요 |
|------|--------|----------------|
| 시그널 생성 | ✅ 4단계 파이프라인 자동 | - |
| 주문 집행 | ✅ RiskGate 통과 시 자동 | 대량 주문 시 확인 |
| 리밸런싱 | ✅ 일정 주기 자동 | 긴급 리밸런싱 |
| 청산 | ✅ 청산 규칙 기반 | Kill Switch |
| 전략 변경 | - | ✅ 사용자 결정 |
| 투자금 변경 | - | ✅ 사용자 결정 |
| 비상 중단 | ✅ 자동 (손실한도, VIX) | ✅ Kill Switch |

---

## 6. CI/CD 배포 체크리스트

### 6.1 GitHub Actions 설정 (이미 구성됨)

#### CI (각 서비스 저장소)
- `investment-backend/.github/workflows/ci.yml`
- `investment-front/.github/workflows/ci.yml`
- `investment-prediction-service/.github/workflows/ci.yml`
- `investment-data-collector/.github/workflows/ci.yml`

#### CD (investment-infra)
- `investment-infra/.github/workflows/cd.yml`

### 6.2 GitHub Secrets 설정 (필수)

```
Settings → Secrets and variables → Actions → Secrets

# SSH 키 (각 노드별)
SSH_PRIVATE_KEY_ORACLE_OSAKA
SSH_PRIVATE_KEY_ORACLE_KOREA
SSH_PRIVATE_KEY_ORACLE_MUMBAI
SSH_PRIVATE_KEY_AWS

# Docker Registry
GHCR_PULL_TOKEN (Classic PAT with read:packages)
```

### 6.3 GitHub Variables 설정 (필수)

```
Settings → Secrets and variables → Actions → Variables

DEPLOY_HOST_ORACLE_OSAKA=xxx.xxx.xxx.xxx
DEPLOY_HOST_ORACLE_KOREA=xxx.xxx.xxx.xxx
DEPLOY_HOST_ORACLE_MUMBAI=xxx.xxx.xxx.xxx
DEPLOY_HOST_AWS=xxx.xxx.xxx.xxx
DEPLOY_USER=ubuntu
```

### 6.4 배포 노드 구성

| 노드 | 역할 | 구성요소 |
|------|------|---------|
| Oracle 1 (Osaka) | 데이터 | TimescaleDB, Redis |
| Oracle 2 (Korea) | 엣지 | Frontend (Nginx) |
| Oracle 3 (Mumbai) | 앱 | Backend, Prediction, Data Collector |
| AWS (선택) | API 스택 | Backend, Prediction, Data Collector |

### 6.5 배포 전 체크리스트

- [ ] 각 노드에 `investment-infra` 클론 완료
- [ ] 각 노드에 `.env` 파일 설정 완료
- [ ] Docker, Docker Compose 설치 완료
- [ ] GitHub Secrets/Variables 설정 완료
- [ ] GHCR 패키지 접근 권한 확인 (public 또는 PAT)

---

## 7. 현재 상태 요약

### 7.1 실사용 준비도

| 항목 | 상태 | 비고 |
|------|------|------|
| 핵심 로직 | ✅ 준비 완료 | 4단계 파이프라인, 리스크 관리 |
| 테스트 | ✅ 474/474 통과 | Backend 100%, Frontend 100% |
| CI/CD | ✅ 구성 완료 | GitHub Actions |
| 문서화 | ✅ 완료 | strategy-registry, README |
| API 키 | ⚠️ 사용자 설정 필요 | KIS, DART, SEC |
| DB/인프라 | ⚠️ 사용자 설정 필요 | Docker Compose |

### 7.2 즉시 사용 가능 여부

**결론: 조건부 YES**

1. **로컬 개발/테스트**: Docker Compose + API 키 설정 후 즉시 사용 가능
2. **실전 투자**: 
   - 모의투자(`SERVER_TYPE=1`)로 충분한 검증 후 전환 권장
   - 백테스트로 전략 성과 확인 필수
   - Kill Switch/손실한도 설정 필수

### 7.3 추가 구현 권장 사항

1. **Regime Detection (HMM)**: 시장 상태 기반 전략 자동 조절
2. **Black-Litterman**: 포트폴리오 최적화 고도화
3. **A/B Test 프레임워크**: 전략 실험 자동화
4. **Live vs Backtest 대시보드**: 모델 드리프트 실시간 감지

---

## 8. Quick Start 요약

```bash
# 1. 환경 설정
cp investment-backend/.env.example investment-backend/.env
cp investment-front/.env.example investment-front/.env
# → 각 .env에 API 키 입력

# 2. 인프라 실행
cd investment-infra
docker compose -f docker-compose.local.yml up -d

# 3. Backend 실행
cd ../investment-backend
./gradlew bootRun

# 4. Frontend 실행 (새 터미널)
cd ../investment-front
npm install && npm run dev

# 5. 브라우저에서 http://localhost:5173 접속
```

---

**작성자**: AI Assistant  
**최종 수정**: 2026-02-20
