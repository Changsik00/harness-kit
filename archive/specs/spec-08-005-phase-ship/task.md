# Task List: spec-08-005

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`specs/spec-08-005-phase-ship/`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (`backlog/phase-08.md` spec 표 — In Progress 마킹)
- [x] 사용자 Plan Accept

---

## Task 1: hk-phase-ship 슬래시 커맨드 + phase-ship 템플릿

### 1-1. 슬래시 커맨드 작성
- [x] `sources/commands/hk-phase-ship.md` — 5단계 절차 정의
  - Step 1: Pre-check (모든 Spec Merged 확인)
  - Step 2: Success Criteria Verification (항목별 PASS/FAIL)
  - Step 3: Integration Test Execution (시나리오별 실행)
  - Step 4: Go/No-Go Report (사용자 승인 대기)
  - Step 5: Phase PR Creation + sdd phase done
- [x] Commit: `feat(spec-08-005): add hk-phase-ship slash command`

### 1-2. Phase PR 템플릿 작성
- [x] `sources/templates/phase-ship.md` — Phase PR 본문 전용 템플릿
  - Overview / Scope / Spec Summary / Success Criteria / Integration Tests / Architecture Decisions / Known Issues / Follow-up
- [x] Commit: `feat(spec-08-005): add phase-ship pr template`

---

## Task 2: 거버넌스 규칙 추가 (영문)

### 2-1. constitution.md + agent.md 수정
- [x] `sources/governance/constitution.md` — Phase Ship 규칙 추가 (§3.1 Phase 또는 §7)
- [x] `sources/governance/agent.md` — §3.1 Work Type Table Phase 행 갱신 + §6.3 Phase done 갱신
- [x] `agent/constitution.md` + `agent/agent.md` 동기화
- [x] Commit: `docs(spec-08-005): add phase ship governance rules to constitution and agent`

---

## Task 3: Ship (필수)

- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Archive Commit**: `docs(spec-08-005): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-08-005-phase-ship`
- [x] **PR 생성**: 타깃 `phase-08-work-model`
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 |
| **현재 단계** | Done (phase-08 PR #27로 main 머지 완료) |
| **마지막 업데이트** | 2026-04-12 |
