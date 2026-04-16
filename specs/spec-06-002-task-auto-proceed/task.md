# Task List: spec-06-002

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: sources/governance/ 규칙 변경

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-06-002-task-auto-proceed`

### 1-2. agent.md §6.1 변경
- [x] 7번 단계를 "자동 진행 / 이슈 시 멈춤" 규칙으로 변경
- [x] Commit: `refactor(spec-06-002): change strict loop to auto-proceed on no issues`

### 1-3. align.md Strict Loop 설명 변경
- [x] "보고 + 대기" → "이슈 없으면 자동 진행"
- [x] Commit: `docs(spec-06-002): update align strict loop description`

---

## Task 2: 도그푸딩 반영

### 2-1. agent/agent.md + agent/align.md 동일 반영
- [x] Commit: `docs(spec-06-002): update dogfooding governance for auto-proceed`

---

## Task 3: Hand-off

- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] **Archive Commit**: `docs(spec-06-002): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-06-002-task-auto-proceed`
- [x] **사용자 알림**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-11 |
