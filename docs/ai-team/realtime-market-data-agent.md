# 실시간 시장 데이터 Agent

## 목적

실시간 시세·호가·체결 스트림과 일봉/차트 데이터를 수집·가공하고, **시장 상태 요약·이상 징후 알림**을 제공하는 Agent 역할을 정의한다. Strategy·Risk Agent와 연동해 레짐·리스크 게이트에 활용한다.

## 역할 정의

- **agents/market-data-analyst.md** — Market Data Analyst 역할 상세
- 기존 백엔드: `RealtimeMarketDataService`, `KoreaInvestmentWebSocketClient`, `MarketDataController`

## 데이터 소스

| 소스 | 용도 | 비고 |
|------|------|------|
| 한국투자증권 REST | 현재가·일봉·차트·종목검색 | GET + query, MCP 참조 |
| 한국투자증권 WebSocket | 실시간 체결/호가 | TokenRefreshScheduler, 구독 관리 |
| TB_DAILY_STOCK | 과거 일봉 (백테스트·팩터) | PIT·수정주가 원칙 |
| MacroIndicatorProvider | VIX·거시 지표 (선택) | investment.risk.macro-indicator-url |

## AI Agent 활용 시나리오

1. **"지금 시장 상태 요약해줘"**  
   → Market Data Analyst 역할: 주요 지수·VIX·최근 변동성 요약 (기존 API 조회 결과 기반 설명).

2. **"이 종목 실시간 시세 알려줘"**  
   → `GET /api/v1/market-data/current-price/{symbol}` 호출 후 사용자에게 요약.

3. **시장 급락·리스크 게이트**  
   → `MarketCrashGateService`, `MacroEconomicStrategyEngine`에서 이미 구현. 실시간 데이터 연동은 기존 스케줄러·배치와 동일 경로.

4. **실시간 알림 자동화**  
   → Discord·Slack 등 알림은 `DiscordEmergencyAlertService` 확장 또는 전용 채널로 시장 요약 전송.

## 확장 시 권장 사항

- WebSocket 구독 종목/채널 설정을 외부 설정(application.yml)으로 분리
- 실시간 요약 배치(1분/5분)와 Cursor Agent 호출(온디맨드) 병행
- 데이터 보관·개인정보: 공개 저장소·로깅 시 민감정보 마스킹 유지

## 관련 문서

- [한국투자증권 API 가이드](../../investment-backend/docs/04-api/09-korea-investment-api-guide.md)
- [전략 레지스트리 § 리스크 게이트](../../investment-backend/docs/02-architecture/00-strategy-registry.md)
- agents/market-data-analyst.md
