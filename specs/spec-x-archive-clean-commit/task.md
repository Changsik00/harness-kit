# Task List: spec-x-archive-clean-commit

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성
- [x] `git checkout -b spec-x-archive-clean-commit`

---

## Task 2: 회귀 테스트 추가 (TDD Red)
- [x] Check 9 추가 (4 assertion)
- [x] Red 확인 (PASS=14 / FAIL=4)
- [x] Commit: `test(spec-x-archive-clean-commit): add failing test for git add -A side effect`

---

## Task 3: cmd_archive 수정 (TDD Green)
- [x] `sources/bin/sdd` 의 `git add -A` 라인 삭제
- [x] dir-archive 18/18, archive-search 11/11, status-cross-check 7/7 PASS
- [x] Commit: `fix(spec-x-archive-clean-commit): remove redundant git add -A from archive`

---

## Task 4: installed sync
- [x] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [x] Commit: `chore(spec-x-archive-clean-commit): sync installed sdd binary`

---

## Task 5: Ship
- [x] `bash -n sources/bin/sdd` syntax OK
- [x] walkthrough.md 작성
- [x] pr_description.md 작성
- [ ] Commit: `docs(spec-x-archive-clean-commit): ship walkthrough and pr description`
- [ ] Push + PR 생성
- [ ] PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-09 |
