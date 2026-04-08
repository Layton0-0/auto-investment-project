---
description: Korea Investment Open API MCP and strict integration tests
alwaysApply: false
globs:
  - "investment-backend/**/*.java"
---

Confirm every Korea Investment API change against the official MCP (GET+query vs POST+JSON). Integration tests hitting that API must assert HTTP 200 and valid shape. Use sandbox accounts only. Spec: investment-backend/docs/04-api/10-korea-investment-api-spec.md
