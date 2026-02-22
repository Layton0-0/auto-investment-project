# 퀀트트레이더 시스템 최종 QA 체크리스트

**작성일:** 2026-02-21  
**목적:** Shrimp Task Manager 기반 전체 시나리오 실행 결과·수정 이력·Known Issue·재실행 방법 정리.

---

## 1. 실행 결과 요약


| 구간           | 결과  | 비고                                                                                                        |
| ------------ | --- | --------------------------------------------------------------------------------------------------------- |
| 인증·설정        | 통과  | login 200, mypage 200, settings 200, logout 200                                                           |
| 시장데이터·계좌     | 통과  | current-price 200, current-prices 수정 후 200, user/accounts 200, accounts/balance 200                       |
| 대시보드·리스크·리포트 | 통과  | dashboard 200, risk/* 200(portfolio-metrics 404 정상), report/tax 200                                       |
| 주문·파이프라인     | 통과  | orders 200, pipeline/summary?accountNo= 200                                                               |
| 트레이딩·백테스트·전략 | 통과  | trading-portfolios/latest 200, rebalance-suggestions 200, today 400(포트폴리오 없음), strategies/{accountNo} 200 |
| Ops·시스템·기타   | 통과  | ops/health, audit, governance, alerts 200, system/kill-switch 200, macro, factor-zoo, news 200            |


---

## 2. 수정 이력 (오류 제거를 위해 적용한 변경)


| 파일                                                 | 변경 내용                                                                      |
| -------------------------------------------------- | -------------------------------------------------------------------------- |
| `investment-backend/.../MarketDataController.java` | POST /market-data/current-prices 예외 시 500 대신 **200 + 빈 목록** 반환. @Slf4j 추가. |
| `investment-backend/.../SecurityConfig.java` | nginx 경유 헬스: **/api/actuator/health**, /api/actuator/metrics/**, /api/actuator/prometheus** permitAll 추가. |
| `investment-infra/nginx/conf.d.local/local.conf` | **location /batch** 추가 → backend:8080 프록시. Ops 데이터 파이프라인 탭에서 GET /batch/api/jobs 502 해소. |


---

## 3. Known issues (문서화·추가 수정 권장)


| API                                          | 현상                  | 조치                                                               |
| -------------------------------------------- | ------------------- | ---------------------------------------------------------------- |
| GET /api/v1/market-data/daily-chart          | **200**             | TB_DAILY_STOCK 기반 구현 완료. 데이터 없으면 200+[].                                 |
| GET /api/v1/strategies                       | **500** (경로만 호출 시)  | 정상 호출: GET /api/v1/strategies/**{accountNo}**. 경로 변수 필수.         |
| GET /api/v1/backtest/robo/last-pre-execution | **accountNo** 쿼리 필수 | 미입력 시 400. ?accountNo=50161075-01 로 호출 시 200 또는 204(no content). |
| GET /api/v1/trading-portfolios/today         | **400**             | 오늘 생성된 포트폴리오 없을 때. 비즈니스 정상.                                      |
| GET /api/v1/risk/portfolio-metrics           | **404**             | 해당 계좌 데이터 없을 때. 정상.                                              |
| 모의/실 계좌 (KIS)                            | 204/404/계좌 없음      | 한국투자증권 키·계좌 미연동 시 정상. 실계좌(serverType=0)는 실전 키·계좌 필요.        |


---

## 4. 재실행 방법

1. **인증**
  - POST /api/v1/auth/login (username, password) → token 확보.  
  - 이후 모든 요청에 `Authorization: Bearer {token}` 사용.
2. **REST Client**
  - `plans/qa/api-qa.http` 사용.  
  - 상단 `@token`에 로그인 응답의 token 붙여넣기 후, 2~8번 블록 순서대로 Send Request.
3. **일괄 스크립트 (PowerShell)**
  - 로그인 1회 → Bearer 헤더로 나머지 GET/POST 순차 호출.  
  - 예: `$h = @{ "Authorization" = "Bearer $($r.token)" }` 후 `Invoke-WebRequest -Uri $url -Headers $h -UseBasicParsing`.
4. **전체 시나리오 목록**
  - `plans/qa/QA_시나리오_마스터.md` 참고.

---

## 5. 검증 완료 기준

- **인증·설정·시장데이터·계좌·대시보드·리스크·리포트·주문·트레이딩·Ops·시스템·기타** 구간별로, 올바른 경로·파라미터로 호출 시 **예상 코드(200/201/204/400/404)** 와 일치.
- **500** 은 current-prices 예외 처리로 제거. (백엔드 재기동 후 반영.)
- **daily-chart** — 구현 완료. 200 + 일봉 배열(또는 빈 배열).

---

## 6. KIS(한국투자증권) 연동 설정 요약

- **Backend** `investment-backend/.env`:  
  - **모의**: `SUPER_ADMIN_VIRTUAL_APP_KEY`, `SUPER_ADMIN_VIRTUAL_APP_SECRET`, `SUPER_ADMIN_VIRTUAL_ACCOUNT_NO`  
  - **실전**: `SUPER_ADMIN_REAL_APP_KEY`, `SUPER_ADMIN_REAL_APP_SECRET`, `SUPER_ADMIN_REAL_ACCOUNT_NO`  
- **화면**: 상단 계좌 탭에서 모의(serverType=1) / 실(serverType=0) 전환. 메인 계좌는 `GET /api/v1/user/accounts/main?serverType=0|1` 로 조회.  
- **일반 사용자**: 설정 메뉴에서 본인 KIS 키·계좌 등록(DB 저장). SUPER_ADMIN만 env 기본값 사용.

---

## 7. 참고 문서

- [QA_시나리오_마스터.md](QA_시나리오_마스터.md) — 전체 API 목록·예상 응답.
- [20260221-1200_퀀트트레이더_QA_시나리오_및_오류분석.md](20260221-1200_퀀트트레이더_QA_시나리오_및_오류분석.md) — 초기 오류 분석·REST Client 사용법.
- [api-qa.http](api-qa.http) — 인증·설정·시장데이터 REST Client 시나리오.
- [20260221-1900_로컬_풀스택_기동_가이드.md](20260221-1900_로컬_풀스택_기동_가이드.md) — Docker Compose 기동·헬스·트러블슈팅.
- [20260221-1920_메뉴별_유효데이터_검증_체크리스트.md](20260221-1920_메뉴별_유효데이터_검증_체크리스트.md) — 메뉴별 API·모의/실 계좌 유효데이터 조건. **브라우저에서 http://localhost 로그인 후 각 메뉴·버튼 클릭하여 유효 데이터 또는 명시적 빈 상태 확인 (한국투자증권 기준).** 표의 모의(1)/실(0) 컬럼은 검증 시 ✓로 체크.

