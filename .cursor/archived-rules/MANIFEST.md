# Cursor rules archive manifest

Cursor는 **`.cursor/rules/` 루트의 규칙 파일만** 로드한다. 부피를 줄이기 위해 아래는 **규칙 디렉터리 밖**에 둔다.

## `ecc-bundled-unused/`

ECC 설치 시 포함됐으나 이 모노레포에 **해당 언어 코드가 없는** 접두사 규칙.

- **이동한 접두사**: `perl-*`, `php-*`, `swift-*`, `rust-*`, `csharp-*`, `dart-*`, `cpp-*`, `kotlin-*`, `golang-*`, `zh-*`
- **복구**: 필요한 파일만 `globs`/`paths`를 지정해 `.cursor/rules/`로 복사.

## `pre-ecc-source/`

커밋 `08a5583` (ECC 직전) 시점 `.cursor/rules` 전체의 UTF-8 스냅샷. 활성 규칙은 동일 내용이 `.cursor/rules/*.md`로 복구됨.

- **재추출**: `node .cursor/scripts/extract-pre-ecc-rules.js` (저장소 루트에서 실행)

## 활성 스택 요약

[`.cursor/ACTIVE_STACKS.md`](../ACTIVE_STACKS.md)

## Skills / agents archives (sibling dirs)

- [`.cursor/archived-skills/`](../archived-skills/MANIFEST.md) — skills moved off daily stack
- [`.cursor/archived-agents/`](../archived-agents/MANIFEST.md) — agent presets moved off daily stack
