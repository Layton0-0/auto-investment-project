#!/bin/bash
# Run All Tests: Backend (JUnit) + Frontend (unit) + E2E (Playwright)
# 사용: ./scripts/run-all-tests.sh
# 전체 QA(API 시나리오, Python QA, 보안 포함)는 run-full-qa.ps1 사용

set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OVERALL_EXIT=0

echo "Running backend tests..."
(cd "$REPO_ROOT/investment-backend" && ./gradlew test) || OVERALL_EXIT=1

echo "Running frontend tests..."
(cd "$REPO_ROOT/investment-frontend" && npm test) || OVERALL_EXIT=1

echo "Running e2e tests..."
(cd "$REPO_ROOT/investment-frontend" && npx playwright test) || OVERALL_EXIT=1

if [ $OVERALL_EXIT -eq 0 ]; then echo "All tests passed."; else echo "Some tests failed. Fix and rerun."; fi
exit $OVERALL_EXIT
