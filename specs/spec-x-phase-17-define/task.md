# Task List: spec-x-phase-17-define

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (sdd specx new)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] queue.md 업데이트 — sdd specx new 가 처리
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-phase-17-define` (from `main`)
- [ ] Commit: 없음

### 1-2. 기획 산출물 commit
- [ ] `git add backlog/queue.md specs/spec-x-phase-17-define/`
- [ ] Commit: `chore(spec-x-phase-17-define): add planning artifacts`

---

## Task 2: `backlog/phase-17.md` 작성

### 2-1. phase 템플릿 읽기 + phase-17.md 작성
- [ ] `.harness-kit/agent/templates/phase.md` 템플릿 참조
- [ ] `backlog/phase-17.md` 작성 — plan.md §Proposed Changes outline 그대로 구현
- [ ] 7 섹션 모두 채움 (메타 / 배경&목표 / SPECs / 결정 기록 / 통합 테스트 / 위험 / Phase Done)
- [ ] SPECs 표 3 spec 등록 (Backlog)
- [ ] 결정 기록 4 결정 박음
- [ ] 회고 ref (W5/W10/C3/W2/W6) 명시
- [ ] Commit: `docs(spec-x-phase-17-define): write phase-17 definition`

---

## Task 3: 단위 검증

### 3-1. plan.md §검증 계획 5 항목
- [ ] `test -f backlog/phase-17.md`
- [ ] `grep "Phase ID.*phase-17" backlog/phase-17.md`
- [ ] `grep "Base Branch.*phase-17-coherence-fix" backlog/phase-17.md`
- [ ] `grep -c "^| spec-17-0" backlog/phase-17.md` → 3
- [ ] `grep -E "W5|W10|C3|W2|W6" backlog/phase-17.md` → 모두 hit
- [ ] Commit: 없음 (검증만)

---

## Task 4: Ship

- [ ] **walkthrough.md 작성** — 결정 기록 + 검증 로그
- [ ] **pr_description.md 작성** — phase-17 outline + 머지 후 활성화 안내
- [ ] **Ship Commit**: `docs(spec-x-phase-17-define): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-phase-17-define`
- [ ] **PR 생성**: `gh pr create --base main` (spec-x 는 main 직 PR)
- [ ] **사용자 알림**: PR URL + 머지 후 `sdd phase activate phase-17 --base` 안내

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (Pre-flight 별도) |
| **예상 commit 수** | 3 (planning + phase-17.md + ship) — Task 3 검증만 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-16 |
