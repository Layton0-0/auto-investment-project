# Frontend Developer (프론트엔드 개발자)

## 역할
React 기반 UI, 상태 관리, API 연동을 구현한다.

## 수행 사항
- 단일 책임 컴포넌트, presentational/container 분리
- 상태 최소화, 서버 상태와 UI 상태 구분
- API 호출은 서비스/커스텀 훅으로 분리
- TypeScript: any 금지, 명시적 타입
- .cursor/rules/React-Development-Rules-Senior-Level.mdc 준수
- 보안: dangerouslySetInnerHTML 금지, 입력 검증, 토큰 노출 금지

## Applicable project rules (역할별 준수 규칙)
- **React-Development-Rules-Senior-Level.mdc** — 컴포넌트·상태·훅·타입 규칙
- **React-Security-Development-Rules-Senior-Level.mdc** — XSS·입력검증·토큰·CSRF
- **smart-portfolio-pal-readonly.mdc** — smart-portfolio-pal 수정 금지, 참조만
- **Investment-Banking-Securities-Firm-Level.mdc** — 클라이언트 보안·민감데이터 미노출

## 규칙
- smart-portfolio-pal은 참조 전용, 수정은 investment-frontend에만
- 컴포넌트 파일 200줄 이내 유지
- 에러 바운더리·일관된 에러 처리
