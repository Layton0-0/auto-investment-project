# 확장 가능한 자동매매 시스템 아키텍처 (Plan 히스토리)

**생성일시**: 2026-03-13 12:00  
**원본 문서**: [investment-backend/docs/02-architecture/15-scalable-automated-trading-system-architecture.md](../investment-backend/docs/02-architecture/15-scalable-automated-trading-system-architecture.md)

본 파일은 Plan 모드 산출물 히스토리로, 해당 시점의 설계 문서를 보관한 것이다.  
최신 내용은 위 원본 문서를 참조한다.

---

- 컴포넌트 다이어그램 (Data / Alpha / Risk / Execution / Observability)
- 데이터 플로우 (시장 데이터 → 시그널 → 리스크 게이트 → 주문 실행)
- 레이턴시 고려사항
- 장애 처리 (계층별, Fail-Safe, 재시도·회로차단)
- 모니터링 (메트릭·헬스·로깅·알림·운영자 체크리스트)
- 리스크 관리 프레임워크 요약
