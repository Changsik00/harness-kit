# PR: spec-09-004 — rootDir config

## Summary

- `install.sh`: `harness.config.json`에 `rootDir`(절대 경로) 항상 기록 (prefix 여부 무관)
- `sdd_find_root`: `/`까지 무한 탐색 제거 → config의 `rootDir` 직접 읽기 (최대 10단계)
- hooks 실행 시 Claude가 프로젝트 외부 디렉토리 접근 권한을 묻는 문제 해결

## Changes

| 파일 | 변경 내용 |
|---|---|
| `install.sh` | `harness.config.json` 항상 생성, `rootDir` 포함 |
| `sources/bin/lib/common.sh` | `sdd_find_root` rootDir 우선 읽기, 탐색 최대 10단계 |
| `.harness-kit/bin/lib/common.sh` | sources/ 동기화 |
| `tests/test-path-config.sh` | Check A 수정 + rootDir 검증 추가 (10 checks) |

## Test Results

```
tests/test-path-config.sh        → ✅ ALL PASS (10/10)
tests/test-hook-modes.sh         → ✅ ALL 12 CHECKS PASSED
tests/test-two-tier-loading.sh   → ✅ ALL 7 CHECKS PASSED
tests/test-install-claude-import.sh → ✅ ALL PASS (6/6)
```

## Commits

- `test(spec-09-004): update test-path-config for rootDir`
- `feat(spec-09-004): always write rootDir to harness.config.json`
- `refactor(spec-09-004): sdd_find_root reads rootDir from config`
