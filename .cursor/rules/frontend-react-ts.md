---
description: React, TypeScript, and Vite frontend rules
alwaysApply: false
globs:
  - "investment-frontend/**/*.tsx"
  - "investment-frontend/**/*.ts"
---

UI is a pure function of state; isolate side effects. Prefer immutable updates, small components, Vitest and Playwright, accessible markup, and sanitized inputs. Avoid generic template UI. Keep HTTP in hooks or services, not scattered in pages.
