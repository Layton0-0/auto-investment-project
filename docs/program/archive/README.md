# Program archive (`docs/program/archive`)

`progress.md`에서 **롤업**된 항목만 다룬다. 활성 기록은 항상 [../progress.md](../progress.md).

## 이층 구조

| 층 | 역할 | 파일 |
|----|------|------|
| **보관층** | 항목 **풀텍스트** (감사·복원) | `progress-YYYY-MM.md` — 항목마다 `### entry-YYYYMMDD-HHMM` 앵커 |
| **색인층** | 항목당 **메타 1줄** (검색·자동화) | `progress-index.jsonl` — 롤업 시 **필수** append |
| *(선택)* | 사람용 요약 표 | `INDEX.md` — 스크립트가 최근 N행만 갱신 가능 |

- **300자 규칙:** `progress.md` **한 항목(불릿)** 이 300자 넘거나 **날짜가 7일 이전**이면 롤업 대상. 월별 보관 파일 전체 길이 제한은 없다.

## `progress-index.jsonl` 스키마 (1줄 = 1 JSON 객체)

롤업 시 한 줄 append. 필드 예시:

| 필드 | 설명 |
|------|------|
| `ts` | ISO-8601 UTC 또는 로컬 시각 문자열 |
| `archiveFile` | 예: `docs/program/archive/progress-2026-04.md` |
| `anchor` | 예: `entry-20260408-1430` (`###` 헤딩 slug와 동일) |
| `files` | 문자열 배열 또는 쉼표 구분 문자열 |
| `scope` | 한 줄 요약 |
| `actor` | 예: `cursor-agent` |

## 롤업 실행

```powershell
# 저장소 루트에서
.\scripts\rollup-progress.ps1          # 실행
.\scripts\rollup-progress.ps1 -WhatIf  # 변경 없이 대상만 출력
```

- 선택: `pre-commit` / 주간 CI에서 동일 스크립트 호출.
- 포인터 형식 (progress.md에 남김): `YYYY-MM-DD [archived] 요약 → archive/progress-YYYY-MM.md#entry-...`

## 기타

- [progress-migration-2026-Q1.md](progress-migration-2026-Q1.md) — 계획 이전 분산 이력 인덱스.
