# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **distributed auto-investment system** with multiple microservices, designed for algorithmic trading using Korean securities APIs. The system analyzes portfolio performance and executes trades automatically based on quantitative strategies.

**Tech Stack:**
- **Backend**: Spring Boot 3.2.2, Java 17, PostgreSQL/TimescaleDB, Redis, Gradle
- **Frontend**: React 18, Vite, TypeScript, Tailwind CSS, Radix UI
- **Testing**: JUnit, Mockito (backend); Vitest, Playwright (frontend)
- **Infrastructure**: Docker Compose (local), GitHub Actions (CI/CD), Nginx
- **IDE**: Cursor, IntelliJ IDEA

## Repository Structure

This is a **monorepo with Git submodules**. Each submodule is a standalone repository:

```
auto-investment-project/
├── investment-backend/        # Spring Boot API server
├── investment-frontend/       # React client (Vite)
├── investment-infra/          # Docker Compose, CI/CD, deployment
├── investment-data-collector/ # Python data pipeline
├── investment-prediction-service/ # ML model service
├── smart-portfolio-pal/       # Lovable-owned; read-only reference here (do not edit)
└── .cursor/rules/             # Cursor IDE development rules
```

All submodules are development branches (`dev` or `main`) and are committed by reference to the parent repository.

**Do not modify `smart-portfolio-pal/`** — it is owned and edited in Lovable only. This repo keeps it as a read-only submodule pointer; never commit changes from here into that directory. Sync it only with `git submodule update` from the repo root when the parent updates the submodule revision.

## Quick Start: Local Development

### Prerequisites
- PowerShell 7+ (Windows)
- Docker Desktop with Compose
- Java 17 (IntelliJ or CLI)
- Node.js 18+ (frontend)
- Python 3.9+ (data collector, optional)

### Full Local Stack (Recommended)

```powershell
# Run from investment-infra/
cd investment-infra
./scripts/local-up.ps1
# Brings up: PostgreSQL/TimescaleDB, Redis, Backend (8080), Frontend, Nginx
```

### Selective Development (Backend or Frontend Only)

#### Backend Only
```powershell
# Terminal 1: Start Docker services (DB, Redis, Python services)
cd investment-infra
./scripts/local-up-db-only.ps1

# Terminal 2: Run backend on port 8084
cd investment-backend
./scripts/bootRun-agent.ps1
# or via IntelliJ: Run → Edit Configurations → Active profiles: local,intellij
```

#### Frontend Only
```powershell
cd investment-frontend
npm install
npm run dev
# Runs on http://localhost:5173, proxies /api to http://localhost:8084 (or 8080 if Docker stack running)
```

### Key Ports

| Service | Port | Environment | Details |
|---------|------|-------------|---------|
| Backend (Docker) | 8080 | Docker Compose | Use for scripts, API docs, QA |
| Backend (Dev) | 8084 | Direct run | For IDE development; requires DB services running |
| Frontend | 5173 | Vite dev | npm run dev |
| Nginx | 80 | Docker | Routes `/api` to backend, serves frontend |
| PostgreSQL | 5432 | Docker Compose | VITE_API_BASE_URL=http://localhost:8080 to use Docker backend |
| Redis | 6379 | Docker Compose | - |

**CORS**: Localhost (5173, 127.0.0.1:5173) is pre-allowed; no extra config needed.

## Building & Testing

### Backend (investment-backend)

**Build:**
```powershell
cd investment-backend
./gradlew build              # Full build with tests
./gradlew build -x test      # Skip tests
```

**Test:**
```powershell
./gradlew test               # All tests
./gradlew test --tests "com.investment.account.*"  # Filter by package/class
./scripts/run-tests-with-coverage.ps1               # With JaCoCo coverage report
```

**Run (IDE):**
- IntelliJ: Active profiles = `local,intellij`
- Cursor/Agent: Use `scripts/bootRun-agent.ps1`

