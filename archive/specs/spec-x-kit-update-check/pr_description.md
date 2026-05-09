feat(install): harness-kit 버전 자동 감지 및 /hk-update 명령어 추가

## 배경

다수의 PR이 머지되어도 대상 프로젝트 사용자가 새 버전을 인지할 방법이 없었음.
`sdd status` 와 `/hk-update` 명령어로 버전 감지 및 업데이트 안내를 제공.

## 변경 내용

### `version.json`
- 0.6.3 → 0.7.0 (PR #97 output-ux, #98 confirm-ux, #99 precommit-chmod-fix 반영)

### `install.sh`
- `installed.json` 에 `kitOrigin`, `lastVersionCheck`, `latestKnownVersion` 필드 추가

### `sources/bin/sdd` + `.harness-kit/bin/sdd`
- `_drift_kit_version()` 함수 추가
  - `curl` 로 `raw.githubusercontent.com/.../main/version.json` 조회 (다운로드 없음)
  - 24시간 캐시 — `installed.json` 에 `lastVersionCheck` + `latestKnownVersion` 기록
  - `latest > installed` 일 때만 drift 섹션에 알림 표시 (역방향 무시)
  - `HARNESS_DRIFT_FETCH=0` / `--no-drift` 시 skip

```
🔄 동기화 상태
  kit: 0.7.0 사용 가능 (현재 0.6.3) — /hk-update 또는 update.sh
```

### `sources/commands/hk-update.md` (신규)
- 버전 확인 → 정보 블록 표시 → `[Y/n]` 확인 → `update.sh` 실행 안내

## 테스트

- `test-governance-dedup.sh`: ✅ PASS 8/8
- `test-hook-modes.sh`: ✅ PASS 12/12
- `test-git-precommit-hook.sh`: ✅ PASS 11/11
- `curl` 조회: `0.6.3` 정상 반환, 캐시 기록 확인
