# Agent 워크플로우 (퀀트·전략 개발)

Agent를 **순서대로** 사용하는 루프로 퀀트 전략·백테스트·시스템 설계를 진행한다.  
**대상**: investment-backend(Spring Boot), investment-data-collector, investment-prediction-service.  
(과거 quant-trading-system 전용 워크플로우를 메인 프로젝트 기준으로 정리한 문서이다.)

---

## 1. 전체 루프 (5단계)

```
strategist  → 전략 설계
     ↓
architect   → 시스템 설계
     ↓
dev         → 코드 작성
     ↓
backtest    → 검증
     ↓
auto        → 전체 구현 및 수정
```

---

## 2. 단계별 개요

| 단계 | Agent | 예시 활동 |
|------|-------|-----------|
| **1** | quant-strategist | 한국 단타 전략 설계(거래량 급증+돌파, 변동성 돌파 등). [18-kr-short-term-strategies-top10.md](../investment-backend/docs/02-architecture/18-kr-short-term-strategies-top10.md), [00-strategy-registry.md](../investment-backend/docs/02-architecture/00-strategy-registry.md) 참조. |
| **2** | quant-architect | 전략을 실행할 수 있는 자동투자 시스템 아키텍처 설계. Backend 4단계 파이프라인·API·DB 경계. |
| **3** | quant-dev | 설계 기반 코드 작성. Backend(factor, pipeline, backtest), data-collector, prediction-service. |
| **4** | quant-backtest | 전략 백테스트 코드·검증. Backend BacktestService, 수수료·슬리피지, CAGR/Sharpe/MDD/승률/Profit factor. [backtest-stress-results.md](../investment-backend/docs/02-architecture/backtest-stress-results.md) 참조. |
| **5** | quant-auto | 저장소 분석 → 누락 모듈 구현·로깅·테스트 보강. [03-quant-development-workflow.md](03-quant-development-workflow.md) 참조. |

---

## 3. 반자동 개발 효과

| 기존 개발           | AI 개발                    |
|--------------------|----------------------------|
| 기획 → 코딩 → 테스트 | 전략 → AI 코드 생성 → AI 테스트 → AI 리팩토링 |

개발 속도 **3~10배** 향상을 목표로 루프를 돌린다.

---

## 4. AI 전략 자동 발견 (고급)

**“AI가 전략을 자동으로 발견하는 구조”**로 확장 시:

```
AI 전략 생성
    ↓
자동 백테스트
    ↓
수익률·리스크 기준 통과한 전략만 저장
```

상세 설계: [02-ai-strategy-discovery-pipeline.md](02-ai-strategy-discovery-pipeline.md).

---

## 5. MCP 연결 (개발 자동화 보조)

- **filesystem MCP**: 코드 수정·파일 탐색
- **git MCP**: 커밋·브랜치 자동화
- **playwright MCP**: UI/API 시나리오 테스트
- **한국투자증권 MCP**: API 스펙 확인 (주문·잔고·시세 등)

(Cursor/IDE에서 MCP 서버 설정 후 위 워크플로우와 함께 사용)
