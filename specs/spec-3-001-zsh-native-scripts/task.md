# Task List: spec-3-001

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
- [x] `git checkout -b spec-3-001-zsh-native-scripts`

---

## Task 2: _lib.sh에 셸 호환 함수 추가

### 2-1. _script_dir 함수 추가
- [x] `sources/hooks/_lib.sh`에 `_script_dir` 함수 추가 (bash/zsh 분기)
- [x] Commit: `feat(spec-3-001): add _script_dir shell compat function to _lib.sh`

---

## Task 3: Hook 스크립트 BASH_SOURCE 교체

### 3-1. check-branch.sh
- [x] `${BASH_SOURCE[0]}` → `_self()` 인라인 함수로 교체

### 3-2. check-plan-accept.sh
- [x] 동일 교체

### 3-3. check-test-passed.sh
- [x] 동일 교체

- [x] Commit: `refactor(spec-3-001): replace BASH_SOURCE with _self in hooks`

---

## Task 4: sdd 배열 제거 및 BASH_SOURCE 교체

### 4-1. cmd_hooks 함수 배열 제거
- [x] `local -a HOOK_NAMES=(...)` → 문자열 기반 순차 처리로 교체
- [x] 0-based 배열 인덱싱 제거

### 4-2. BASH_SOURCE 교체
- [x] `${BASH_SOURCE[0]}` → `_self()` 호환 함수로 교체

- [x] Commit: `refactor(spec-3-001): remove bash arrays and BASH_SOURCE from sdd`

---

## Task 5: install.sh --shell 옵션 추가

### 5-1. CLI 옵션 파싱
- [x] `--shell=zsh|bash` 옵션 추가 (기본값: bash)

### 5-2. shebang 교체 로직
- [x] 파일 복사 시 shebang 교체 (`do_fix_shebang`)

### 5-3. BASH_SOURCE 호환 처리
- [x] install.sh 자체의 `${BASH_SOURCE[0]}` 호환 처리

- [x] Commit: `feat(spec-3-001): add --shell option to install.sh for zsh support`

---

## Task 6: doctor.sh zsh 모드 감지

### 6-1. zsh 감지 및 bash 체크 조건부 스킵
- [x] 설치된 스크립트의 shebang 기반 zsh 모드 감지
- [x] zsh 버전 정보 출력

- [x] Commit: `feat(spec-3-001): add zsh detection to doctor.sh`

---

## Task 7: 도그푸딩 동기화

### 7-1. scripts/harness/ 동기화
- [x] `sources/hooks/` → `scripts/harness/hooks/` 복사
- [x] `sources/bin/sdd` → `scripts/harness/bin/sdd` 복사
- [x] diff 검증

- [x] Commit: `chore(spec-3-001): sync scripts/harness/ with sources/`

---

## Task 8: 검증 테스트

### 8-1. 테스트 작성 및 실행
- [x] `tests/test-zsh-compat.sh` 작성
- [x] 테스트 실행 → PASS (20/20)

- [x] Commit: `test(spec-3-001): add zsh compatibility verification test`

---

## Task 9: Hand-off (필수)

- [x] 전체 테스트 실행 → PASS (모든 테스트 스위트 회귀 없음)
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-3-001): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-3-001-zsh-native-scripts`
- [ ] **PR 생성**: `/gh-pr`

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 9 |
| **예상 commit 수** | 8 (Task 1은 브랜치만) |
| **현재 단계** | Hand-off |
| **마지막 업데이트** | 2026-04-10 |
