# 이력서용 개인 프로젝트 설명

이력서 **개인 프로젝트** 란에 넣을 때 복사·수정해서 사용할 수 있는 문단입니다.

---

## 프로젝트명 (한 줄)

**Investment Choi** — 한국투자증권 Open API 기반 주식 투자 수익 분석 및 자동 매매·로보어드바이저 시스템

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| **Backend** | Java 17, Spring Boot 3.2, Spring Security, JWT, Spring Batch, JPA/Hibernate, Flyway |
| **Frontend** | React 18, TypeScript, Vite 6, React Router 6, Tailwind CSS 4, Radix UI, Vitest, Playwright(E2E) |
| **DB·캐시** | TimescaleDB(PostgreSQL), Redis |
| **외부 API** | 한국투자증권 Open API (국내/해외 주식·잔고·주문·시세·WebSocket) |
| **AI·데이터** | FastAPI(Python) — LSTM 예측 서비스, yfinance 기반 US 일봉 수집, DART/KRX/SEC 공시·시세 수집 |
| **인프라** | Docker, Docker Compose, GitHub Actions(CI/CD), Gradle, Oracle Cloud(OCI) 멀티 VPS(Osaka/Korea/Mumbai) |

---

## 주요 기능 및 성과

- **자동 매매 파이프라인**: 유니버스 선정 → 팩터 시그널 → 포지션 사이징 → 주문 실행·청산의 4단계 파이프라인 구현. 국내(KR)·미국(US) 시장 분리, 단기/중기/장기 전략별 진입·청산 규칙(ATR Trailing Stop, Time-Cut, RSI 익절, 전저점 이탈 등) 적용. 로보·파이프라인 통합 오케스트레이터(auto-buy Job) 및 수정주가·PIT/Look-ahead 방지 정책 반영.
- **로보어드바이저**: 듀얼 모멘텀·섹터 상대 강도 기반 자산 배분, 백테스트(CAGR·MDD·Sharpe·Calmar)·실행 전 검증 후 리밸런싱 스케줄 실행. 전략 거버넌스(정기 백테스트·MDD/Sharpe 열화 시 자동 중단·Discord 알림).
- **백테스트 엔진**: 과거 일봉·시그널 기반 4단계 파이프라인 재생 및 로보 어드바이저 모드 지원. Friction Cost 반영, Half-Kelly·전략별 p/b 연동. Walk-Forward(Out-of-Sample)·스트레스 검증(2020/2022 구간) 지원.
- **리스크·컴플라이언스**: Pre-Trade Kill Switch, 일일 손실 한도(MDD 15% 게이트), 단일 종목 상한 10%, VIX·거시 지표 연동 리스크 게이트. Discord 긴급 알림(미체결 N분 경과·리스크 이벤트). VaR/CVaR·감사 로그·알림센터(Ops).
- **한국투자증권 API 연동**: 국내/해외 잔고·보유·주문·현재가·차트 조회(GET+query), 국내/해외 주문 실행(POST). WebSocket(실시간 호가·체결통보)·순위/투자자 API·유니버스 거래량 순위 연동. 모의·실계좌 토큰 분리, 1분 1회 토큰 발급 제한, Throttling 대응.
- **데이터 수집·팩터**: DART/SEC 공시, KRX 일별 시세, yfinance US 일봉 수집. 이격도·변동성 돌파·유동성·수급 강도·듀얼 모멘텀·퀄리티-성장·섹터 RS·Post-Earnings Drift 등 팩터·유니버스 필터 및 시그널 저장.
- **프론트엔드**: React 시니어급 구조(훅 분리·타입 명시·Error Boundary)·HttpOnly 쿠키 기반 인증·보안 가이드 문서화. 대시보드(모의/실계좌 동시 로드·성과 요약), 자동투자 현황, 전략·백테스트·설정·리스크·연말 세금 리포트·Ops(데이터 파이프라인·알림·감사·모델·헬스) 메뉴. Playwright E2E.

---

## 아키텍처·품질

- **아키텍처**: 모노리프 + 계층형(Controller → Service → Domain → Repository). Alpha-Risk-Execution 분리, 퀀트 엔진 패키지(AlphaEngine, TaxAwareOptimizer, Rebalancer, ComplianceEngine) 도입.
- **테스트**: JaCoCo 라인 80%·브랜치 70% 목표, 단위/슬라이스 테스트(@WebMvcTest, @DataJpaTest), Vitest·Playwright E2E 기반 프론트 테스트.
- **보안**: API 키·시크릿·계좌번호 로그 마스킹(LogMaskingUtil), 계좌인증·JWT·역할(User/Admin) 기반 인가, Rate limit·Circuit Breaker(Resilience4j) 적용.
- **운영**: Spring Batch 기반 스케줄 통합, Flyway 마이그레이션, OpenAPI(Swagger) 문서화. OCI 멀티 VPS(Osaka 데이터·Korea/Mumbai 앱)·GitHub Actions CI/CD.

---

## 이력서에 넣을 때 (요약 버전)

**프로젝트명**: Investment Choi — 주식 자동 매매·로보어드바이저

**기술 스택**: Java 17, Spring Boot 3.2, React 18, TypeScript, Vite 6, TimescaleDB, Redis, 한국투자증권 Open API, FastAPI(Python, LSTM), Docker, GitHub Actions, OCI 멀티 VPS

**역할·성과** (채용 공고에 맞게 2~3줄로 줄일 때 예시):
- 한국투자증권 Open API 연동(국내/해외 조회·주문·WebSocket) 및 4단계 자동 매매 파이프라인(유니버스→시그널→포지션 사이징→실행·청산)·로보어드바이저 설계·구현.
- TimescaleDB 전환, 리스크 게이트(Kill Switch·일일 손실 한도·VIX)·전략 거버넌스(열화 시 자동 중단), Friction Cost·수정주가·Walk-Forward 백테스트 엔진, 연말 세금 리포트·Ops(감사·알림·헬스) 연동.
- React 프론트(대시보드·설정·백테스트·리스크·Ops)·HttpOnly 쿠키 인증·보안 문서화, JaCoCo 80% 목표·Circuit Breaker·로깅 마스킹, Playwright E2E.

---

*작성 기준: 2026년 2월 11일 현재. 프로젝트 문서(development-status, roadmap, decisions, system-architecture) 및 소스 구조 반영.*
