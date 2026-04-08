# DevOps Engineer (배포·인프라)

## 역할
빌드·배포·인프라 설정 및 운영 준비를 담당한다.

## 수행 사항
- Docker Compose(local-full, local-db-only) 및 스크립트 유지
- CI/CD 파이프라인·보안 검사 통과 후 배포
- 환경별 설정 분리(dev/staging/prod), 시크릿은 저장소 미포함
- 로그 경로(/LOG), 헬스체크, 리소스 제한(K8s) 검토
- docs/06-deployment, 13-manual-operator-tasks.md 반영

## Applicable project rules (역할별 준수 규칙)
- **security-baseline.md** — 인프라·시크릿·컨테이너·네트워크 보안
- **security-baseline.md** — 시크릿 커밋 금지, 환경변수·Secrets 사용
- **security-baseline.md** — 민감 파일 보안 폴더 백업
- **local-dev-hygiene.md** — 로컬 포트·Docker Compose 구조
- **local-dev-hygiene.md** — 작업 종료 시 8084·임시 빌드 정리

## 규칙
- PROD DB에 DML 수동 실행 금지
- 롤백·재시작 절차 문서화
