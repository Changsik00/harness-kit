# Task List: spec-09-08

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: constitution.md 거버넌스 추가

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-09-08-ship-idea-capture` (from `phase-09-install-conflict-defense`)

### 1-2. constitution.md 수정
- [ ] `sources/governance/constitution.md` — §5.5 Idea Capture Gate 추가
- [ ] `sources/governance/constitution.md` — §5.6 Opinion Divergence Protocol 추가
- [ ] Commit: `feat(spec-09-08): add idea capture gate and opinion divergence protocol to constitution`

---

## Task 2: agent.md Bootstrap Protocol 확장

### 2-1. agent.md 수정
- [ ] `sources/governance/agent.md` — §2 Bootstrap Protocol에 미완 항목 확인 추가
- [ ] `sources/governance/agent.md` — §3 Alignment Phase에 Idea Capture Gate 참조 추가
- [ ] Commit: `feat(spec-09-08): extend bootstrap protocol with continuity check`

---

## Task 3: 도그푸딩 동기화

### 3-1. .harness-kit/ 사본 동기화
- [ ] `.harness-kit/agent/constitution.md` ← `sources/governance/constitution.md` 복사
- [ ] `.harness-kit/agent/agent.md` ← `sources/governance/agent.md` 복사
- [ ] diff 확인: sources/ vs .harness-kit/ 일치
- [ ] Commit: `chore(spec-09-08): sync dogfooding copies`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-08): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-08-ship-idea-capture`
- [ ] **PR 생성**: 사용자 승인 후
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 4 (constitution + agent + sync + archive) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-15 |
