# Task List: spec-21-05

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-21.md SPEC 표 상태 갱신)
- [ ] 사용자 Plan Accept

---

## Task 1: 통합 테스트 작성 + 검증

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-21-05-integration-test` from `phase-21-turbo-mode`

### 1-2. 테스트 작성 (TDD Red → Green 통합)
- [ ] `tests/test-turbo-mode.sh` 작성 (4개 시나리오)
  - S1: turbo 모드 → check-plan-accept exit 0 (happy path)
  - S2: turbo + intent.test FAIL → post-commit-verify revert
  - S3: governed 복귀 → check-plan-accept 차단
  - S4: governed 기본 → check-plan-accept 차단 (회귀)
- [ ] 테스트 실행 → 4/4 PASS 확인
- [ ] Commit: `test(spec-21-05): add turbo mode integration tests`

### 1-3. 회귀 테스트 실행
- [ ] `bash tests/run.sh` → 전체 PASS 확인
- [ ] (별도 커밋 없음 — 실행 확인만)

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [ ] `bash tests/test-turbo-mode.sh` → 4/4 PASS
- [ ] `bash tests/run.sh` → 전체 PASS

### 📝 산출물 작성

- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-21-05): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] **Push**: `git push -u origin spec-21-05-integration-test`
- [ ] **PR 생성**: `gh pr create --base phase-21-turbo-mode`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 1 |
| **예상 commit 수** | 2 (test + docs-ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-06-13 |
