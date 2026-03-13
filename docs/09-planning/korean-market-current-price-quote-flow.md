# 한국 시장 현재가·호가 조회 흐름 (Current-Price & Quote Flow)

**역할**: Market Data Analyst (market microstructure, data quality)  
**참조**: [10-korea-investment-api-spec.md](../investment-backend/docs/04-api/10-korea-investment-api-spec.md), 한국투자증권 MCP, [09-korea-investment-api-guide.md](../investment-backend/docs/04-api/09-korea-investment-api-guide.md)

---

## 1. 진입점 (Frontend / Pipeline)

| 호출자 | API | 백엔드 |
|--------|-----|--------|
| 프론트엔드 | `GET /api/v1/market-data/current-price/{symbol}` | `MarketDataController.getCurrentPrice()` |
| 프론트엔드 / 파이프라인 | `POST /api/v1/market-data/current-prices` (body: `["005930", ...]`) | `MarketDataController.getCurrentPrices()` |

- **Controller**: `investment-backend` → `MarketDataController`  
- **서비스**: `RealtimeMarketDataService.getCurrentPrice(symbol)` → 내부에서 `getCurrentPriceBlocking(symbol)` 호출  
- **일괄 조회**: `getCurrentPrices(symbols)`는 종목별로 `getCurrentPriceBlocking(symbol)`을 병렬 호출(동일 캐시·동일 흐름).

---

## 2. 현재 구현 흐름 (실제 실행 순서)

### 2.1 단일 종목: `getCurrentPriceBlocking(symbol)`

**실제 순서 (코드 기준):**

1. **Spring 캐시 (AOP)**  
   - `@Cacheable(value = "currentPrice", key = "#symbol")` 때문에 **메서드 진입 전**에 캐시 조회가 수행됨.  
   - **캐시 히트** → 메서드 본문이 실행되지 않고 **캐시된 값 즉시 반환**.  
   - **캐시 미스** → 아래 2·3 단계로 진행.

2. **WebSocket 라이브 맵**  
   - 메서드 진입 시 `webSocketLivePrices.get(symbol)` 조회.  
   - 값이 있으면 해당 `CurrentPriceDto` 반환 (그리고 이 반환값이 Spring에 의해 캐시에 저장됨).

3. **REST 폴백**  
   - `webSocketLivePrices`에 없으면 `KoreaInvestmentMarketDataClient.getCurrentPrice(symbol)` 호출.  
   - 한투 API: **GET** `/uapi/domestic-stock/v1/quotations/inquire-price`  
     - TR_ID: `FHKST01010100` (실전/모의 동일, 명세 §4.4)  
     - Query: `FID_COND_MRKT_DIV_CODE=J`, `FID_INPUT_ISCD={6자리 종목코드}`  
   - 응답의 `output.stck_prpr` 등으로 `CurrentPriceDto` 생성 후 반환(및 캐시 저장).  
   - Circuit Breaker `marketDataService` 적용; 실패 시 `getCurrentPriceBlockingFallback` → `null` 반환 → API는 404.

### 2.2 캐시·WebSocket 갱신

- **캐시**: `CacheConfig.CACHE_CURRENT_PRICE` (Redis 또는 simple), TTL = `investment.market-data.current-price-cache-ttl-seconds` (기본 300초).  
- **WebSocket**: `KoreaInvestmentWebSocketClientImpl`이 호가/체결 수신 시 `WebSocketDataEvent` 발행.  
  - **이벤트 → 현재가 반영**: 설계상 `WebSocketPriceCacheListener` 등이 `WebSocketDataEvent`를 구독해 `RealtimeMarketDataService.updateFromWebSocket(symbol, CurrentPriceDto)`를 호출해야 함.  
  - `updateFromWebSocket`은 `webSocketLivePrices`에 넣고, `CacheManager`가 있으면 `currentPrice` 캐시에도 `put(symbol, dto)` 수행.  
  - **현재 코드베이스**: `WebSocketDataEvent`를 구독해 `updateFromWebSocket`을 호출하는 **리스너 클래스는 없음**. 따라서 실제로는 WebSocket 수신 데이터가 현재가 캐시/맵에 반영되지 않고, **캐시 → (캐시 미스 시) REST**만 사용 중.

---

## 3. 데이터 품질 관점 요약

| 단계 | 설명 | 비고 |
|------|------|------|
| (1) 캐시 | Spring `@Cacheable`로 **캐시가 먼저** 조회됨. 히트 시 메서드 미실행. | **버그**: 캐시 히트 시 WebSocket 라이브맵을 보지 않음 → 아래 §4. |
| (2) WebSocket | 메서드가 실행될 때만 `webSocketLivePrices` 참조. 설계상 호가(H0STASP0)/체결(H0STCNT0) 수신 시 리스너가 `updateFromWebSocket` 호출. | 리스너 미구현으로 현재는 미사용. |
| (3) REST | 한투 주식현재가 시세 API (inquire-price). GET + query, TR_ID FHKST01010100. | 명세·MCP 기준 준수. |

---

## 4. 버그: 캐시 히트 시 WebSocket 최신가 미반영 (Stale cache over WebSocket)

### 현상

- `@Cacheable`은 **AOP로 메서드 호출 전**에 캐시를 조회한다.  
- **캐시 히트**이면 `getCurrentPriceBlocking` 본문이 실행되지 않으므로 **`webSocketLivePrices`를 전혀 보지 않고** 이전에 캐시된 값(REST 또는 과거 WebSocket)을 그대로 반환한다.  
- 따라서 (리스너가 구현된 이후) WebSocket으로 더 최신 호가/체결이 들어와 `webSocketLivePrices`만 갱신되고, Redis/캐시는 갱신 실패·지연·다른 노드 미동기화 등으로 예전 값이 남아 있으면, **캐시 히트 시 구식 가격이 반환될 수 있다.**

### 권장 실행 순서 (시장 미세구조·데이터 품질)

1. **WebSocket 라이브맵** (최신 체결/호가 반영)  
2. **캐시** (과거 REST/WebSocket 결과)  
3. **REST** (캐시 미스 시 한투 현재가 API)

### 적용된 수정 (2026-03)

- **파일**: `investment-backend/src/main/java/com/investment/marketdata/service/RealtimeMarketDataService.java`  
- **변경**: `@Cacheable` 제거 후, **메서드 내부**에서 순서 (1) WebSocket 라이브맵 (2) 수동 캐시 조회 (3) REST API 호출 및 캐시 put.  
- 이로써 **항상 WebSocket → 캐시 → REST** 순서가 보장되어, WebSocket에 더 최신 데이터가 있을 때 캐시가 구식이어도 최신가를 반환한다.

---

## 5. 참조

- **한국투자증권 API 명세**: [10-korea-investment-api-spec.md](../investment-backend/docs/04-api/10-korea-investment-api-spec.md) §4.4 시세, §4.5 실시간(WebSocket).  
- **한투 MCP**: 신규/수정 API는 MCP로 path·TR_ID·GET/POST·파라미터 검증.  
- **현재가 REST**: `KoreaInvestmentMarketDataClient.getCurrentPrice()` → GET `/uapi/domestic-stock/v1/quotations/inquire-price`, TR_ID `FHKST01010100`.
