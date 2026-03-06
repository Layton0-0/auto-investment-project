# WebSocket 실시간 단타 설정 및 스케줄러 계획

## 설계 참조 (명세서·가이드 일관성)

구현 시 **명세서와 09 가이드를 동시에 참조**한다. 불일치가 있으면 09 가이드·원본 xlsx를 기준으로 명세서를 보완한다.

| 문서 | 참조 절 | 용도 |
|------|---------|------|
| [10-korea-investment-api-spec.md](investment-backend/docs/04-api/10-korea-investment-api-spec.md) | **§4.1 인증** | 실시간(웹소켓) 접속키 발급 API: path `/oauth2/Approval`, POST, approval_key 발급 |
| [10-korea-investment-api-spec.md](investment-backend/docs/04-api/10-korea-investment-api-spec.md) | **§4.5 실시간(WebSocket)** | 연결 URL·이용 순서·국내 TR_ID 요약·41건·1초·0.2초 제한 |
| [09-korea-investment-api-guide.md](investment-backend/docs/04-api/09-korea-investment-api-guide.md) | WebSocket approval_key 발급, 유량 제한·사용 정책 | Request/Response 상세, 웹소켓 이용 순서, 구독 간격 |

---

## approval_key 발급 흐름

1. **REST 발급**: `POST /oauth2/Approval` (명세서 §4.1). Body: `grant_type`, `appkey`, `secretkey`. Response: `approval_key`.
2. **구현**: `KoreaInvestmentTokenClient.getApprovalKey(accessToken, serverType)`, `KoreaInvestmentTokenService.getApprovalKey(userId, serverType)`.
3. **타이밍**: WebSocketConnectScheduler가 **08:50 KST 평일**에 connect 크론 실행. 연결 직전 또는 연결 시점에 approval_key 사용. 필요 시 08:50 직전에 REST로 발급 후 구독 메시지 `header.approval_key`에 설정.
4. **설정**: `investment.market-data.korea-investment.websocket.approval-key`에 값을 넣거나, `approval-key-fetch-enabled=true`로 두면 `KoreaInvestmentWebSocketClientImpl` 연결 시 REST로 발급 시도.

---

## approval_key 실패 시 정책

- **발급 실패 시**: 빈 문자열 또는 미설정으로 로그 남기고, 가능한 경우 **접속키 없이 연결 유지 시도** (일부 환경에서는 접근토큰만으로 구독 가능). 재시도는 1분당 1회 등 API 제한을 준수.
- **연결 실패 시**: 재연결 로직(`reconnectEnabled`, `reconnectMaxAttempts`)에 따라 백오프 재시도. approval_key는 재연결 시 다시 발급 시도 가능.

---

## 명세서 일관성

- §4.1·§4.5와 09 가이드의 path·TR_ID·이용 순서·제한 수치는 **동일하게 유지**한다.
- 코드·설정(connectCron, disconnectCron, quote-tr-id 등)은 위 명세서·09 가이드와 불일치하지 않도록 반영한다.
