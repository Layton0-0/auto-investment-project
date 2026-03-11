# 전략 테스트 (루트 tests/strategy)

이 폴더는 **AI 팀 테스트 구조**의 전략 테스트 분류용입니다.

- **전략·백테스트 관련 테스트** 위치: `investment-backend` (전략 서비스), `investment-prediction-service` (Python 단위)
- **전략 레지스트리·버전**: `docs/02-architecture/00-strategy-registry.md`
- 실행: Backend `.\gradlew test`, Python `python -m unittest discover -s tests -p "test_*.py"` (run-full-qa.ps1에 포함)

Strategy Agent가 전략 검증 테스트를 생성할 때 이 구조를 참고합니다.
