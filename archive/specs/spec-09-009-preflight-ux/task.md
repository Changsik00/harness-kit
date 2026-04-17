# Task List: spec-09-009

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] critique 실행 및 반영 (5건)
- [ ] 사용자 Plan Accept

---

## Task 1: preflight 테스트 + install.sh 스캔 추가

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-09-009-preflight-ux` (from `phase-09-install-conflict-defense`)

### 1-2. 테스트 작성 (TDD Red)
- [x] `tests/test-preflight.sh` 작성 (5개 체크)
- [x] Commit: `test(spec-09-009): add preflight scan test cases`

### 1-3. install.sh preflight 구현 (TDD Green)
- [x] install.sh에 preflight 블록 inline 추가
- [x] 테스트 실행 → Pass
- [x] Commit: `feat(spec-09-009): add preflight scan to install.sh`

---

## Task 2: update.sh 스캔 + state 복원 fallback

### 2-1. update.sh preflight + fallback
- [x] update.sh에 preflight 블록 inline 추가 (semver_lt 포함)
- [x] state 복원 graceful fallback 추가
- [x] 테스트 실행 → 모든 시나리오 Pass (5/5)
- [x] 기존 테스트 회귀 확인 (test-install-layout 7/7, test-update 7/7)
- [x] Commit: `feat(spec-09-009): add preflight scan to update.sh with state fallback`

---

## Task 3: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-009): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-009-preflight-ux`
- [ ] **PR 생성**: 사용자 승인 후
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 (test + install + update + archive) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-15 |
