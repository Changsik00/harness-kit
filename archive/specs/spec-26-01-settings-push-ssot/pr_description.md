# refactor(spec-26-01): git-push ask 토글 제거 (§5.7 push 자동 정합)

> 본 spec 은 base 모드라 별도 spec PR 없이 **phase-26 → main phase-ship PR** 에 포함되어 검토됩니다.

## 📋 Summary

### 배경 및 목적

phase-25 회고 잔여 W3(settings SSOT). 조사 결과 `sdd mode` 전환 시 `_settings_mode_patch` 가 governed 에서 `Bash(git push)` 를 `permissions.ask` 로 올려 **constitution §5.7("Plan Accept 후 push 완전 자동, NO user response")과 충돌**하고, fragment baseline(ask 게이트 없음)과 영구 drift 를 만든다. push 게이팅을 제거해 §5.7 과 정합시킨다.

### 주요 변경 사항
- [x] `_settings_mode_patch` + 호출 3곳(turbo/auto/governed) 제거 — 모드 전환이 settings 를 건드리지 않음
- [x] `tests/test-settings-ssot.sh` 신규 — fragment 불변식(ask 무 push / deny force) + sdd 비조작 박제
- [x] `.claude/settings.json` 정리 — allow 의 stray `Bash(git push:*)` 제거(`git:*` 로 redundant)

### Phase 컨텍스트
- **Phase**: `phase-26` (auto-safety-residue)
- **본 SPEC 의 역할**: auto 안전망 잔여 3건 중 W3. push 게이팅을 §5.7 + deny/hook 단일 책임으로 정리해 SSOT 회복.

## 🎯 Key Review Points

1. **§5.7 정합**: governed 에서 push 가 자동이 되는 동작 변경. 단 §5.7 이 이미 규정한 동작이며 force-push 는 deny+check-irreversible 로 여전히 차단(무영향 회귀: test-stop-rules·test-settings-ssot T2).
2. **회귀 안전성**: 토글 제거가 test-turbo-mode / test-e2e-auto-mode 를 깨지 않음 — fixture baseline 이 이미 push 게이트 없음(fragment).

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-settings-ssot.sh
bash tests/test-turbo-mode.sh
bash tests/test-e2e-auto-mode.sh
bash tests/run.sh
```

**결과 요약**:
- ✅ `test-settings-ssot`: 3/3 (T1 fragment ask 무 push / T2 deny force 3변형 / T3 sdd 비조작)
- ✅ `test-turbo-mode`: 5/5 (모드 전환 회귀)
- ✅ `test-e2e-auto-mode`: 8/8 (auto baseline 불변식)
- ✅ `tests/run.sh`: 전체 PASS

### 수동 검증 시나리오
1. **시나리오 1**: `sdd mode turbo↔governed↔auto` 왕복 → `.claude/settings.json` 의 git push ask 멤버십 불변(항상 게이트 없음)
2. **시나리오 2**: `git push --force` → check-irreversible + deny 로 여전히 차단

## 📦 Files Changed

### 🆕 New Files
- `tests/test-settings-ssot.sh`: settings push SSOT 불변식 테스트

### 🛠 Modified Files
- `sources/bin/sdd`: `_settings_mode_patch` + 호출 3곳 제거
- `tests/test-e2e-auto-mode.sh`: ① 라벨을 "패치" → baseline 불변식으로 정정
- `.claude/settings.json`: allow 의 stray git push:* 제거

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit
- [x] `pr_description.md` ship commit
- [x] (push/PR 은 phase-ship 에서 일괄)

## 🔗 관련 자료

- Phase: `backlog/phase-26.md`
- Walkthrough: `specs/spec-26-01-settings-push-ssot/walkthrough.md`
- 규약: constitution §5.7 (push 자동), §2.4 (모드)
