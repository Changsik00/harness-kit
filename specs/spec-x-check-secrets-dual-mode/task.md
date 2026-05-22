# Task List: spec-x-check-secrets-dual-mode

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: check-secrets.sh 듀얼 모드 적용

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-x-check-secrets-dual-mode` (main 기준)
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [x] `tests/test-check-secrets-dual-mode.sh` 신규 작성 (11개 테스트)
- [x] Commit: `test(spec-x-check-secrets-dual-mode): add failing tests for dual-mode secret scan`

### 1-3. check-secrets.sh 듀얼 모드 구현 (TDD Green)
- [x] `sources/hooks/check-secrets.sh` 재설계 — HARNESS_GIT_HOOK_MODE 기반 분기, BSD grep 수정, + 라인 필터
- [x] Commit: `fix(spec-x-check-secrets-dual-mode): dual-mode for direct git commit secret scan` (외 3개)

---

## Task 2: pre-commit.sh에서 check-secrets.sh 호출 추가

### 2-1. pre-commit.sh 수정 및 테스트
- [x] `sources/hooks/pre-commit.sh`에 `HARNESS_GIT_HOOK_MODE=1 bash check-secrets.sh` 추가
- [x] 전체 테스트 PASS
- [x] Commit: `fix(spec-x-check-secrets-dual-mode): pass HARNESS_GIT_HOOK_MODE=1 from pre-commit`

---

## Task 3: Ship

- [x] 전체 테스트 실행 → 11 PASS (신규) + 13 PASS (회귀)
- [x] **walkthrough.md 작성** (증거 로그)
- [x] **pr_description.md 작성** (템플릿 준수)
- [x] **Ship Commit**: `docs(spec-x-check-secrets-dual-mode): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-check-secrets-dual-mode`
- [ ] **PR 생성**: `gh pr create` 자동 실행
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 8 (실제) |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-05-23 |
