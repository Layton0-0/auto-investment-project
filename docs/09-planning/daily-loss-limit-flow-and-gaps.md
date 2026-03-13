# 일일 손실 한도(Daily Loss Limit) 플로우 및 갭 분석

**역할**: Risk Analyst (Nassim Taleb 페르소나 — tail risk, robustness, explicit limits)  
**참조**: [00-strategy-registry.md §2.9](../investment-backend/docs/02-architecture/00-strategy-registry.md) (리스크 게이트·일일 손실 한도), 실제 서비스 클래스

---

## 1. 현재 플로우 요약 (Narrative)

일일 손실 한도는 **당일 기준 시초 평가액 대비 손실률**이 설정값(`daily-loss-limit-pct`, 기본 5%)을 초과하면 당일 신규 매수를 차단하는 **하드 게이트**다. 시초 평가액은 “당일 첫 파이프라인 실행 시점의 평가액”으로 기록되며, 그 시점 이후 손실률을 계산해 **100% 한도 도달 시** 매수 차단, **80% 도달 시** Discord 리스크 알림(임박)이 나가도록 되어 있다. 다만 시초 기록 시점·저장 위치·알림 실행 시간대에 따라 **꼬리 위험**이 남을 수 있어, 아래에서 점검 항목과 최소 수정 제안을 정리한다.

---

## 2. 시초 평가액(Opening Balance) 기록 시점

| 항목 | 내용 |
|------|------|
| **언제** | 당일 해당 계좌에 대해 **파이프라인 스케줄러가 처음 실행될 때** (첫 run에서만 기록) |
| **어디서** | `PipelineExecutionScheduler.runNow()` → 계좌별로 `getCurrentPortfolioValue(accountNo)` 호출 후 `recordOpeningBalanceIfAbsent(accountNo, currentValue)` 호출 |
| **코드 위치** | `PipelineExecutionScheduler` 141–144행: `currentValue != null` 이고 양수일 때만 `recordOpeningBalanceIfAbsent` 호출 |
| **의미** | “시초”는 **장 시작 시초가가 아니라**, 당일 **첫 파이프라인 실행 시점의 평가액**이다. (예: KR 09:10, KR 오후 14:35, US 05:05 중 해당 계좌에 대해 먼저 도는 실행) |

**참고**: `IntradayBreakoutScheduler`는 `recordOpeningBalanceIfAbsent`를 호출하지 않으며, `isNewBuyAllowed`만 호출한다. 따라서 시초 평가액은 **오직 PipelineExecutionScheduler**를 통해서만 기록된다.

---

## 3. 한도 검사 시점 및 동작

| 검사 | 시점 | 동작 |
|------|------|------|
| **신규 매수 허용 여부** | 파이프라인 실행 직전, 장중 변동성 돌파 실행 직전 | `DailyLossLimitService.isNewBuyAllowed(accountNo)` → `lossPct >= dailyLossLimitPct` 이면 `false` (당일 신규 매수 스킵) |
| **호출 위치** | (1) `PipelineExecutionScheduler` 145–151행 (2) `IntradayBreakoutScheduler` 102행 | 스킵 시 로그: `PipelineSkipReason.DAILY_LOSS_LIMIT` / “일일 손실 한도 초과” |
| **80% 임박 알림** | Batch Job `risk-event-alert` | `RiskEventAlertService.checkAndSendAlerts()`: `ratio = lossPct / dailyLimitPct`, `ratio >= alertMddThresholdPct`(기본 0.8) 이면 Discord 리스크 알림 발송, 60분 쿨다운 |

- **한도 초과 시 동작**: 신규 매수만 차단, 매도는 허용(동일하게 `isNewBuyAllowed`만 사용).
- **설정**: `investment.risk.daily-loss-limit-pct`(기본 5), `investment.risk.alert-mdd-threshold-pct`(기본 0.8).

---

## 4. 점검 체크리스트

- [x] **시초 평가액 기록**: 당일 첫 파이프라인 실행 시 `recordOpeningBalanceIfAbsent`로 기록됨 (`PipelineExecutionScheduler`).
- [x] **100% 한도 도달 시**: `isNewBuyAllowed == false` → 파이프라인·장중 돌파 모두 신규 매수 스킵.
- [x] **80% 도달 시 알림**: `RiskEventAlertService`에서 `ratio >= 0.8` 이면 Discord 알림; 설정은 `alert-mdd-threshold-pct: 0.8`.
- [x] **검사 적용 위치**: 파이프라인 실행 전 + 장중 변동성 돌파 실행 전 모두 `DailyLossLimitService.isNewBuyAllowed` 호출.
- [ ] **시초 평가액 영속성**: 현재 인메모리(`ConcurrentHashMap`) → 재기동 시 소실, 당일 “시초”가 다음 실행 시점 평가액으로 바뀜.
- [ ] **시초 정의**: “장 시초”가 아니라 “당일 첫 파이프라인 실행 시점” 평가액임을 문서/운영 가이드에 명시할 필요 있음.
- [ ] **미국장 시간대 알림**: `risk-event-alert` 크론이 `0 */10 9-15 * * MON-FRI`(09:00~15:59 KST, 10분마다) → US 마감 구간(05:05 KST 등)에는 배치가 돌지 않아, 해당 시간대 80% 임박 알림이 나가지 않음.

---

## 5. 갭 및 권장 변경 (Minimal)

### GAP 1: 시초 평가액 비영속 (재기동 시 한도 우회 가능)

