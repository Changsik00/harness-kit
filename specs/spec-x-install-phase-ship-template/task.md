# Task List: spec-x-install-phase-ship-template

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — Pass: spec-x 는 phase.md/queue.md 갱신 불필요 (constitution §5.1)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. main 으로부터 spec-x 브랜치 분기
- [x] `git checkout -b spec-x-install-phase-ship-template` (main 에서 분기)
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 회귀 테스트 추가 (TDD Red)

### 2-1. tests/test-install-layout.sh 에 8개 템플릿 검증 블록 추가
- [x] 8개 템플릿 검증 루프 추가 (Check 8)
- [x] `bash tests/test-install-layout.sh` 실행 → `phase-ship.md 없음` 1건 FAIL (Red, 14/15)
- [x] Commit: `test(spec-x-install-phase-ship-template): add 8-template existence check`

---

## Task 3: install.sh 수정 (TDD Green)

### 3-1. install.sh 의 템플릿 리스트에 phase-ship.md 추가
- [x] `install.sh:262` 의 `for f in ...` 리스트에 `phase-ship.md` 추가
- [x] `bash tests/test-install-layout.sh` 실행 → ALL PASS (15/15)
- [x] Commit: `fix(spec-x-install-phase-ship-template): copy phase-ship.md template on install`

---

## Task 4: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 sweep → Total fails = 0
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Ship Commit**
- [ ] **Push**
- [ ] **PR 생성**
- [ ] **사용자 알림**

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (Pre-flight + Task1~3 + Ship) |
| **예상 commit 수** | 3 (Task 2, 3 + Ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-27 |
