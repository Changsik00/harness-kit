# Task List: spec-7-001

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec 디렉토리 생성: `specs/spec-7-001-scope-classification-rules/`
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + constitution §2 결정 체크리스트 추가

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-7-001-scope-classification-rules`

### 1-2. constitution.md 수정 (sources + agent 동시)
- [ ] `sources/governance/constitution.md` — §2에 Mode C(SDD-x) + 결정 체크리스트 + edge cases 추가
- [ ] `agent/constitution.md` — 동일 변경 반영
- [ ] Commit: `refactor(spec-7-001): add work mode decision checklist to constitution §2`

---

## Task 2: agent.md §3 Classification 항목 추가

- [ ] `sources/governance/agent.md` — §3 Output Format에 `[Classification]` 항목 추가
- [ ] `agent/agent.md` — 동일 변경 반영
- [ ] Commit: `refactor(spec-7-001): add classification output to alignment phase`

---

## Task 3: Hand-off

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-7-001): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-7-001-scope-classification-rules`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 요청

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 2 (+ Hand-off) |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
