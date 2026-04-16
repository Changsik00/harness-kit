# Task List: spec-02-003

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-02-003-enforce-to-suggest`

---

## Task 2: _lib.sh에 per-hook 모드 지원 추가

### 2-1. hook_resolve_mode 함수 추가
- [x] `sources/hooks/_lib.sh`에 `hook_resolve_mode` 함수 추가
- [x] Commit: `feat(spec-02-003): add per-hook mode resolution to _lib.sh`

---

## Task 3: 각 hook에 per-hook 모드 적용

### 3-1. check-branch.sh
- [x] `hook_resolve_mode "BRANCH" "block"` 호출 추가 (source _lib.sh 직후)

### 3-2. check-plan-accept.sh
- [x] `hook_resolve_mode "PLAN_ACCEPT" "warn"` 호출 추가

### 3-3. check-test-passed.sh
- [x] `hook_resolve_mode "TEST_PASSED" "warn"` 호출 추가

- [x] Commit: `feat(spec-02-003): apply per-hook default modes to all hooks`

---

## Task 4: sdd hooks 서브커맨드

### 4-1. sdd에 hooks 서브커맨드 추가
- [x] `sdd hooks` — 각 hook 이름, 현재 모드, 기본값 표시
- [x] `sdd hooks block <name>` — 해당 hook을 block으로 안내
- [x] `sdd hooks warn <name>` — 해당 hook을 warn으로 안내
- [x] Commit: `feat(spec-02-003): add sdd hooks subcommand`

---

## Task 5: 도그푸딩 동기화

### 5-1. scripts/harness/ 동기화
- [x] `sources/hooks/` → `scripts/harness/hooks/` 복사
- [x] `sources/bin/sdd` → `scripts/harness/bin/sdd` 복사
- [x] diff 검증
- [x] Commit: `chore(spec-02-003): sync scripts/harness/ with sources/`

---

## Task 6: 검증 테스트

### 6-1. 테스트 작성 및 실행
- [x] `tests/test-hook-modes.sh` 작성
- [x] 테스트 실행 → PASS
- [x] Commit: `test(spec-02-003): add hook mode verification test`

---

## Task 7: Hand-off (필수)

- [x] 전체 테스트 실행 → PASS
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [x] **Archive Commit**: `docs(spec-02-003): archive walkthrough and pr description`
- [x] **Push**: `git push -u origin spec-02-003-enforce-to-suggest`
- [x] **PR 생성**: `/gh-pr`

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 |
| **예상 commit 수** | 6 (Task 1은 브랜치만) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-10 |
