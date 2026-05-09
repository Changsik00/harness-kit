# fix(spec-x-fix-archive-test-expectation): archive 테스트 기대값 복원 + 활성 .md 표기 일관성 + specx done 회귀 테스트

## 📋 Summary

### 배경 및 목적

로컬 `main` 이 `origin/main` 보다 2 개 커밋(`120d0f2`, `f601417`) 앞서 있던 상태에서 push 전 감사 과정 중 세 건의 문제가 확인됐다:

1. **P1**: `f601417` 의 "Check 4 기대값 반전" 근거가 **거짓** — 커밋은 "PR #64 신 동작 반영" 이라 주장하나 실제로는 PR #65 (`34f055b`) 에서 spec-x 아카이브 블록이 명시적으로 되돌려진 상태였음. 결과적으로 `tests/test-sdd-dir-archive.sh` Check 4 가 지속 실패.
2. **P2**: `constitution.md §6.2` 는 소문자 `spec-{phaseN}-{seq}` 를 표준으로 선언하나, 사용자에게 상태 리포트를 출력하는 `align.md` / `hk-plan-accept.md` 는 대문자 `SPEC-{N}-{NN}` 을 그대로 씀.
3. **P3**: `f601417` 이 `sdd specx done` 에 추가한 두 동작 — (a) `spec-x-` prefix 이중 방지, (b) active spec 매칭 시 state 리셋 — 은 코드상 정상 동작하나 **회귀 테스트 0 건**.

본 PR 은 전체 변경을 한 PR 로 묶어 정식 리뷰를 받고, 위 세 건을 동시에 해결한다.

### 주요 변경 사항

- [x] **P1** `tests/test-sdd-dir-archive.sh` Check 4 의 기대값을 "spec-x 디렉토리는 아카이브되지 않음" 으로 복원 (PR #65 설계와 일치).
- [x] **P2** 활성 4 개 .md 파일의 ID placeholder 를 `constitution.md §6.2` 와 일관된 소문자 포맷으로 통일.
- [x] **P3** `tests/test-sdd-ship-completion.sh` 에 두 회귀 테스트(Check 6b / 6c) 추가.
- [x] **원 커밋 정상화** `120d0f2`, `f601417` 이 main 에 직접 커밋된 것을 정식 PR 경로로 rehabilitate.

### Phase 컨텍스트
- **Phase**: 없음 (Solo Spec / SDD-x)
- **역할**: Push 전 감사에서 드러난 위반 / 회귀 / 드리프트를 한 PR 로 정리.

## 🎯 Key Review Points

1. **브랜치 history 의미**: 본 브랜치는 6 개 커밋 (`120d0f2`, `f601417`, scaffold, P1, P2, P3) + ship 커밋. 원 두 커밋(`120d0f2`, `f601417`)을 그대로 유지한 채 잘못된 테스트 기대값만 P1 에서 복원했다는 점이 핵심. `f601417` 자체를 rewrite 하지 않은 이유는 *다른 수정들*(test-install-layout, sdd specx done 코드)은 유효하기 때문.
2. **Check 4 교정 방향의 근거**: 단순 "테스트를 빨갛게 → 파랗게" 가 아니라 **실 구현(PR #65 최종 디자인)** 을 기준으로 맞춤. `.harness-kit/bin/sdd:1301` 의 `case "$base" in spec-x-*) continue ;; esac` 블록이 이 방향을 명시.
3. **P2 의 placeholder 정규화**: `{NN}` → `{seq}` 는 constitution 과 placeholder 이름을 맞춘 것. `SPEC-` → `spec-` 는 실제 ID 표기와 맞춘 것.
4. **P3 테스트의 정밀도**: Check 6b 는 단순히 "done 섹션에 있는가" 뿐 아니라 `spec-x-spec-x-` 이중 prefix 가 *없는지* 까지 확인. Check 6c 는 state.json 의 `spec`/`planAccepted` 두 필드 모두 검증.

## 🧪 Verification

### 자동 테스트
```bash
for t in tests/test-*.sh; do echo "=== $t ==="; bash "$t" 2>&1 | tail -3; done
```

**결과 요약**: 19/19 테스트 파일 전부 FAIL=0.

핵심 변화:
- ✅ `test-sdd-dir-archive.sh`: `PASS=9 FAIL=1` → `PASS=10 FAIL=0`
- ✅ `test-sdd-ship-completion.sh`: `PASS=7 FAIL=0` → `PASS=9 FAIL=0` (Check 6b, 6c 추가)

### 수동 검증 시나리오
1. **`git log origin/main..HEAD --oneline`** → 6 + ship = 7 commits.
2. **`git log main..origin/main --oneline`** → 출력 없음 (로컬 main = origin/main).
3. **`git branch --show-current`** → `spec-x-fix-archive-test-expectation`.

## 📦 Files Changed

### 🛠 Modified Files
- `tests/test-sdd-dir-archive.sh` (+4 -4): Check 4 기대값 복원 (P1)
- `.harness-kit/agent/align.md` (+2 -2): ID placeholder 소문자화 (P2)
- `sources/governance/align.md` (+2 -2): 동일 (P2, source 측)
- `.claude/commands/hk-plan-accept.md` (+1 -1): placeholder + 포맷 정규화 (P2)
- `sources/commands/hk-plan-accept.md` (+1 -1): 동일 (P2, source 측)
- `tests/test-sdd-ship-completion.sh` (+85): Check 6b / 6c 추가 (P3)
- `backlog/queue.md` (+1): `sdd specx new` 자동 등록
- `specs/spec-x-fix-archive-test-expectation/spec.md`, `plan.md`, `task.md`, `walkthrough.md`, `pr_description.md`: 산출물

### 원 두 커밋 (본 PR 에 포함, 수정되지 않음)
- `120d0f2` fix: align docs/hooks/tests with 2-digit seq padding
- `f601417` fix: resolve remaining test regressions and sdd specx done UX bugs

**Total**: 13 files changed (산출물 포함).

## ✅ Definition of Done

- [x] P1 교정 커밋 (`49175b8`)
- [x] P2 교정 커밋 (`cbb636e`)
- [x] P3 회귀 테스트 커밋 (`2e03ee0`)
- [x] `for t in tests/test-*.sh; do bash "$t"; done` → 19/19 PASS
- [x] 로컬 `main` == `origin/main`
- [x] walkthrough.md / pr_description.md ship commit

## 🔗 관련 자료

- Spec: `specs/spec-x-fix-archive-test-expectation/spec.md`
- Plan: `specs/spec-x-fix-archive-test-expectation/plan.md`
- Walkthrough: `specs/spec-x-fix-archive-test-expectation/walkthrough.md`
- 관련 PR (근거):
  - PR #64 (`c2dd254`): 최초 spec-x 아카이브 포함 시도
  - PR #65 (`34f055b`): spec-x 아카이브 블록 제거 (최종 디자인)
