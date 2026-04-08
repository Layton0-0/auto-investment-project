---
description: Local ports, agent cleanup, script timeouts
alwaysApply: true
---

Docker backend 8080; IDE backend 8084; Vite 5173. After agent work stop listeners on 8084, delete agent-build folders, and avoid leaving Gradle daemons when agents ran builds. Use terminal timeouts of at least 600000 ms for long QA PowerShell scripts.
