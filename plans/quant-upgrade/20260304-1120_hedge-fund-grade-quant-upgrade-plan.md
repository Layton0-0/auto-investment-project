# 헤지펀드급 퀀트 트레이딩 시스템 고도화 계획

**작성일**: 2026-03-04
**목표**: CAGR 30%+, MDD -15% 이내, 초보자 원클릭 자동투자

---

## 1. 현재 상태 분석

### 완성된 기반
- **4단계 파이프라인**: 유니버스 → 시그널 → 자금관리 → 매매실행
- **7개 팩터**: Disparity, Volatility Breakout, Liquidity, Smart Money, Dual Momentum, Quality Growth, Contrarian RSI
- **리스크 관리**: 킬스위치, 일일 손실 한도, 시장 급락 게이트, VaR/CVaR, Monte Carlo
- **주문 실행**: KIS API 연동, Pre-trade Compliance, Circuit Breaker, TWAP
- **20+ 배치잡**: 자동화 스케줄링 완비
- **Frontend**: Dashboard, AutoInvest, Strategy, Backtest, Settings, Ops 등 전체 화면
- **인프라**: Docker Compose, Oracle 1/2/3 + AWS 멀티 VPS

### 핵심 갭 10가지
1. UniverseFilterService 스텁 상태
2. MediumTermRebalance 모멘텀 순위 미구현
3. 한국장 9:00-10:00 동적 k값 미구현
4. 레짐 탐지(HMM/규칙) 미구현
5. PortfolioComponents 스텁
6. VWAP/POV 실행 알고리즘 미구현
7. 초보자 온보딩 UX 부재
8. 뉴스 실시간 센티멘트 스코어링 미구현
9. 성과 귀인 분석 미구현
10. 포지션 정합성 자동 검증 개선 필요

---

## 2. 8 Phase 계획

### Phase 1: 핵심 전략 엔진 고도화 (Backend) — 병렬 시작 가능
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P1-1 | UniverseFilterService 실제 구현 (KRX 시가총액/섹터/유동성) | 없음 |
| P1-2 | MediumTermRebalance 모멘텀 순위 재계산 | P1-1 |
| P1-3 | 한국장 동적 k값 변동성 돌파 | 없음 |
| P1-4 | RegimeDetectionService (VIX/이평선 기반 시장 레짐) | 없음 |
| P1-5 | FactorDecayMonitorService (팩터 성과 추적/열화 알림) | 없음 |

### Phase 2: 포트폴리오 구성 고도화 (Backend) — P1-1 이후
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P2-1 | PortfolioComponents 실 구현 (역변동성 가중) | P1-1 |
| P2-2 | 동적 리밸런싱 (drift tolerance 기반) | P2-1 |
| P2-3 | 섹터 집중도 제한 (단일 섹터 30% 상한) | P2-1 |

### Phase 3: 실행 품질 향상 (Backend) — 병렬 시작 가능
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P3-1 | VWAP 실행 알고리즘 | 없음 |
| P3-2 | 스마트 주문 타이밍 (장 시작/마감 변동성 회피) | 없음 |
| P3-3 | 시장 충격 추정 모델 (Square-Root Impact) | P3-1 |

### Phase 4: 초보자 온보딩 & UX 개선 (Full-stack) — P1-4 이후 (레짐 데이터 필요)
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P4-1 | 위험 성향 퀴즈 + 자동 전략 선택 (3문항) | 없음 |
| P4-2 | 원클릭 자동투자 시작 (센서블 디폴트) | P4-1 |
| P4-3 | 대시보드 간소화 (핵심 지표 3개 + 한줄 요약) | P1-4 |
| P4-4 | 평문 알림 시스템 (매매 사유 한글 설명) | 없음 |

### Phase 5: 데이터 & 시그널 파이프라인 강화 — 병렬 시작 가능
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P5-1 | KRX 일봉 수집 안정화 (한투 API 폴백) | 없음 |
| P5-2 | 뉴스 센티멘트 스코어링 (경량 키워드/감성사전) | 없음 |

### Phase 6: 리스크 & 운영 고도화 — P1-4 이후
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P6-1 | 드로다운 회복 모드 (MDD -10% 이후 노출 50% 축소) | P1-4 |
| P6-2 | 성과 귀인 분석 (팩터/전략별 수익 기여도) | 없음 |
| P6-3 | 자동 트레이드 저널 (모든 매매 결정 사유 기록) | P4-4 |
| P6-4 | Discord 알림 체계화 (매매/리스크/시스템 채널 분리) | 없음 |

### Phase 7: 불필요 복잡성 제거 — 독립
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P7-1 | 중복 서브모듈/Dead Code 정리 | 없음 |
| P7-2 | 설정 간소화 (초보자 디폴트 프로필) | P4-1 |

### Phase 8: 테스트 & 검증 — 각 Phase 완료 후
| ID | 태스크 | 의존성 |
|----|--------|--------|
| P8-1 | 전략 엔진 통합 테스트 (워크포워드 백테스트) | P1-1, P1-4, P2-1 |
| P8-2 | 초보자 온보딩 E2E 테스트 (Playwright) | P4-1, P4-2, P4-3 |
| P8-3 | 문서 최종 갱신 (strategy-registry v2.0) | P8-1, P8-2 |

---

## 3. 의존성 그래프 (병렬 실행 최적화)

```
[병렬 시작 가능]
P1-1 ──→ P1-2
  │──→ P2-1 ──→ P2-2
  │         ──→ P2-3
  │──→ P8-1 (P1-1 + P1-4 + P2-1)
P1-3 (독립)
P1-4 ──→ P4-3
  │──→ P6-1
  │──→ P8-1
P1-5 (독립)

P3-1 ──→ P3-3
P3-2 (독립)

P4-1 ──→ P4-2 ──→ P8-2
  │──→ P7-2
P4-4 ──→ P6-3

P5-1, P5-2, P6-2, P6-4, P7-1 (모두 독립)

P8-1 + P8-2 ──→ P8-3 (최종 문서)
```

---

## 4. 핵심 설계 원칙

1. **기존 아키텍처 유지**: 계층형+DDD, Spring Boot 3.2.2, React 18
2. **기존 인터페이스 확장**: ExecutionAlgorithm, PipelineExecutor 등 OCP 준수
3. **PIT 데이터 원칙**: 모든 팩터/전략에서 Point-in-Time 준수
4. **초보자 우선**: UI는 최소 설정, 시스템은 최대 안전
5. **테스트 필수**: line ≥80%, branch ≥70%
6. **문서 동기화**: 모든 변경 시 strategy-registry, decisions.md, development-status 갱신

---

## 5. 불필요 제거 목록

| 대상 | 조치 | 사유 |
|------|------|------|
| investment-front 서브모듈 | 삭제 | investment-frontend와 중복 |
| ComplianceEngineStub | 테스트용으로만 유지 | 실 구현체(PreTradeComplianceEngine) 디폴트 |
| 과도한 설정 노출 | 초보자 모드 숨김 | 복잡성 감소 |
| Dead Code (미구현 TODO) | 구현 또는 제거 | 코드 정리 |
