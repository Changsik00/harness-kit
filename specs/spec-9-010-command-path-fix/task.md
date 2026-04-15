# Task List: spec-9-010

## Pre-flight

- [x] spec.md / plan.md / task.md 작성
- [ ] 사용자 Plan Accept

---

## Task 1: 경로 일괄 치환

- [ ] 브랜치 생성
- [ ] `sources/commands/` 내 모든 `scripts/harness/bin/sdd` → `.harness-kit/bin/sdd` 치환
- [ ] `.claude/commands/` 도그푸딩 사본 동기화
- [ ] grep 검증: 잔재 0건
- [ ] Commit: `fix(spec-9-010): replace legacy sdd path in slash commands`

---

## Task 2: Ship

- [ ] **walkthrough.md / pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-9-010): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-9-010-command-path-fix`
- [ ] **PR 생성**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 2 |
| **예상 commit 수** | 2 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-15 |
