# Task List: spec-02-002

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-02-002-two-tier-loading`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: CLAUDE.md.fragment에서 @import 제거

### 2-1. 소스 fragment 수정
- [x] `sources/claude-fragments/CLAUDE.md.fragment`에서 `@agent/constitution.md`, `@agent/agent.md`, `@agent/align.md` 3줄 제거
- [x] 핵심 규칙 요약 및 `/align` 안내 유지 확인
- [x] Commit: `refactor(spec-02-002): remove @imports from CLAUDE.md.fragment`

---

## Task 3: CLAUDE.md 본체 동기화

### 3-1. 도그푸딩 CLAUDE.md 수정
- [x] `CLAUDE.md`의 HARNESS-KIT 블록에서 동일 @import 3줄 제거
- [x] HARNESS-KIT 블록 내용이 fragment와 일치하는지 확인
- [x] Commit: `chore(spec-02-002): sync CLAUDE.md harness block with fragment`

---

## Task 4: 검증 테스트

### 4-1. 검증 스크립트 작성 및 실행
- [x] `tests/test-two-tier-loading.sh` 작성 (7 checks)
- [x] 테스트 실행 → 7/7 PASS
- [x] Commit: `test(spec-02-002): add two-tier loading verification test`

---

## Task 5: Hand-off (필수)

- [x] 전체 테스트 실행 → 모두 PASS
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] **Archive Commit**: `docs(spec-02-002): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-02-002-two-tier-loading`
- [x] **PR 생성**: `/gh-pr`
- [x] **사용자 알림**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 4 (Task 1은 브랜치만) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-10 |
