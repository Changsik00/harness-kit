# Task List: spec-15-02

> 모든 task 는 한 commit 에 대응 (One Task = One Commit).

## Pre-flight

- [x] Spec ID 확정 + 디렉토리 생성 (`sdd spec new stateful-fixture-system`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] phase-15.md spec 표 자동 갱신 (sdd 처리)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-15-02-stateful-fixture-system` (phase-15-upgrade-safety 에서 분기)
- [x] Commit: 없음

---

## Task 2: TDD Red — fixture lib 단위 테스트 작성

### 2-1. 테스트 작성
- [x] `tests/test-fixture-lib.sh` 신규 — 7 그룹 × 검증 = 18 checks

### 2-2. 실행 → Fail 확인
- [x] Red — "lib not found" 1 fail
- [x] Commit: `test(spec-15-02): add failing tests for fixture lib mixins`

---

## Task 3: TDD Green — `tests/lib/fixture.sh` 구현

### 3-1. 디렉토리 + 파일 생성
- [x] `mkdir -p tests/lib`
- [x] `tests/lib/fixture.sh` 신규 — `make_fixture` + 5 mixin
- [x] `make_fixture` 가 queue.md 템플릿을 자동 복사 (install.sh 가 만들지 않음 — 사용 중인 사용자 모사)

### 3-2. 검증
- [x] `bash tests/test-fixture-lib.sh` → 18/18 PASS
- [x] `bash tests/test-version-bump.sh` → 전체 스위트 FAIL=0
- [x] Commit: `feat(spec-15-02): implement fixture lib with 5 mixins`

---

## Task 4: Ship

- [x] 회귀 검증 — `bash tests/test-version-bump.sh` PASS (6/6 + 전체 FAIL=0)
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-15-02): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-15-02-stateful-fixture-system`
- [ ] **PR 생성**: `gh pr create --base phase-15-upgrade-safety`
- [ ] 머지 후 `sdd ship` 으로 phase-15.md spec 표 자동 Merged 갱신

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 4 |
| **예상 commit 수** | 3 (Task 1 은 브랜치 생성만) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-28 |
