# Strategy 자동 생성 AI (전략 자동 생성 플로우)

## 목적

사용자 요청(예: "RSI + 이동평균 전략 추가해줘", "새 매매 전략 생성 후 백테스트해줘")을 받으면 **AI 팀이 Planner → Architect → Strategy Analyst → Backend Dev → QA → 백테스트 실행**까지 한 번에 수행하도록 하는 플로우이다.

## 워크플로우

1. **Planner**: 요청 분석 → "신규 전략 모듈 추가" 명세 작성 → Shrimp로 태스크 분해  
   - Task 1: 전략 명세·파라미터 정의  
   - Task 2: 백엔드 전략/팩터 코드  
   - Task 3: 백테스트 연동  
   - Task 4: UI 패널(선택)  
   - Task 5: 테스트 작성·실행  

2. **Architect**: 기존 아키텍처 정합성 확인  
   - `docs/02-architecture/00-strategy-registry.md`, `05-quantitative-strategy.md`, `12-auto-investment-strategy.md`  
   - StrategyType 확장 필요 시 enum·파이프라인 진입점 검토  
   - PIT·Look-ahead·수정주가 원칙 유지  

3. **Strategy Analyst**: 전략 가설·수식·파라미터 정의  
   - 전략 레지스트리에 새 섹션 추가 (버전·변경 이력)  
   - Quant-Trading-System.mdc 원칙 준수  
   - 리스크 한도·킬스위치 고려  

4. **Backend Developer**: 구현  
   - 팩터/시그널: `factor.service.*`, `PositionSizingService`, `ExitRuleEvaluator` 등  
   - 결정론적·재현 가능, 파라미터는 `application.yml` 또는 DB  
   - 한국투자증권/시세 API 사용 시 MCP·API 명세 참조  

5. **QA**: 단위·통합·백테스트 검증  
   - `BacktestService`로 기간·시장·전략타입 지정 후 실행  
   - 메트릭(MDD, CAGR, Sharpe 등) 확인  
   - 테스트 코드 생성·실행 필수  

6. **Run backtest**: `.\scripts\run-backtest.ps1` 또는 `POST /api/v1/backtest` 호출로 검증  

7. **Reviewer**: 코드 리뷰·보안·문서 반영 확인  

## 사용자 예시 명령

- "RSI + 이동평균 전략 모듈 추가해줘. 백엔드 API, 전략 계산, 백테스트, UI 패널, 테스트 포함."
- "Generate a new trading strategy and backtest it."
- "변동성 돌파 파라미터 k 조정 가능하도록 하고, 백테스트 돌려서 결과 알려줘."

## 전략 스펙 템플릿 (AI가 채울 때 참고)

새 전략을 추가할 때 아래를 명세로 채우면 구현이 수월하다.

| 항목 | 내용 |
|------|------|
| 전략명 | (예: RSI_MA_COMBO) |
| 가설·엣지 | 어떤 비효율을 이용하는지 |
| 타임호라이즌 | 단기/중기/장기 (StrategyType) |
| 입력 데이터 | 일봉/분봉, 지표(RSI, MA 등) |
| 진입 규칙 | 수식·조건 |
| 청산 규칙 | 시간절단·트레일링·손절 등 |
| 파라미터 | 기본값, application.yml 키 |
| 리스크 | MDD 한도, 포지션 사이징 |

## 관련 파일

- 전략 통합 문서: `investment-backend/docs/02-architecture/00-strategy-registry.md`
- 백테스트: `BacktestService`, `BacktestController`, `POST /api/v1/backtest`
- 자동 실행 스크립트: `scripts/run-backtest.ps1`
