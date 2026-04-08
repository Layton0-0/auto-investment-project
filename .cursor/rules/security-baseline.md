---
description: Security baseline for public repos and logs
alwaysApply: true
---

Never commit secrets, API keys, tokens, or credentials; repositories are public. Mask PII in logs (Java: LogMaskingUtil per backend security docs). Do not commit sensitive backup dumps. Use security-reviewer for authentication, payments, and trading.