- **문제**: `openingBalanceByAccountAndDate`가 인메모리라 서버/팟 재기동 시 초기화됨. 재기동 후 첫 실행 시 “시초”가 그 시점 평가액으로 다시 잡혀, 이미 손실이 난 상태여도 당일 한도가 사실상 리셋될 수 있음.
- **권장**: 시초 평가액을 **계좌·일자** 단위로 DB 또는 Redis에 저장하고, `DailyLossLimitService`에서 해당 저장소를 읽/쓰도록 변경. (예: `TB_DAILY_OPENING_BALANCE(account_no, bas_dt, opening_balance)` 또는 Redis 키 `daily_loss_limit:opening:{accountNo}:{yyyy-MM-dd}`.)
- **대상**: `DailyLossLimitService` — 저장소 인터페이스 주입 후 `recordOpeningBalanceIfAbsent` / `getOpeningBalance` 구현을 영속 저장으로 교체.

### GAP 2: 80% 알림이 “시초 미기록” 계좌에서만 스킵

- **문제**: `RiskEventAlertService`는 `getSummary` → `getAccountSummaries`에서 `dailyLossLimitService.getOpeningBalance(accountNo, today)`를 쓰며, opening이 null이면 해당 계좌를 `continue`로 스킵함. 당일 파이프라인이 한 번도 안 돌았으면 시초가 없어 80% 알림이 아예 나가지 않음.
- **현재 설계**: “시초는 첫 파이프라인에서만 기록”이므로, 09:00에 `risk-event-alert`만 돌면 아직 시초가 없을 수 있음. 09:10 파이프라인 이후 09:10, 09:20, … 알림에서는 시초가 채워져 동작함.
- **권장**: (1) 전략 레지스트리/운영 문서에 “일일 손실 한도 임박 알림은 당일 파이프라인이 최소 1회 실행된 계좌에 한해 유효”라고 명시. (2) 선택 사항: 당일 00:00 또는 장 시작 전에 “전일 종가 평가액”을 시초로 미리 넣는 배치를 두면, 장 시작 전·초반에도 80% 알림이 가능해짐 (요구사항이 있으면 추가).

### GAP 3: 미국장 시간대 80% 알림 미동작

- **문제**: `risk-event-alert`가 09:00~15:59 KST, 10분마다만 실행되므로, 05:05 KST US 마감 구간 등에는 실행되지 않음.
- **권장**: 리스크 알림을 미국장에도 쓰려면, 크론을 확장하거나 별도 스케줄 추가. 예: `BatchJobRegistry`에서 `risk-event-alert` 크론을 `0 */10 0-15,23 * * MON-FRI` 형태로 23시대(미국 장중)를 포함하거나, 동일 Tasklet을 호출하는 별도 Job을 `0 5 5 * * MON-FRI` 등으로 등록.

### GAP 4: 80%에서의 “차단” 없음 (설계 선택)

- **현재**: 80%는 **알림만**, 100%에서만 **신규 매수 차단**.
- **권장**: 설계상 “80%에서 경고만”이면 변경 불필요. “80% 도달 시 신규 매수 비중 50%로 축소” 등 소프트 게이트를 넣으려면, `RiskGateService` 또는 `PipelineExecutionScheduler`에서 `DailyLossLimitService`에 “당일 손실률 / 한도” 비율을 반환하는 메서드를 두고, 비율 ≥ 0.8일 때 `sizeMultiplier`를 줄이는 방식으로 확장 가능. (설정 예: `investment.risk.daily-loss-approach-scale-pct: 50`.)

---

## 6. 요약 표

| 구분 | 현재 동작 | 설정/위치 |
|------|-----------|-----------|
| 시초 기록 시점 | 당일 **첫** 파이프라인 실행 시 평가액 | `PipelineExecutionScheduler` 141–144행 |
| 100% 한도 검사 | lossPct ≥ dailyLossLimitPct → 신규 매수 스킵 | `DailyLossLimitService.isNewBuyAllowed`, `investment.risk.daily-loss-limit-pct` (기본 5) |
| 80% 임박 알림 | ratio ≥ 0.8 시 Discord 리스크 알림, 60분 쿨다운 | `RiskEventAlertService`, `investment.risk.alert-mdd-threshold-pct` (기본 0.8), Batch `risk-event-alert` |
| 검사 호출처 | 파이프라인 실행 전, 장중 변동성 돌파 실행 전 | `PipelineExecutionScheduler`, `IntradayBreakoutScheduler` |

---

## 7. 권장 변경 요약 (Bullet)

- **필수 권장**: 시초 평가액을 **DB 또는 Redis에 영속**하여 재기동 후에도 당일 한도가 리셋되지 않도록 함. (`DailyLossLimitService` + 저장소/레포 또는 Redis 템플릿.)
- **문서**: 00-strategy-registry.md §2.9 또는 운영 가이드에 “시초 = 당일 첫 파이프라인 실행 시점 평가액”, “80% 알림은 당일 파이프라인 1회 이상 실행된 계좌에 한해 유효” 문구 추가.
- **선택**: 미국장 시간대 80% 알림을 쓰려면 `risk-event-alert` 크론 확장 또는 US 대역 전용 스케줄 추가.
- **선택**: 80% 도달 시 매수 비중 축소(소프트 게이트)가 필요하면, `DailyLossLimitService`에 “한도 대비 비율” 조회 메서드 추가 후 `PipelineExecutionScheduler`의 sizeMultiplier에 반영.

이 문서는 [00-strategy-registry.md §2.9](investment-backend/docs/02-architecture/00-strategy-registry.md) 및 실제 서비스 클래스(`DailyLossLimitService`, `PipelineExecutionScheduler`, `RiskEventAlertService`)를 기준으로 작성되었으며, tail risk와 명시적 한도 관점에서 갭을 최소 수정으로 보완하는 방향을 제안한다.
