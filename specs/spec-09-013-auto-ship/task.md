# Task List: spec-09-013

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight

- [x] spec.md / plan.md / task.md 작성
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

- [ ] `git checkout -b spec-09-013-auto-ship` (from `phase-09-install-conflict-defense`)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: 거버넌스 문서 갱신 (agent.md + constitution.md)

- [ ] `sources/governance/agent.md` §6.1: Ship 자동 진행 규칙으로 변경
- [ ] `sources/governance/agent.md` §6.3: Walkthrough Protocol 항목 6 갱신
- [ ] `sources/governance/constitution.md` §10.2: PR 생성 위임 규칙 갱신
- [ ] `sources/governance/constitution.md` §7.1: Delegation Rule에 push+PR 포함
- [ ] `.harness-kit/agent/agent.md` 도그푸딩 동기화
- [ ] `.harness-kit/agent/constitution.md` 도그푸딩 동기화
- [ ] Commit: `feat(spec-09-013): auto-ship delegation in governance docs`

---

## Task 3: hk-ship 슬래시 커맨드 갱신

- [ ] `sources/commands/hk-ship.md` §4: push 확인 블록 → 정보 표시 + 자동 진행
- [ ] `sources/commands/hk-ship.md` §5: PR 생성 자동 실행으로 변경
- [ ] `.claude/commands/hk-ship.md` 도그푸딩 동기화
- [ ] Commit: `feat(spec-09-013): auto-ship in hk-ship command`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-013): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-013-auto-ship`
- [ ] **PR 생성**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
