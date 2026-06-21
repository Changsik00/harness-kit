# Task List: spec-24-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

---

## Task 1: scope commit 모드 테스트 (TDD Red)

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-24-02-auto-scope-commit` (완료)

### 1-2. 테스트 작성 (Red)
- [x] `tests/test-scope-commit.sh`: fixture 에서 plan-accepted + active spec(scope 정의), staged 파일이 범위 밖 → 경고(exit 0) + stderr, 범위 안 → 무경고, turbo/auto 에서도 검사, .md 면제
- [x] 실행 → Fail 확인 (commit 모드 미구현)
- [x] Commit: `test(spec-24-02): add failing test for commit-time scope`

---

## Task 2: dual-mode 구현 (TDD Green)

### 2-1. check-scope.sh dual-mode + pre-commit 연동
- [x] `sources/hooks/check-scope.sh`: scope 추출/매칭 함수화, `HARNESS_GIT_HOOK_MODE=1` → staged 루프 + 경고(exit 0, mode 무관). edit 모드 기존 유지
- [x] `sources/hooks/pre-commit.sh`: secret 뒤 scope(commit 모드) 호출
- [x] `sources/` → `.harness-kit/` 미러링
- [x] 테스트 실행 → Pass + 전체 회귀 (68/68)
- [x] Commit: `feat(spec-24-02): commit-time scope check (dual-mode, 경고)`

---

## Task 3: Ship

### 🚦 Pre-Push Quality Gate
- [x] 전체 테스트 PASS (68/68)

### 📝 산출물
- [x] walkthrough.md / pr_description.md
- [x] Commit: `docs(spec-24-02): ship walkthrough and pr description`

### 🚀 Push & PR
- [x] push + `gh pr create`
