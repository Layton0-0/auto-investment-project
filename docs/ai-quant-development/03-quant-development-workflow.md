# 퀀트·반자동 개발 워크플로우

**대상**: investment-backend, investment-data-collector, investment-prediction-service.  
저장소를 분석하고 누락·미완성 부분을 점진적으로 구현·개선하는 절차이다.

---

## 1. Workflow (반복 실행)

1. **Analyze** — 저장소 구조(폴더, 기존 모듈, 진입점) 분석.
2. **Identify** — 누락 모듈 또는 미완성 컴포넌트 식별 (전략 레지스트리·아키텍처 문서 대비).
3. **Implement** — 누락 컴포넌트 최소 구현 (production-style).
4. **Improve** — 기존 코드 가독성·타입·에러 처리 보강.
5. **Add logging** — 구조화 로깅, 비밀 미포함. 핵심 플로우: 수집, 시그널, 주문, 리스크.
6. **Add tests** — 단위(리스크/전략/백테스트), 필요 시 API 통합 테스트.

**반복**: 한 번에 1~2개 모듈만 다룬다.

---

## 2. 규칙

- **전체 재작성 금지.** 필요한 부분만 수정.
- **최소 변경.** 작고 리뷰 가능한 diff 선호.
- **변경 사항 요약** — 커밋 또는 응답에 짧게 설명.
- **기존 동작 유지** — 작업이 명시적으로 변경을 요구하지 않으면 유지.
- **비밀** — 코드·로그에 넣지 않음. config/env 사용.

---

## 3. Cursor 원샷 프롬프트 (전체 개선용)

한 번에 저장소를 분석하고 개선할 때 아래를 Agent에 붙여넣어 사용할 수 있다.

```
Analyze the entire repository (investment-backend and related Python services).

Then improve the automated trading system.

Tasks:
- Identify missing modules or incomplete components (vs strategy registry, architecture docs)
- Improve architecture (clear boundaries, no circular deps)
- Implement missing code (data collection, strategy, execution, risk, portfolio, backtest, monitoring, API)
- Add logging (structured; key flows: collect, signal, order, risk)
- Add tests (unit for risk/strategy/backtest; optional API)
- Optimize performance where obvious (e.g. avoid redundant loads)

Modify multiple files if needed.
Never rewrite the whole repo; change only what is necessary.
Always explain what you changed.
```

---

## 4. 참조

- **전략·수식**: [investment-backend/docs/02-architecture/00-strategy-registry.md](../../investment-backend/docs/02-architecture/00-strategy-registry.md)
- **Agent 순서**: [01-agent-workflow-quant.md](01-agent-workflow-quant.md)
- **테스트**: Backend `.\scripts\run-tests.ps1`, `run-full-qa.ps1`; Python 서비스 해당 레포 테스트 명령.
