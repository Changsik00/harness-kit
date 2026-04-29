# fix(spec-15-06): 사용자 커스텀 hook 보존 + sdd spec_new archive seq 수정

## 📋 Summary

### 배경 및 목적

두 가지 버그를 수정합니다.

**버그 1 — 사용자 커스텀 hook 손실 (Pattern B, spec-15-01 §5.1)**
`install.sh`의 `settings.json` 머지 로직이 `.hooks = ($kit.hooks // $user.hooks)` 방식으로 kit hooks를 통째로 덮어써, 사용자가 `settings.json`에 추가한 커스텀 hook event type이 install/update 시 영구 소실되었다.

**버그 2 — sdd spec_new() seq 번호 중복 (phase_new과 동일 패턴)**
`spec_new()`가 `specs/` 디렉토리만 스캔하여 next seq를 계산했다. phase-N spec들이 `archive/specs/`로 이동된 후 `sdd spec new`를 호출하면 이전에 사용된 seq 번호를 재할당하는 버그가 있었다. `phase_new()`는 commit `ab271db`에서 수정되었으나 `spec_new()`는 누락되었다.

### 주요 변경 사항

- [x] `install.sh` jq 머지: kit-owned key(`PreToolUse`, `SessionStart`)는 최신화, 사용자-전용 key는 보존
- [x] `update.sh`: uninstall 전 사용자 커스텀 hook 저장 → install 후 복원 (save/restore 패턴)
- [x] `sources/bin/sdd` + `.harness-kit/bin/sdd`: `spec_new()` find 경로에 `archive/specs` 추가
- [x] `tests/test-install-settings-hook.sh`: hook 보존 4개 시나리오 단위 테스트 신규
- [x] `tests/test-sdd-spec-new-seq.sh`: archive seq 중복 방지 3개 케이스 단위 테스트 신규
- [x] `tests/test-update-stateful.sh` Scenario 3: skip → 실제 검증으로 활성화

### Phase 컨텍스트

- **Phase**: `phase-15` (upgrade-safety)
- **본 SPEC 의 역할**: Pattern B (User Content Blindness) 픽스 — settings.json hook 영역을 사용자 커스텀 안전 지대로 확보. sdd 도구의 seq 할당 견고성 확보.

## 🎯 Key Review Points

1. **`install.sh` jq 표현** (`install.sh:352`): `$kh + ($uh | with_entries(select(.key as $k | ($kh | has($k)) | not)))` — kit key 우선, user-only key 보존. jq `+` 연산자의 left-precedence 동작 확인
2. **`update.sh` save/restore 위치** (`update.sh:109-142`): uninstall *전*에 저장, install *후*에 복원. state save/restore와 동일 패턴으로 일관성 유지
3. **`spec_new()` find 경로** (`sources/bin/sdd:831`): `"$SDD_ROOT/archive/specs"` 추가 — `phase_new()`의 `archive/backlog` 수정과 완전 동일 패턴

## 🧪 Verification

### 자동 테스트

```bash
bash tests/test-sdd-spec-new-seq.sh
bash tests/test-install-settings-hook.sh
bash tests/test-update-stateful.sh
```

**결과 요약**:
- ✅ `test-sdd-spec-new-seq`: 3/3 (archive seq 중복 없음)
- ✅ `test-install-settings-hook`: 4/4 (hook 보존 / 멱등성 / kit 갱신)
- ✅ `test-update-stateful` Scenario 3: PASS (UserAddedHook update 후 보존)
- ✅ 전체 stateful 통합 테스트: 17/17

### 수동 검증 시나리오

1. **settings.json에 PostToolUse 추가 → install 재실행** → PostToolUse 잔존 확인
2. **archive/specs/에 phase-N spec 존재 → sdd spec new** → seq 중복 없이 max+1 할당

## 📦 Files Changed

### 🆕 New Files
- `tests/test-sdd-spec-new-seq.sh`: sdd spec_new archive seq 검증 (3 케이스)
- `tests/test-install-settings-hook.sh`: hook 보존 단위 테스트 (4 케이스)

### 🛠 Modified Files
- `install.sh` (+2, -1): jq hook 머지 로직 — kit-key 우선 + user-전용 key 보존
- `update.sh` (+20, -0): 사용자 hook save/restore 블록 추가
- `sources/bin/sdd` (+2, -2): spec_new() archive/specs 스캔 추가
- `.harness-kit/bin/sdd` (+2, -2): 동일 (installed 버전)
- `tests/test-update-stateful.sh` (+12, -1): Scenario 3 skip 해제 → 실제 검증

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (`test-sdd-spec-new-seq`, `test-install-settings-hook`)
- [x] 통합 테스트 통과 (`test-update-stateful` 17/17)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-15.md`
- Walkthrough: `specs/spec-15-06-user-hook-preserve/walkthrough.md`
- 관련 수정 (phase_new archive scan): commit `ab271db`
