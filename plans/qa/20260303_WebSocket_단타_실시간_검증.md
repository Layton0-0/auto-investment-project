# WebSocket·단타 실시간 시세 검증 보고서

**일자**: 2026-03-03  
**목적**: 단타를 위한 실시간 WebSocket 및 계산·분석 타이밍이 올바르게 개발·연동되었는지 검증

---

## 1. 요약 결론

| 구분 | 상태 | 비고 |
|------|------|------|
| WebSocket 클라이언트 구현 | ✅ 구현됨 | 연결/구독/재연결/하트비트·이벤트 발행까지 구현 |
| WebSocket → 단타/청산 연동 | ✅ 연동됨 | WebSocketPriceCacheListener가 WebSocketDataEvent 수신 시 RealtimeMarketDataService.updateFromWebSocket 호출, getCurrentPriceBlocking에서 webSocketLivePrices 우선 조회 |
| 실시간 시세 조회(단타/청산용) | ✅ WebSocket 우선 | `websocket.enabled=true` 시 WebSocket 최신가 우선, 없을 때만 REST+캐시 fallback |
| WebSocket 기본 동작 | ⚠️ 기본 비활성 | `enabled: false`(기본값). 단타 사용 시 `enabled=true` 및 장 시작 전 연결·구독 필요 |

**종합**: WebSocket 클라이언트·이벤트 리스너·RealtimeMarketDataService WebSocket 우선 조회는 구현 완료. 단타 활용을 위해선 `websocket.enabled=true` 설정 및 장 시작 전 연결·구독·단타용 캐시 TTL 조정 권장.

---

## 2. WebSocket 구현 상태 (잘 개발된 부분)

### 2.1 KoreaInvestmentWebSocketClientImpl

| 기능 | 구현 | 설명 |
|------|------|------|
| 연결/해제 | ✅ | `connect(userId, serverType)`, `disconnect`, `sessions` Map으로 세션 관리 |
| 연결 간격 | ✅ | `MIN_CONNECTION_INTERVAL_MS = 1000` (1초) 준수 |
| 토큰·approval_key | ✅ | `KoreaInvestmentTokenService` 연동, `approvalKeyFetchEnabled` 시 REST 발급 |
| 호가 구독 | ✅ | `quoteTrId`(H0STASP0), `executionTrId`(H0STCNT0)로 종목별 구독, 구독 간격 적용 |
| 체결통보 구독 | ✅ | `ccnlNoticeTrId`(H0STCNI0) |
| 구독 해제 | ✅ | tr_type "2"로 해제 메시지 전송 |
| 재연결 | ✅ | `scheduleReconnect`, 지수 백오프(`reconnectInitialDelayMs`, `reconnectBackoffMultiplier`, `reconnectMaxAttempts`) |
| 하트비트 | ✅ | `startHeartbeat`, PINGPONG(tr_type "9") 주기 전송 (`heartbeatIntervalSeconds`) |
| 구독 복원 | ✅ | 재연결 후 `restoreSubscriptions`로 호가·체결통보 재구독 |
| 메시지 파싱 | ✅ | JSON·파이프(`|`) 형식 모두 처리, `WebSocketDataEvent` 발행 |
| 종료 정리 | ✅ | `@PreDestroy`에서 하트비트·세션 정리 |

### 2.2 설정 (MarketDataProperties.WebSocketProperties)

- `baseUrlReal` / `baseUrlVirtual`, `path`, `quoteTrId`, `executionTrId`, `ccnlNoticeTrId`
- `reconnectEnabled`, `reconnectMaxAttempts`, `reconnectInitialDelayMs`, `reconnectMaxDelayMs`, `reconnectBackoffMultiplier`
- `heartbeatIntervalSeconds`, `maxSubscriptionsPerSession`(41)

### 2.3 문서와의 차이

- 재연결·Heartbeat·이벤트 리스너 연동은 **코드에 구현되어 있으며**, `14-multi-account-realtime-streaming.md` 5.2 테이블에 반영 완료.

---

## 3. 단타/청산에서의 실시간 시세 경로 (문제점)

### 3.1 실제 사용 경로

- **PipelineExitScheduler**(청산 평가): `RealtimeMarketDataService.getCurrentPrices(symbols)` → 현재가 Map 사용.
- **IntradayBreakoutService**(변동성 돌파): 동일하게 `RealtimeMarketDataService.getCurrentPrices()` 사용.

### 3.2 RealtimeMarketDataService 동작

