# PR: spec-9-005 — update.sh 리라이트

## Summary

- `update.sh`를 `uninstall --keep-state + install + cleanup` 구조로 전면 재작성
- 390줄 → 132줄 (dead code 제거: v0.3 마이그레이션, CLAUDE.md 백업, migration 스크립트 인프라)
- state(phase/spec) 보존, prefix 보존, 백업 디렉토리 자동 정리

## Changes

| 파일 | 변경 내용 |
|---|---|
| `update.sh` | 전면 재작성 (390→132줄) |
| `tests/test-update.sh` | 신규 테스트 (7 checks) |

## Test Results

```
tests/test-update.sh       → ✅ ALL PASS (7/7)
tests/test-path-config.sh  → ✅ ALL PASS (10/10)
tests/test-hook-modes.sh   → ✅ ALL 12 CHECKS PASSED
```

## Commits

- `test(spec-9-005): add failing test for update.sh rewrite`
- `refactor(spec-9-005): rewrite update.sh as uninstall+install+cleanup`
