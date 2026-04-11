# Task List: spec-7-003

> 모든 task는 한 commit에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec 디렉토리 생성: `specs/spec-7-003-plan-accept-consistency/`
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + constitution.md §4.2 허용 응답 규칙 추가

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-7-003-plan-accept-consistency`

### 1-2. constitution.md 수정
- [x] `sources/governance/constitution.md` — §4.2에 Plan Accept 허용 응답 인식 규칙 추가
- [x] `agent/constitution.md` — 동일 반영
- [x] Commit: `refactor(spec-7-003): add plan accept recognition rules to constitution §4.2`

---

## Task 2: agent.md §4.4 선택 프롬프트에 허용 응답 안내 추가

- [x] `sources/governance/agent.md` — §4.4 선택 프롬프트 순서 변경 + constitution 참조
- [x] `agent/agent.md` — 동일 반영
- [x] Commit: `refactor(spec-7-003): update plan accept prompt order and add constitution reference in agent.md §4.4`

---

## Task 3: hk-plan-accept.md 커맨드에 허용 응답 목록 명시

- [x] `sources/commands/hk-plan-accept.md` — constitution §4.2 참조로 대체
- [x] `.claude/commands/hk-plan-accept.md` — 동일 반영
- [x] Commit: `refactor(spec-7-003): replace inline allowed responses with constitution §4.2 reference in hk-plan-accept`

---

## Task 4: Hand-off

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-7-003): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-7-003-plan-accept-consistency`
- [ ] **사용자 알림**: 푸시 완료 + PR 생성 확인 [Y/n]

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (+ Hand-off) |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
