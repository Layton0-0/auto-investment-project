# AI·퀀트 개발 가이드 (메인 프로젝트 docs)

**목적**: Agent 워크플로우, AI 전략 발견 파이프라인 설계, 반자동 개발 절차를 메인 프로젝트 기준으로 정리한다.  
(과거 `quant-trading-system` 서브트리에서 추출·정리한 문서이다.)

---

## 문서 목록

| 문서 | 내용 |
|------|------|
| [01-agent-workflow-quant.md](01-agent-workflow-quant.md) | 퀀트 전략·백테스트 개발 시 Agent 순서 (strategist → architect → dev → backtest → auto). Backend·data-collector·prediction-service 기준. |
| [02-ai-strategy-discovery-pipeline.md](02-ai-strategy-discovery-pipeline.md) | AI 전략 자동 생성·백테스트·저장 파이프라인 설계. 전략 후보 → 백테스트 → 기준 통과 시 저장. |
| [03-quant-development-workflow.md](03-quant-development-workflow.md) | 반자동 개발 워크플로우 (분석 → 누락 식별 → 구현 → 로깅·테스트). Backend 및 Python 서비스 공통. |
| [04-agent-commands.md](04-agent-commands.md) | **페르소나 히스토리.** Agent별 유명 전문가 페르소나 참조용. (명령은 05 참조) |
| **[05-agent-commands-ordered.md](05-agent-commands-ordered.md)** | **Agent별 명령·순서.** 복사해 쓸 명령만 실행 순서대로 정리. 기능 개발 → 도메인 → 퀀트 루프. |

---

## 참조

- **전략·수식**: [investment-backend/docs/02-architecture/00-strategy-registry.md](../investment-backend/docs/02-architecture/00-strategy-registry.md)
- **한국 단타 전략 TOP 10**: [investment-backend/docs/02-architecture/18-kr-short-term-strategies-top10.md](../investment-backend/docs/02-architecture/18-kr-short-term-strategies-top10.md)
- **AI 팀 역할**: [ai-team.md](../../ai-team.md)