**API Documentation:**
- Swagger UI: `http://localhost:8084/swagger-ui.html` (or 8080 for Docker)
- OpenAPI JSON: `http://localhost:8084/v3/api-docs`

### Frontend (investment-frontend)

**Dev:**
```powershell
cd investment-frontend
npm install
npm run dev
```

**Build:**
```powershell
npm run build     # Production build (vite build)
npm run preview   # Preview production build locally
```

**Test:**
```powershell
npm test          # Vitest (unit + integration)
npm run test:e2e  # Playwright E2E tests
npm run test:e2e:ui    # Interactive test UI
npm run test:e2e:debug # Debug single test
```

## Architecture Highlights

### Core Domain Model
- **Accounts**: Multiple account support, balance/position tracking
- **Orders**: Buy/sell orders with execution tracking
- **Strategies**: Configurable quantitative strategies (factor-based, trend-following, etc.)
- **Analysis**: Per-stock/portfolio analysis results
- **Settings**: Max/min investment amounts, trading limits

### Key Patterns

**Backend:**
- **Layered**: Controller → Service → Repository → Entity
- **Event-driven**: Strategy executions trigger order placement
- **Async**: WebFlux for non-blocking I/O; Batch jobs for scheduled tasks
- **Resilience4j**: Circuit breaker for external API calls (Korean Investment API)
- **Cache**: Redis for market data, account snapshots (TTL-based)

**Frontend:**
- **Component-centric**: Single responsibility, max 200 lines per component
- **State separation**: Server state (API responses) vs. UI state (local forms)
- **No derived state**: Derived values computed on-render, not stored
- **Custom hooks**: Business logic extracted (useAccounts, useOrders, etc.)
- **Async patterns**: Loading/error states explicitly handled; no logic in useEffect

### Database Schema
- PostgreSQL with TimescaleDB (hypertable-ready for time-series data)
- Flyway migrations: `src/main/resources/db/migration/`
- Schema: Accounts → Orders → Positions → MarketData

See: `investment-backend/docs/05-database/01-database-schema.md`

## Important Development Rules

These rules are enforced via Cursor `.cursor/rules/*.mdc` files. Key ones:

### General
- **Agent cleanup** (`agent-cleanup.mdc`): Delete `agent-build/`, stop port 8084 processes, clean temp files after work
- **Document sync** (`development-status.mdc`): Update docs/architecture/API whenever code changes; don't commit code-only changes
- **Public repo security** (`public-repository-security.mdc`): Never commit API keys, credentials, or sensitive files

### Backend
- **No mock data outside tests** (`no-mock-data-outside-tests.mdc`): Use real APIs or test fixtures only
- **External API tests** (`external-api-test-strict-200.mdc`): Verify HTTP 200 responses from Korean Investment API
- **Quant standards** (`backtest-quant-research-standards.mdc`): Factor validation, statistical rigor for strategy development
- **Timeout handling** (`script-run-timeouts.mdc`): Agent scripts have strict timeouts; Gradle daemon must be managed

### Frontend
- **React principles** (`React-Development-Rules-Senior-Level.mdc`):
  - Pure function of state; no side effects in render
  - Separate logic from presentation
  - Prefer `useReducer` for complex state
  - Never call hooks conditionally; intentional omissions need comments
  - No useEffect business logic; extract to services
- **Security** (`React-Security-Development-Rules-Senior-Level.mdc`): Input sanitization, no dangling event listeners, safe DOM operations

### Domain-Specific
- **Investment/Banking rules** (`Investment-Banking-Securities-Firm-Level.mdc`): Decimal precision for money (BigDecimal backend, `toFixed(2)` frontend), audit logging for trades
- **Logging/Masking** (`logging-masking.mdc`): Mask account numbers, API credentials in logs

## Submodule Management

### Updating References
```bash
git submodule update --remote --merge
git add .
git commit -m "chore: update submodule refs"
```