- **getCurrentPriceBlocking(symbol)** 호출 시 **webSocketLivePrices** 맵을 먼저 조회하고, 값이 있으면 해당 값을 반환(WebSocket 실시간 반영).
- 없을 때만 **KoreaInvestmentMarketDataClient.getCurrentPrice(symbol)** → REST API 조회 후 `@Cacheable(CACHE_CURRENT_PRICE)`(TTL 5분)에 적재.
- `websocket.enabled=true`이고 구독 중인 종목은 WebSocket 수신 시 **updateFromWebSocket**으로 webSocketLivePrices 및 캐시에 반영되어 단타·청산에서 최신가 사용 가능.

### 3.3 WebSocket 수신 데이터의 사용처 (구현 완료)

- `KoreaInvestmentWebSocketClientImpl`은 수신 시 `ApplicationEventPublisher.publishEvent(WebSocketDataEvent)` 수행.
- **WebSocketPriceCacheListener**(`@ConditionalOnProperty(websocket.enabled=true)`)가 WebSocketDataEvent를 구독하여 호가(H0STASP0)/체결(H0STCNT0) 데이터를 파싱 후 **RealtimeMarketDataService.updateFromWebSocket(symbol, CurrentPriceDto)** 호출.
- 따라서 호가/체결 WebSocket 데이터가 **단타·청산 로직**에서 getCurrentPrices 경로로 사용됨.

---

## 4. WebSocket 기본 비활성

- `investment.market-data.korea-investment.websocket.enabled` 기본값 **false**.
- `NoOpKoreaInvestmentWebSocketClient`가 `matchIfMissing = true`로 등록되어, **설정 없으면 WebSocket은 동작하지 않음.**

---

## 5. 개선 권장 사항 (단타 타이밍 확보)

1. **WebSocket → 현재가 반영**
   - `WebSocketDataEvent` 리스너 추가.
   - H0STASP0(호가)/H0STCNT0(체결) 수신 시 종목별 현재가 파싱 후, **RealtimeMarketDataService가 참조하는 저장소**(예: 종목별 최신가 맵, TTL 짧은 캐시)에 반영.
   - `RealtimeMarketDataService.getCurrentPrice(symbol)` 호출 시 **WebSocket 최신가 우선 조회**, 없을 때만 REST 호출(또는 기존 캐시).

2. **단타/청산 전용 캐시**
   - 단타·청산용 현재가는 **5분 캐시 사용 중단** 또는 **WebSocket 전용 짧은 TTL(예: 1~5초)** 캐시로 분리하여, REST 캐시와 분리.

3. **WebSocket 활성화**
   - 단타·실시간 청산을 사용할 환경에서는 `investment.market-data.korea-investment.websocket.enabled=true` 및 URL·approval_key 등 설정 적용.
   - 장 시작 전 WebSocket 연결·구독(호가/체결통보)을 스케줄 또는 로그인 플로우에 포함.

4. **문서 정리**
   - `14-multi-account-realtime-streaming.md`의 “재연결·Heartbeat 미구현” 문구를 “구현됨”으로 수정.
   - “실시간 시세 조회”가 현재 REST+5분 캐시임을 명시하고, WebSocket 연동 후 경로를 문서에 반영.

---

## 6. 참고 코드 위치

| 항목 | 경로 |
|------|------|
| WebSocket 인터페이스 | `marketdata/websocket/KoreaInvestmentWebSocketClient.java` |
| WebSocket 구현체 | `marketdata/websocket/KoreaInvestmentWebSocketClientImpl.java` |
| WebSocket 이벤트 | `marketdata/websocket/WebSocketDataEvent.java` |
| 실시간 시세 서비스 | `marketdata/service/RealtimeMarketDataService.java` |
| 현재가 캐시 TTL | `config/CacheConfig.java` (currentPrice, 5분) |
| 청산 시 현재가 사용 | `factor/scheduler/PipelineExitScheduler.java` |
| 변동성 돌파 현재가 사용 | `factor/service/IntradayBreakoutService.java` |
| WebSocket 설정 | `MarketDataProperties.KoreaInvestmentProperties.WebSocketProperties` |
| WebSocket → 현재가 리스너 | `marketdata/websocket/WebSocketPriceCacheListener.java` |

---

## 7. 구현 완료 항목 (2026-03-03 갱신)

- **WebSocketDataEvent 리스너**: `WebSocketPriceCacheListener`가 H0STASP0/H0STCNT0 수신 시 `parseToCurrentPrice`로 CurrentPriceDto 생성 후 `RealtimeMarketDataService.updateFromWebSocket(symbol, dto)` 호출.
- **RealtimeMarketDataService WebSocket 우선 조회**: `getCurrentPriceBlocking(symbol)`에서 `webSocketLivePrices.get(symbol)` 우선 반환, 없을 때만 REST 및 5분 TTL 캐시 사용.
- **재연결·Heartbeat**: `14-multi-account-realtime-streaming.md` 5.2에 완료로 반영됨.
