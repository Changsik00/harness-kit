# Task List: spec-10-003

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase.md SPEC 표 자동 갱신 완료)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + 테스트 작성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-10-003-spec-completeness` (base: `phase-10-status-reliability`)
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [x] 테스트 파일 생성: `tests/test-sdd-spec-completeness.sh`
  - 시나리오 1: spec.md+plan.md만 → `Planning`, walkthrough/pr_description `✗`
  - 시나리오 2: +task.md → `Executing`
  - 시나리오 3: +walkthrough.md+pr_description.md → `Ship-ready`
  - 시나리오 4: active spec 없음 → 산출물 라인 미출력
- [x] 테스트 실행 → Fail 확인 (PASS=1, FAIL=3)
- [x] Commit: `test(spec-10-003): add failing tests for spec completeness`

---

## Task 2: 산출물 체크리스트 + 완성도 단계 구현

### 2-1. cmd_status에 산출물 표시 추가
- [x] `sources/bin/sdd`의 `cmd_status()` Tasks 라인 이후에 산출물 체크리스트 출력
- [x] 완성도 단계 레이블 (Planning/Executing/Ship-ready) 표시
- [x] 테스트 실행 → 전체 4/4 Pass
- [x] Commit: `feat(spec-10-003): add artifact completeness to status`

---

## Task 3: 도그푸딩 동기화

### 3-1. .harness-kit/bin/sdd 동기화
- [x] `sources/bin/sdd` → `.harness-kit/bin/sdd` 복사
- [x] `sdd status` 실행으로 동작 확인 — Artifacts 라인 정상 표시
- [x] 전체 회귀 테스트 16개 파일 전부 PASS
- [x] Commit: `chore(spec-10-003): sync sdd to .harness-kit`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 실행 → 16개 파일 전부 PASS
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-10-003): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-10-003-spec-completeness`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 5 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
