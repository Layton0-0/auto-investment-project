---
description: Layering and read-only smart-portfolio-pal
alwaysApply: true
---

Backend: controller-service-repository with DTOs at the edge. Frontend: dedicated API layer and hooks. Python services talk to Spring via HTTP only; no shared DB. Never edit, commit, or push under smart-portfolio-pal/ (Lovable submodule; read-only in this monorepo).
