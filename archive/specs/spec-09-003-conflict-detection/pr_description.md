# PR: spec-09-003 — install prefix UX + path config system

## Summary

- `install.sh`에 `--prefix` 플래그 추가 및 대화형 prefix 프롬프트 구현 (`--yes` 시 스킵)
- prefix 지정 시 `{prefix}backlog/`, `{prefix}specs/` 생성 + `.harness-kit/harness.config.json` 작성
- `sources/bin/lib/common.sh`: `SDD_AGENT`/`SDD_TEMPLATES` 경로 `.harness-kit/agent/`로 수정, `harness.config.json` 읽기 추가
- `doctor.sh`: Section 2/5에서 `harness.config.json` 경로 반영

## Changes

| 파일 | 변경 내용 |
|---|---|
| `install.sh` | `--prefix` 파싱, prefix UX 프롬프트, `BACKLOG_DIR`/`SPECS_DIR` 변수, `harness.config.json` 생성 |
| `sources/bin/lib/common.sh` | `SDD_AGENT`/`SDD_TEMPLATES` 경로 수정, config 읽기 |
| `.harness-kit/bin/lib/common.sh` | sources/bin/ 동기화 |
| `doctor.sh` | Section 2: config 경로로 디렉토리 체크, Section 5: config 존재 확인 |
| `tests/test-path-config.sh` | 신규 테스트 (9 checks) |

## Test Results

```
tests/test-path-config.sh        → ✅ ALL PASS (9/9)
tests/test-hook-modes.sh         → ✅ ALL 12 CHECKS PASSED
tests/test-two-tier-loading.sh   → ✅ ALL 7 CHECKS PASSED
tests/test-install-claude-import.sh → ✅ ALL PASS (6/6)
```

## Commits

- `test(spec-09-003): add failing test for path config system`
- `refactor(spec-09-003): fix common.sh agent paths and add config reading`
- `feat(spec-09-003): add prefix UX and harness.config.json to install.sh`
- `refactor(spec-09-003): doctor.sh reflects harness.config.json paths`
