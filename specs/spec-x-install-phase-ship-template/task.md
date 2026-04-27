# Task List: spec-x-install-phase-ship-template

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [-] 백로그 업데이트 — Pass: spec-x 는 phase.md/queue.md 갱신 불필요 (constitution §5.1)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. main 으로부터 spec-x 브랜치 분기
- [ ] `git checkout -b spec-x-install-phase-ship-template` (main 에서 분기)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: 회귀 테스트 추가 (TDD Red)

### 2-1. tests/test-install-layout.sh 에 8개 템플릿 검증 블록 추가
- [ ] 8개 템플릿 (`queue.md`, `phase.md`, `phase-ship.md`, `spec.md`, `plan.md`, `task.md`, `walkthrough.md`, `pr_description.md`) 존재 검증 루프 추가
- [ ] `bash tests/test-install-layout.sh` 실행 → `phase-ship.md 없음` FAIL 확인 (Red)
- [ ] Commit: `test(spec-x-install-phase-ship-template): add 8-template existence check`

---

## Task 3: install.sh 수정 (TDD Green)

### 3-1. install.sh 의 템플릿 리스트에 phase-ship.md 추가
- [ ] `install.sh:262` 의 `for f in ...` 리스트에 `phase-ship.md` 추가
- [ ] `bash tests/test-install-layout.sh` 실행 → 모두 PASS (Green)
- [ ] Commit: `fix(spec-x-install-phase-ship-template): copy phase-ship.md template on install`

---

## Task 4: Ship (필수)

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 sweep: `for t in tests/test-*.sh; do bash "$t" || echo "FAIL: $t"; done` → Total fails = 0
- [ ] **walkthrough.md 작성** (결정/검증/발견)
- [ ] **pr_description.md 작성** (한국어)
- [ ] **Ship Commit**: `docs(spec-x-install-phase-ship-template): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-install-phase-ship-template`
- [ ] **PR 생성**: `gh pr create` PR base = main
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 (Pre-flight + Task1~3 + Ship) |
| **예상 commit 수** | 3 (Task 2, 3 + Ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-27 |
