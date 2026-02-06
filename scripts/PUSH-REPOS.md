# Polyrepo 푸시 방법

Git은 설치되어 있고, 5개 저장소(investment-infra, investment-backend, investment-prediction-service, investment-data-collector, investment-frontend) 모두 **로컬에서 초기 커밋 및 main/develop 브랜치**까지 완료된 상태입니다.

GitHub에 레포를 만들고 푸시하려면 **GitHub CLI(gh) 로그인**이 필요합니다.

## 1) gh 로그인 (한 번만)

터미널에서 실행:

```powershell
gh auth login
```

- GitHub.com 선택 → HTTPS → 브라우저에서 인증 완료.

또는 **Personal Access Token** 사용:

1. GitHub → Settings → Developer settings → Personal access tokens 에서 토큰 생성 (repo 권한)
2. PowerShell에서:
   ```powershell
   $env:GITHUB_TOKEN = "ghp_xxxx..."
   ```

## 2) 레포 생성 및 푸시

프로젝트 루트에서:

```powershell
cd d:\works\pjt\auto-investment-project
.\scripts\create-repos-and-push.ps1
```

이 스크립트는 다음을 수행합니다.

- `gh auth status`로 로그인 여부 확인 (또는 `GITHUB_TOKEN`으로 로그인)
- 없으면 **Layton0-0/investment-infra**, **investment-backend**, **investment-prediction-service**, **investment-data-collector**, **investment-frontend** 레포 생성
- 각 디렉터리에서 `origin` 설정 후 **main**, **develop** 푸시

## 레포 목록 (investment- 접두사)

| 로컬 경로 | GitHub 저장소 |
|-----------|----------------|
| investment-infra/ | Layton0-0/investment-infra |
| investment-backend/ | Layton0-0/investment-backend |
| investment-prediction-service/ | Layton0-0/investment-prediction-service |
| investment-data-collector/ | Layton0-0/investment-data-collector |
| investment-frontend/ | Layton0-0/investment-frontend |

**폴더 구조 개편 후:** 로컬에 예전 `infra/`, `services/`, `frontend/` 폴더가 남아 있으면 사용하지 않으므로 수동 삭제해도 됩니다. 푸시는 위 표의 경로만 사용합니다.
