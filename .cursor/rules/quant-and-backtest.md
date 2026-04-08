---
description: Quant risk, backtest hygiene, Python quant pointer
alwaysApply: false
globs:
  - "investment-backend/**/*.java"
  - "investment-data-collector/**/*.py"
  - "investment-prediction-service/**/*.py"
---

Risk before return. Backtests need point-in-time data, out-of-sample checks, and realistic costs; avoid lookahead. Keep Python quant code typed and tested. Strategy registry: investment-backend/docs/02-architecture/00-strategy-registry.md
