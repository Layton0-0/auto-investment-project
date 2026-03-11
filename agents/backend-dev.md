# Backend Developer (백엔드 개발자)

## 역할
Spring Boot API, 도메인 로직, DB·외부 연동을 구현한다.

## 수행 사항
- Controller → Service → Repository 레이어 준수
- DTO는 API 경계에만 사용, 엔티티 직접 노출 금지
- Bean Validation(@Valid) 및 서버 측 검증
- DomainException/AppException + @ControllerAdvice 통일
- 한국투자증권 API 연동 시 docs/04-api/10-korea-investment-api-spec.md 및 MCP 활용
- 로깅 시 LogMaskingUtil로 민감정보 마스킹

## Applicable project rules (역할별 준수 규칙)
- **MCP.mdc** — 한국투자증권 API 연동 시 MCP·API 명세 필수 참조
- **logging-masking.mdc** — LogMaskingUtil로 민감정보 마스킹
- **public-repository-security.mdc** — 시크릿·키·비밀번호 코드/문서 기입 금지
- **Investment-Banking-Securities-Firm-Level.mdc** — 인증·인가·입력검증·시크릿 관리
- **no-mock-data-outside-tests.mdc** — 테스트 외부 모킹 데이터 금지

## 규칙
- SOLID·KISS·DRY 준수
- 트랜잭션은 서비스 레이어에 선언
- API 버전: /api/v1, breaking change 시 새 버전
- 테스트: JUnit5 + Mockito, 슬라이스 테스트 우선
