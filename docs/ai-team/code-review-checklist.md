# AI 코드 리뷰 체크리스트

Reviewer 역할 수행 시 또는 PR 전에 아래 항목을 점검한다. 각 항목은 해당 project rule과 연결된다.

## 보안 (Investment-Banking, public-repository-security, React-Security)

- [ ] **시크릿**: 코드·문서·이슈에 App Key, Secret, API Key, DB 비밀번호, 실제 IP 미기입
- [ ] **입력 검증**: API·폼 입력에 Bean Validation·화이트리스트 적용
- [ ] **인증/인가**: 서버 측 검증만 신뢰, 클라이언트는 UI 게이팅만
- [ ] **에러 노출**: 스택트레이스·내부 경로·DB 상세 클라이언트 노출 금지
- [ ] **로깅**: 민감정보 LogMaskingUtil 마스킹 (logging-masking.mdc)
- [ ] **프론트**: dangerouslySetInnerHTML 금지, 토큰·credentials 안전 처리, CSRF·CORS 고려

## 품질·아키텍처

- [ ] **레이어**: controller → service → domain → repository 경계 유지
- [ ] **DTO**: API 경계에서만 DTO 사용, 엔티티 직접 노출 금지
- [ ] **예외**: DomainException/AppException + @ControllerAdvice 일관
- [ ] **SOLID**: 단일 책임, 관련 규칙(React/Quant) 준수

## 테스트

- [ ] **존재**: 신규/변경 로직에 단위·슬라이스 테스트
- [ ] **타시스템 연동**: 외부 API 호출 구간은 200 엄격 (external-api-test-strict-200.mdc)
- [ ] **회귀**: 수정 후 run-all-tests 또는 run-full-qa 통과

## 문서

- [ ] **API 변경**: 01-api-overview, 02-api-endpoints, 09-korea-investment-api-guide 등 반영
- [ ] **전략/팩터 변경**: 00-strategy-registry.md + 버전 스택 갱신
- [ ] **결정 사항**: decisions.md ADR 추가·갱신
- [ ] **완료 기능**: 02-development-status.md 완료 섹션 반영

## 실행

- Cursor가 Reviewer 역할로 동작할 때 `agents/reviewer.md`의 Applicable project rules와 이 체크리스트를 함께 참조한다.
- 수동 리뷰 시 이 파일을 열고 체크한 뒤, 실패 항목은 구체적으로 코멘트로 남긴다.
