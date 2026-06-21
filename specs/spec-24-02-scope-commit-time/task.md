# Task List: spec-24-02

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

---

## Task 0: 브랜치 생성

- [x] `git checkout -b spec-24-02-scope-commit-time` (커밋 없음 — setup)

---

## Task 1: 커밋시점 scope 테스트 (TDD Red)

- [x] `tests/test-scope-commit-time.sh` 작성 — 커버리지:
  - `_scope.sh` 함수 in/out-scope 판정
  - pre-commit out-of-scope staged → stderr 경고
  - pre-commit in-scope staged → 무경고
  - 경고 모드 → 항상 exit 0(커밋 미차단)
  - spec.md 없음 → no-op
- [x] 테스트 실행 → **Fail 확인** (3 PASS / 4 FAIL — Test 1·2·4·5)
- [x] Commit: `test(spec-24-02): add failing commit-time scope guard test` (de097c9)

---

## Task 2: `_scope.sh` 추출 + check-scope.sh 위임 (TDD Green pt1)

- [x] `sources/hooks/_scope.sh` 신규 — `scope_is_safe_path`·`scope_extract_paths`·`scope_path_in_scope`
- [x] `sources/hooks/check-scope.sh` — inline 매칭 제거 → `_scope.sh` 위임 (동작 불변)
- [x] 도그푸딩 미러: `.harness-kit/hooks/_scope.sh`·`.harness-kit/hooks/check-scope.sh` 동일 반영
- [x] 테스트 실행 → 6/7 PASS (함수 케이스 green), precommit 회귀 13/13
- [x] Commit: `refactor(spec-24-02): extract scope resolution into _scope.sh` (cf7eb8e)

---

## Task 3: pre-commit 커밋시점 scope 경고 블록 (TDD Green pt2)

- [x] `sources/hooks/pre-commit.sh` — secret 검사 후·plan-accept 전에 커밋시점 scope 경고 블록 추가, `STATE_FILE` 정의 이동
- [x] 도그푸딩 미러: `.harness-kit/hooks/pre-commit.sh` 동일 반영
- [x] 테스트 실행 → `test-scope-commit-time.sh` 7/7 Pass
- [x] `tests/test-git-precommit-hook.sh` 실행 → 13/13 회귀 없음
- [x] Commit: `feat(spec-24-02): add commit-time scope guard (warn mode)` (6de6fb9)

---

## Task N: Ship (필수)

### 🚦 Pre-Push Quality Gate

- [x] **전체 테스트 실행** → 68/68 PASS (신규 7/7 포함, 회귀 없음)

### 📝 산출물 작성

- [x] **walkthrough.md 작성** (git 네이티브 hook 결정 기록 포함)
- [x] **pr_description.md 작성**
- [ ] Commit: `docs(spec-24-02): ship walkthrough and pr description`

### 🚀 Push & PR

- [ ] `git push -u origin spec-24-02-scope-commit-time`
- [ ] PR 생성 (`/hk-pr-gh`)
