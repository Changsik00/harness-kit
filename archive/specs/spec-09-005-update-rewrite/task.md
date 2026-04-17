# Task List: spec-09-005

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-09.md SPEC 표 spec-09-005 Active 추가)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-09-005-update-rewrite` (phase-09-install-conflict-defense에서 시작)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: tests/test-update.sh 작성 (TDD Red)

### 2-1. 테스트 작성
- [ ] `tests/test-update.sh` 작성:
  - `--yes` 실행 후 state(phase/spec) 보존 확인
  - prefix 있는 경우 재설치 후 동일 prefix 유지 확인
  - `.harness-kit/` 재생성 확인
  - doctor 통과 확인
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-09-005): add failing test for update.sh rewrite`

---

## Task 3: update.sh 재작성

### 3-1. update.sh 전면 재작성
- [ ] uninstall `--yes --keep-state` 호출
- [ ] prefix 보존 (uninstall 전 config에서 읽기)
- [ ] install `--yes [--prefix ...] [--shell ...]` 호출
- [ ] `.harness-backup-*` / `.harness-uninstall-backup-*` cleanup
- [ ] doctor 호출
- [ ] `tests/test-update.sh` → Pass 확인
- [ ] 기존 테스트 회귀 확인
- [ ] Commit: `refactor(spec-09-005): rewrite update.sh as uninstall+install+cleanup`

---

## Task 4: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-09-005): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-09-005-update-rewrite`
- [ ] **PR 생성**: target: `phase-09-install-conflict-defense`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 (+ Ship) |
| **예상 commit 수** | 3 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-14 |
