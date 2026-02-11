# Git 푸시 워크플로우 (서브모듈 기준)

루트 저장소 `auto-investment-project`는 5개 프로젝트를 **서브모듈**로 추적합니다.  
이 문서는 **일상적인 변경 후 GitHub 푸시** 절차를 정리한 것입니다. (최초 레포 생성·푸시는 [PUSH-REPOS.md](PUSH-REPOS.md) 참고.)

---

## 1. 구조 요약

| 로컬 경로 | 기본 브랜치 | 비고 |
|-----------|-------------|------|
| investment-backend | **dev** | 나머지는 main |
| investment-data-collector | main | |
| investment-frontend | main | |
| investment-infra | main | |
| investment-prediction-service | main | |
| **루트** (auto-investment-project) | main | 서브모듈 포인터만 커밋 |

- **중요:** 서브모듈은 각자 독립 저장소이므로, **각 프로젝트 디렉터리에서 먼저 커밋·푸시**한 뒤, **루트에서 서브모듈 포인터를 갱신해 푸시**해야 합니다.
- PowerShell에서는 `&&` 대신 `;`를 사용합니다.

---

## 2. 푸시 순서 (권장)

### 2.1 서브모듈별로 커밋 후 푸시

변경이 있는 프로젝트만 진행하면 됩니다. 순서는 상관없지만, 아래 순서를 추천합니다.

1. **investment-backend** (브랜치: `dev`)
   ```powershell
   cd d:\works\pjt\auto-investment-project\investment-backend
   git add -A
   git status -s
   git commit -m "feat: 요약 메시지"
   git push origin dev
   ```

2. **investment-data-collector**
   ```powershell
   cd d:\works\pjt\auto-investment-project\investment-data-collector
   git add -A
   git commit -m "fix(investment-data-collector): 요약"
   git push origin main
   ```

3. **investment-frontend**
   ```powershell
   cd d:\works\pjt\auto-investment-project\investment-frontend
   git add -A
   git commit -m "feat(investment-frontend): 요약"
   git push origin main
   ```

4. **investment-infra**
   ```powershell
   cd d:\works\pjt\auto-investment-project\investment-infra
   git add -A
   git commit -m "docs(investment-infra): 요약"
   git push origin main
   ```

5. **investment-prediction-service**
   ```powershell
   cd d:\works\pjt\auto-investment-project\investment-prediction-service
   git add -A
   git commit -m "chore(investment-prediction-service): 요약"
   git push origin main
   ```

### 2.2 루트 저장소: 서브모듈 포인터 갱신 후 푸시

서브모듈을 푸시한 뒤, 루트에서 갱신된 커밋을 반영해 커밋·푸시합니다.

```powershell
cd d:\works\pjt\auto-investment-project
git status -s
# M investment-backend 등 변경된 서브모듈 확인
git add investment-backend investment-data-collector investment-frontend investment-infra investment-prediction-service
# 루트 자체 변경(.cursor, scripts 등)이 있으면 함께 add
git add .cursor scripts
git commit -m "chore: update submodule refs (backend, data-collector, frontend, infra, prediction-service)"
git push origin main
```

- 루트에서 **코드 변경이 없고 서브모듈 포인터만 바뀐 경우**: 위처럼 서브모듈 경로만 `git add` 후 커밋하면 됩니다.
- **루트 자체 변경**이 있으면(예: `.cursor/`, `scripts/` 수정) 해당 경로도 `git add`에 포함하고, 커밋 메시지에 함께 적습니다.

---

## 3. 커밋 메시지 규칙

- **형식:** `타입(프로젝트명): 한 줄 요약` (프로젝트명은 선택)
- **타입 예:** `feat`, `fix`, `docs`, `chore`, `refactor`
- **예시**
  - `feat(investment-backend): 거버넌스 API 및 Walk-forward 백테스트 추가`
  - `chore(investment-frontend): add Playwright report/test-results to gitignore`
  - `chore: update submodule refs (frontend, data-collector, infra, prediction-service gitignore)`

---

## 4. 주의사항

- **서브모듈을 먼저 푸시할 것.** 루트만 먼저 푸시하면, 다른 환경에서 `git pull` 시 서브모듈이 아직 없는 커밋을 가리켜 일치하지 않을 수 있습니다.
- **investment-backend**만 기본 브랜치가 `dev`이므로, 푸시 시 `git push origin dev`를 사용합니다.
- 이미 추적 중인 파일을 `.gitignore`에 추가한 경우, 저장소에서만 제거하려면:
  ```powershell
  git rm -r --cached <경로>
  git add .gitignore
  git commit -m "chore: stop tracking ... and add to gitignore"
  ```

---

## 5. 한 번에 확인하는 명령 (참고)

각 서브모듈 상태를 빠르게 보려면:

```powershell
cd d:\works\pjt\auto-investment-project
git status -sb
# 각 서브모듈
cd investment-backend; git status -sb; cd ..
cd investment-data-collector; git status -sb; cd ..
cd investment-frontend; git status -sb; cd ..
cd investment-infra; git status -sb; cd ..
cd investment-prediction-service; git status -sb; cd ..
```

이 문서는 `scripts/GIT-PUSH-WORKFLOW.md`에 있으며, 푸시 절차 변경 시 이 파일을 갱신하면 됩니다.
