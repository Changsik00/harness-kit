# feat(spec-x-kit-update-hook): SessionStart에서 kit 새 버전 알림 노출

## 📋 Summary

### 배경 및 목적
`_drift_kit_version` 자동 체크 로직은 이미 존재하지만 (`sources/bin/sdd:285-341`), 알림은 `sdd status` / `/hk-align` 을 사용자가 *수동으로 호출할 때만* 표시된다. 그 결과 사용자는 다른 프로젝트에서 새 kit 버전이 출시되어도 알림을 만날 일이 거의 없다 — "새 버전 있습니다" 흐름이 보고된 적이 없다는 사용자 피드백.

SessionStart 시점에 전용 hook 을 추가해, 새 세션이 시작될 때마다 stderr 1줄로 새 버전을 알린다. 캐시(24h) 와 차단 정책은 기존 `_drift_kit_version` 과 완전히 공유한다.

### 주요 변경 사항
- [x] 신규 `sources/hooks/check-kit-version.sh` — SessionStart 전용 알림 hook
- [x] `sources/claude-fragments/settings.json.fragment` SessionStart 배열에 hook entry 추가
- [x] (코드 변경 없음) `install.sh:289-297` 의 hook 일괄 복사 로직이 새 hook 도 자동 배포

### Phase 컨텍스트
- **Phase**: 없음 (Solo Spec — `spec-x-{slug}`)
- **본 SPEC 의 역할**: 자동 체크 로직의 "도달성(reach)" 보강. 사용자가 손을 대지 않아도 알림이 보임.

## 🎯 Key Review Points

1. **차단 금지 정책**: hook 은 어떤 경우든 exit 0 (`hook_violation` 미사용). `set -uo pipefail` (errexit 없음) + 각 단계 silent skip. 세션 시작이 hook 실패로 막혀선 안 된다.
2. **캐시 공유**: `_drift_kit_version` 과 동일한 `installed.json.lastVersionCheck` / `latestKnownVersion` 사용. 두 진입점이 서로의 결과를 재사용 → 비용 / 동작 일관.
3. **자동 실행 금지**: 알림만, prompt / 자동 실행 없음. `/hk-update` 는 기존대로 사용자가 직접 입력해야 한다 (constitution §5.7 + hk-update.md 안전 문구 유지).
4. **per-hook off**: `HARNESS_HOOK_MODE_KIT_VERSION=off` 로 개별 비활성 가능. 글로벌 `HARNESS_HOOK_MODE=off` / `HARNESS_DRIFT_FETCH=0` 도 존중.

## 🧪 Verification

### 정적 검증
```bash
bash -n sources/hooks/check-kit-version.sh                                            # syntax PASS
jq '.hooks.SessionStart[0].hooks | length'  sources/claude-fragments/settings.json.fragment  # = 3
jq '.hooks.SessionStart[0].hooks[1]'        sources/claude-fragments/settings.json.fragment  # check-kit-version entry
```

### 수동 검증 결과
- ✅ fake `kitVersion=0.0.1` → `🆕 harness-kit 0.8.0 사용 가능 (현재 0.0.1) — /hk-update 로 갱신`
- ✅ `HARNESS_HOOK_MODE_KIT_VERSION=off` → 출력 없음, exit 0
- ✅ `HARNESS_DRIFT_FETCH=0` → 출력 없음, exit 0
- ✅ 본 프로젝트(latest == installed) → silent exit 0

## 📦 Files Changed

### 🆕 New Files
- `sources/hooks/check-kit-version.sh` (+65): SessionStart 전용 kit 버전 알림 hook.

### 🛠 Modified Files
- `sources/claude-fragments/settings.json.fragment` (+4, -0): SessionStart hooks 배열에 entry 1개 삽입.

**Total**: 1 new + 1 modified (production); 5 spec artifacts.

## ✅ Definition of Done

- [x] `bash -n` syntax check PASS
- [x] 수동 검증 4종 모두 PASS
- [x] `walkthrough.md` ship commit
- [x] `pr_description.md` ship commit
- [x] 사용자 검토 요청 알림 완료
