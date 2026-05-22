# Task List: spec-x-check-secrets-dual-mode

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: check-secrets.sh 듀얼 모드 적용

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-x-check-secrets-dual-mode` (main 기준)
- [ ] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [ ] `tests/` 내 기존 테스트 구조 확인 후 check-secrets 관련 테스트 추가
- [ ] 직접 git hook 모드 (cmd 비어있음) 에서 secret 감지 여부 테스트 케이스 작성
- [ ] 테스트 실행 → Fail 확인
- [ ] Commit: `test(spec-x-check-secrets-dual-mode): add failing test for direct-commit secret scan`

### 1-3. check-secrets.sh 듀얼 모드 구현 (TDD Green)
- [ ] `sources/hooks/check-secrets.sh` line 15-21 수정 (cmd 비어있을 때 fall-through)
- [ ] 테스트 실행 → Pass 확인
- [ ] Commit: `fix(spec-x-check-secrets-dual-mode): dual-mode for direct git commit secret scan`

---

## Task 2: pre-commit.sh에서 check-secrets.sh 호출 추가

### 2-1. pre-commit.sh 수정 및 테스트
- [ ] `sources/hooks/pre-commit.sh`에 check-secrets.sh 호출 추가 (staged-lint 뒤, block 모드)
- [ ] 전체 테스트 실행 → Pass 확인
- [ ] Commit: `fix(spec-x-check-secrets-dual-mode): invoke check-secrets from pre-commit hook`

---

## Task 3: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] 전체 테스트 실행 → 모두 PASS (`bash tests/run_tests.sh`)
- [ ] **walkthrough.md 작성** (증거 로그)
- [ ] **pr_description.md 작성** (템플릿 준수)
- [ ] **Ship Commit**: `docs(spec-x-check-secrets-dual-mode): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-check-secrets-dual-mode`
- [ ] **PR 생성**: `gh pr create` 자동 실행
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 3 |
| **예상 commit 수** | 4 (test / fix×2 / ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-23 |