### Checking Out a Specific Branch
```bash
cd investment-backend
git checkout dev
cd ..
git add investment-backend
git commit -m "chore: update backend to dev branch"
```

### Cloning the Full Monorepo
```bash
git clone --recurse-submodules https://github.com/Layton0-0/auto-investment-project.git
# Or if already cloned without submodules:
git submodule update --init --recursive
```

## Documentation

Key docs (read before major changes):

- **API**: `investment-backend/docs/04-api/` — Endpoints, request/response schemas, Korean Investment API mapping
- **Architecture**: `investment-backend/docs/02-architecture/` — Design patterns, quantitative strategy framework, frontend integration
- **Database**: `investment-backend/docs/05-database/01-database-schema.md` — Entity relationships, indexes
- **Deployment**: `investment-backend/docs/06-deployment/02-operations-guide.md` — Running in production, monitoring
- **Development Status**: `investment-backend/docs/09-planning/02-development-status.md` — What's done, in-progress, planned
- **Setup Guides**: `investment-backend/docs/08-setup-guides/` — Complete local environment setup, troubleshooting

## Common Workflows

### Adding a New API Endpoint
1. Define entity/repository if needed
2. Implement service method
3. Create controller endpoint
4. **Document** in `investment-backend/docs/04-api/02-api-endpoints.md`
5. **Test**: Unit test service, integration test controller
6. Update Swagger (auto-generated from `@Operation`, `@Schema` annotations)

### Modifying a Trading Strategy
1. Update strategy class in `src/main/java/com/investment/strategy/`
2. **Document** in `investment-backend/docs/02-architecture/00-strategy-registry.md` (parameters, formulas, backtesting results)
3. Add version to strategy's version stack
4. Test with historical data
5. Update frontend strategy display/config UI if applicable

### Frontend Component Updates
1. **Check**: Is this a refactor or new feature?
2. **Split**: If component > 200 lines or has multiple responsibilities, split it
3. **Test**: Add unit tests (Vitest) or E2E test (Playwright)
4. **Verify**: No console errors; styled correctly (Tailwind)
5. **Document**: Update `investment-frontend/docs/03-development-guide.md` if new pattern

### Running E2E Tests
```powershell
cd investment-frontend
npm run test:e2e                    # All tests, headless
npm run test:e2e:ui                # Interactive browser
npm run test:e2e:debug             # Step through with browser
npm run test:e2e:report            # View last run report
```

## Debugging

### Backend
- **Logs**: `TRACE`/`DEBUG` log level in `application-local.yml` for detailed output
- **Debugger**: IntelliJ breakpoints; Cursor: attach to JVM
- **Database**: Connect to `localhost:5432` with `psql` or DBeaver; use `investment_portfolio` DB
- **Cache**: Check Redis with `redis-cli`: `redis-cli -p 6379 KEYS *`

### Frontend
- **DevTools**: React DevTools extension in Chrome/Edge
- **Network**: Check `/api/*` calls in Network tab; look for CORS errors
- **Vite**: Check terminal output for build/dev server errors
- **Env**: Verify `.env.local` has correct `VITE_API_BASE_URL`

## CI/CD & Deployment

- **GitHub Actions**: Runs on push to `dev` and `main` branches
- **Workflow**: Build → Test → Deploy to staging (`dev`) or production (`main`)
- **Deployment target**: Docker image pushed to container registry, Kubernetes cluster
- See: `investment-infra/.github/workflows/`

## Tips for Productivity

- **Reload env**: After changing `.env` or `application-*.yml`, restart dev server (Ctrl+C, re-run)
- **Gradle cache**: First build is slow; subsequent builds use cache (`build/` folder)
- **Hot reload**: Frontend (Vite) hot-reloads CSS/JS; backend requires restart
- **Cursor AI**: Use context from `.cursor/rules/` — it will guide your code style
- **Task tracking**: Use `plans/` directory for adhoc notes; `docs/09-planning/02-development-status.md` for official progress

---

**Last Updated**: 2026-04-01
