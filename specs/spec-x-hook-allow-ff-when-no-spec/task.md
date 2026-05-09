# Task List: spec-x-hook-allow-ff-when-no-spec

## Pre-flight
- [x] Spec ID 확정 + 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성
- [ ] Plan Accept

---

## Task 1: 브랜치 생성
- [ ] `git checkout -b spec-x-hook-allow-ff-when-no-spec`

## Task 2: TDD Red — Test 12, 13 추가 + Test 2 fixture 갱신
- [ ] `_inject_state` 시그니처 확장 (`spec` 옵셔널 인자)
- [ ] Test 2 fixture 에 `"spec":"spec-x-active"` 주입 (회귀 안전)
- [ ] 신규 Test 12: spec=null + planAccepted=false + production → 통과
- [ ] 신규 Test 13: spec 필드 누락 + planAccepted=false + production → 통과
- [ ] Red 확인 (Test 12, 13 Fail 예상)
- [ ] Commit: `test(spec-x-hook-allow-ff-when-no-spec): add failing tests for no-active-spec bypass`

## Task 3: TDD Green — sources/hooks 수정
- [ ] `sources/hooks/pre-commit.sh` spec=null bypass 추가
- [ ] `sources/hooks/check-plan-accept.sh` 동일 적용
- [ ] `bash tests/test-git-precommit-hook.sh` 모두 PASS
- [ ] `bash tests/test-hook-modes.sh` 회귀 PASS
- [ ] Commit: `fix(spec-x-hook-allow-ff-when-no-spec): allow production commit when no active spec`

## Task 4: installed sync
- [ ] `cp sources/hooks/{pre-commit,check-plan-accept}.sh .harness-kit/hooks/`
- [ ] Commit: `chore(spec-x-hook-allow-ff-when-no-spec): sync installed hook scripts`

## Task 5: Ship
- [ ] `bash -n` syntax check (두 hook 파일)
- [ ] walkthrough.md / pr_description.md
- [ ] Commit: `docs(spec-x-hook-allow-ff-when-no-spec): ship walkthrough and pr description`
- [ ] Push + PR

---

| 항목 | 값 |
|---|---|
| 총 Task | 5 |
| 예상 commit | 4 |
| 단계 | Planning |
