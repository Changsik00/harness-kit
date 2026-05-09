# fix(spec-x-hook-allow-ff-when-no-spec): plan-accept hook 이 활성 SPEC 없을 때 production 코드 commit 을 허용

## 📋 Summary

### 배경 및 목적
직전 commit (`85d2462 fix(install): skip '# harness-kit' .gitignore header on self-host`) 을 만들 때 두 hook 이 production 코드 commit 을 차단:
- `.harness-kit/hooks/pre-commit.sh` — git pre-commit
- `.harness-kit/hooks/check-plan-accept.sh` — Claude PreToolUse

판단 기준이 `state.json` 의 `planAccepted` 단일 flag 라, FF 모드 (state 변경 없이 직접 commit) 가 사실상 production 코드를 못 건드림. constitution §2.3 의 FF 정의 ("config tweaks that do not warrant a PR") 와 모순 → `--no-verify` bypass 외 우회 불가.

### 주요 변경 사항
- [x] 두 hook 에 활성 SPEC 검사 추가: `state.spec` 이 null/빈문자열/누락이면 즉시 통과 (FF / 유지보수 / 휴지 모드)
- [x] 활성 SPEC 존재 시 기존 동작 유지 (planAccepted 검사) — 회귀 없음
- [x] 회귀 테스트 신규 2건 (`tests/test-git-precommit-hook.sh` Test 12, 13)
- [x] 기존 Test 2 fixture 갱신 — `_inject_state` 가 spec 명시적으로 주입 ("spec-x-active") 하도록 시그니처 확장
- [x] dogfood sync (`.harness-kit/hooks/*`)

## 🎯 Key Review Points

1. **state.spec 해석 일관성**: `jq -r '.spec // empty'` 로 통일. null / "null" / 누락 → 모두 빈 문자열로 정규화. `[ -z ]` 검사 한 번으로 처리.
2. **두 hook 동시 수정**: 두 hook 의 정책이 동일 (whitelist + planAccepted) 이므로 일관되게 둘 다 spec 검사 추가. 한쪽만 수정하면 Edit→차단 / commit→통과 같은 비대칭 발생.
3. **Test 2 fixture 갱신 필요성**: 기존 fixture 가 spec 필드를 안 가져 본 fix 로 통과 처리됨 → 의도 (planAccepted=false 차단) 가 깨짐. `_inject_state` 시그니처 확장 + Test 2 에 spec 명시.
4. **legacy state 호환**: 새 state 스키마 미보유 환경에서 spec 필드 자체가 없을 수 있음 → 누락 = 활성 SPEC 없음 으로 해석 (Test 13 으로 보호).

## 🧪 Verification

```bash
bash tests/test-git-precommit-hook.sh   # 13/13 PASS (Test 12, 13 신규)
bash tests/test-hook-modes.sh           # 12/12 PASS (sync check)
bash tests/test-staged-lint.sh          # 6/6 PASS (회귀)
```

### 수동 검증 시나리오
1. main 에서 활성 SPEC 없는 상태로 `install.sh` 같은 production 코드 변경 → `git commit` 통과 확인 (`--no-verify` 없이)
2. 활성 SPEC 작업 중 (planAccepted=false) production 코드 staged → 기존처럼 차단 확인
3. Plan Accept 후 production 코드 → 기존처럼 통과 확인

## 📦 Files Changed

### 🛠 Modified Files
- `sources/hooks/pre-commit.sh` (+5): spec=null bypass
- `sources/hooks/check-plan-accept.sh` (+5): spec=null bypass
- `.harness-kit/hooks/pre-commit.sh` (+5): dogfood sync
- `.harness-kit/hooks/check-plan-accept.sh` (+5): dogfood sync
- `tests/test-git-precommit-hook.sh` (+47, -3): `_inject_state` 시그니처 확장 + Test 12, 13 추가 + Test 2 fixture 갱신

### 🆕 New Files
- `specs/spec-x-hook-allow-ff-when-no-spec/{spec,plan,task,walkthrough,pr_description}.md`

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] walkthrough.md ship commit 완료
- [x] pr_description.md ship commit 완료
- [x] bash syntax 통과
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- 직전 FF 시도 commit: `85d2462 fix(install): skip '# harness-kit' .gitignore header on self-host`
- constitution §2.3 (FF 정의) — 본 PR 머지 후 정의에 부합하게 동작
