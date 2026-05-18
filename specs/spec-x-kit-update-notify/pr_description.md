# fix(spec-x-kit-update-notify): kit 업데이트 알림 및 실행 UX 개선

## 📋 Summary

### 배경 및 목적

harness-kit 업데이트 시스템이 설계는 존재했으나 실제로 한 번도 작동하지 않았던 문제를 수정한다. 근본 원인: Claude Code의 `compact hook success` 포맷이 SessionStart 첫 번째 훅 출력만 에이전트 컨텍스트에 포함시켜, 두 번째 훅(`check-kit-version.sh`)의 업데이트 알림이 에이전트에 도달하지 못했다. 또한 `/hk-update` 실행 시 에이전트가 명령어 텍스트만 출력하고 실제 실행을 못 해 사용자가 복사-붙여넣기를 해야 했다.

### 주요 변경 사항
- [x] `sdd status --brief`: `cache.json` 읽기로 업데이트 가용 시 `→UPDATE:X.Y.Z` suffix 포함 — 첫 번째 훅 출력에 포함되어 에이전트에 안정적으로 도달
- [x] `/hk-update` step 5: step 4 사용자 승인 시 에이전트가 Bash 툴로 `get.sh --update` 직접 실행 (임시 동의 기반)
- [x] SessionStart IMPORTANT 에코: `→UPDATE:` 패턴 감지 → 즉시 사용자 보고 지시 추가
- [x] 로컬 클론 불필요 명시: `! bash <(curl...) --update` Claude Code 프롬프트 직접 실행 안내 추가

## 🎯 Key Review Points

1. **`sdd status --brief` cache 읽기**: 네트워크 호출 없음(파일 읽기만). `cache.json` 또는 `jq` 없는 환경에서 graceful skip — 기존 brief 포맷 유지. bash 3.2+ 호환.
2. **임시 동의 실행 패턴**: `/hk-update`의 step 4 `[Y/n]` 확인이 이미 사용자 동의를 받으므로 step 5에서 별도 확인 없이 실행. `deny` 리스트의 `curl * | bash` 패턴과 `bash <(curl ...)` 은 문법이 달라 충돌 없음.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-install-claude-import.sh
bash tests/test-marker-append-guard.sh
bash tests/test-marker-edge-cases.sh
```

**결과**: ✅ ALL PASS (6/6, 5/5, 8/8) — `lastTestPass: 2026-05-18T07:59:18Z`

### 수동 검증
1. `cache.json`에 상위 버전 임시 기록 → `sdd status --brief` → `→UPDATE:0.99.0` suffix 확인 ✅
2. `cache.json` 없는 상태 → `sdd status --brief` → 기존 포맷 그대로 ✅

## 📦 Files Changed

### 🛠 Modified Files
- `sources/bin/sdd` (+13, -1): brief 분기에 cache.json 읽기 + update_suffix 로직
- `.harness-kit/bin/sdd` (+13, -1): dogfooding 동기화
- `sources/commands/hk-update.md` (+19, -14): step 5 실행 로직 + ! prefix 안내
- `.claude/commands/hk-update.md` (+19, -14): dogfooding 동기화
- `.claude/settings.json` (+1, -1): SessionStart IMPORTANT 에코 `→UPDATE:` 감지 지시 추가

**Total**: 5 files changed

## ✅ Definition of Done

- [x] `sdd status --brief` 가 cache.json 에 업데이트 버전 있을 때 `→UPDATE:X.Y.Z` 포함 출력
- [x] SessionStart IMPORTANT 에코에 `→UPDATE:` 감지 지시 포함
- [x] `/hk-update` step 5 실행 로직 적용 (sources + installed 모두)
- [x] 기존 테스트 ALL PASS
- [x] walkthrough.md 작성 완료
