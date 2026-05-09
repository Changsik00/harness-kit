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
- [ ] `git checkout -b spec-x-archive-clean-commit`

---

## Task 2: 회귀 테스트 추가 (TDD Red)

### 2-1. Check 9 추가
- [ ] `tests/test-sdd-dir-archive.sh` 신규 Check 9: "archive commit 은 무관한 워킹트리 변경을 흡수하지 않음"
  - fixture: phase-01 done + spec-01-001 + 무관한 untracked + 무관한 modified
  - assert: archive commit 변경 파일이 archive rename 만 포함, 워킹트리는 무관 변경 보존
- [ ] `bash tests/test-sdd-dir-archive.sh` → Check 9 Fail 확인
- [ ] Commit: `test(spec-x-archive-clean-commit): add failing test for git add -A side effect`

---

## Task 3: cmd_archive 수정 (TDD Green)

### 3-1. git add -A 제거
- [ ] `sources/bin/sdd` `cmd_archive` 의 `git add -A` 라인 삭제
- [ ] `bash tests/test-sdd-dir-archive.sh` → 모든 Check PASS
- [ ] `bash tests/test-sdd-archive-search.sh` → PASS (회귀)
- [ ] Commit: `fix(spec-x-archive-clean-commit): remove redundant git add -A from archive`

---

## Task 4: installed sync
- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [ ] Commit: `chore(spec-x-archive-clean-commit): sync installed sdd binary`

---

## Task 5: Ship
- [ ] `bash -n sources/bin/sdd` syntax OK
- [ ] walkthrough.md 작성
- [ ] pr_description.md 작성
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
