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
- [ ] `tests/test-fixture-lib.sh` 신규 — 18+ checks:
  1. `make_fixture` (3 checks): 디렉토리 / .harness-kit/ / state.json 존재
  2. `with_in_flight_phase` (4 checks): state.phase / state.spec / phase.md / specs/ 디렉토리
  3. `with_pre_defined_phases` (3 checks): 파일 존재 (다중) / 마커 / 가변 인자
  4. `with_customized_fragment` (2 checks): 마커 존재 / 기존 본문 보존
  5. `with_dirty_queue_icebox` (2 checks): 마커 존재 / 마커 영역 손상 없음
  6. `with_user_hook` (2 checks): UserAddedHook 키 존재 / 기존 hooks 보존
  7. **조합** (2 checks): in_flight + dirty_queue + user_hook 동시 적용 정상

### 2-2. 실행 → Fail 확인
- [ ] `bash tests/test-fixture-lib.sh` → "lib not found" 또는 "function not defined" 류 fail
- [ ] Commit: `test(spec-15-02): add failing tests for fixture lib mixins`

---

## Task 3: TDD Green — `tests/lib/fixture.sh` 구현

### 3-1. 디렉토리 + 파일 생성
- [ ] `mkdir -p tests/lib`
- [ ] `tests/lib/fixture.sh` 신규 — `make_fixture` + 5 mixin (plan.md §Proposed Changes 의사코드 참고)

### 3-2. 검증
- [ ] `bash tests/test-fixture-lib.sh` → 모두 PASS (18+/18+)
- [ ] `bash tests/test-version-bump.sh` → 전체 스위트 FAIL=0 (회귀)
- [ ] Commit: `feat(spec-15-02): implement fixture lib with 5 mixins`

---

## Task 4: Ship

- [ ] 회귀 검증 — `bash tests/test-version-bump.sh` PASS
- [ ] **walkthrough.md 작성** — 결정 기록, mixin 설계 결정 이유, 발견 사항
- [ ] **pr_description.md 작성**
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
