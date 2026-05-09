# Task List: spec-x-hook-allow-ff-when-no-spec

## Pre-flight
- [x] Spec ID 확정 + 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성
- [ ] Plan Accept

---

## Task 1: 브랜치 생성
- [x] `git checkout -b spec-x-hook-allow-ff-when-no-spec`

## Task 2: TDD Red
- [x] `_inject_state` 시그니처 확장 + Test 2 fixture 갱신
- [x] 신규 Test 12, 13 추가
- [x] Red 확인 (11 PASS / 2 FAIL)
- [x] Commit: `test(spec-x-hook-allow-ff-when-no-spec): add failing tests for no-active-spec bypass`

## Task 3: TDD Green
- [x] `sources/hooks/pre-commit.sh` spec=null bypass
- [x] `sources/hooks/check-plan-accept.sh` 동일
- [x] precommit 13/13, hook-modes 12/12, staged-lint 6/6 PASS
- [x] Commit: `fix(spec-x-hook-allow-ff-when-no-spec): allow production commit when no active spec`

## Task 4: installed sync
- [x] `cp sources/hooks/* .harness-kit/hooks/`
- [x] Commit: `chore(spec-x-hook-allow-ff-when-no-spec): sync installed hook scripts`

## Task 5: Ship
- [x] `bash -n` syntax OK
- [x] walkthrough.md / pr_description.md
- [ ] Commit: `docs(spec-x-hook-allow-ff-when-no-spec): ship walkthrough and pr description`
- [ ] Push + PR

---

| 항목 | 값 |
|---|---|
| 총 Task | 5 |
| 예상 commit | 4 |
| 단계 | Planning |
