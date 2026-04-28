# Task List: spec-15-04

> One Task = One Commit. 매 commit 직후 본 파일 체크박스 갱신.

## Pre-flight

- [x] Spec ID 확정 + 디렉토리 생성 (`sdd spec new historical-regression-tests`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] phase-15.md spec 표 자동 갱신 (sdd 처리)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + 테스트 파일 골격

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-15-04-historical-regression-tests` (phase-15-upgrade-safety 에서 분기)

### 1-2. 골격 작성
- [ ] `tests/test-update-stateful.sh` 신규 — header / source fixture lib / cleanup trap / md5 헬퍼 / 5 시나리오 placeholder
- [ ] 실행 → 시나리오 placeholder 메시지만 출력 + PASS 0 / FAIL 0
- [ ] Commit: `test(spec-15-04): scaffold test-update-stateful.sh with 5 scenario placeholders`

---

## Task 2: 시나리오 1 — in-flight phase (#82 회귀 잠금)

### 2-1. 구현
- [ ] `with_in_flight_phase` → update.sh → state 6 필드 before/after 비교
- [ ] kitVersion 갱신 검증
- [ ] phase.md / spec 디렉토리 보존 검증
- [ ] 4 checks PASS
- [ ] Commit: `test(spec-15-04): scenario 1 — in-flight phase preserves 6 state fields (#82)`

---

## Task 3: 시나리오 2 — pre-defined phases (#84 회귀 잠금)

### 3-1. 구현
- [ ] `with_pre_defined_phases phase-09 phase-10 phase-11` → update → md5 비교
- [ ] `sdd phase activate phase-09` 정상 동작 검증
- [ ] 2 checks PASS
- [ ] Commit: `test(spec-15-04): scenario 2 — pre-defined phases preserved through update (#84)`

---

## Task 4: 시나리오 4 — dirty queue (Pattern B 검증)

### 4-1. 구현
- [ ] `with_dirty_queue_icebox` → update → 사용자 메모 + sdd 마커 검증
- [ ] 2 checks PASS
- [ ] Commit: `test(spec-15-04): scenario 4 — dirty queue icebox preserved through update`

> 시나리오 3 (customized fragment) 는 plan.md §주요 결정 에 따라 skip — spec-15-06 으로.

---

## Task 5: 시나리오 5 — multi-install (#78 gitignore + #83 phase-ship)

### 5-1. 구현
- [ ] install 2 회 → 8 템플릿 존재 확인
- [ ] `.gitignore` 의 4 라인 (헤더 + .harness-kit + .harness-backup-* + .claude/state/) 각 1 회 정확
- [ ] 5 checks PASS
- [ ] Commit: `test(spec-15-04): scenario 5 — multi-install idempotent for templates and gitignore (#78, #83)`

---

## Task 6: Ship

- [ ] 회귀 검증 — `bash tests/test-version-bump.sh` PASS
- [ ] 본 spec 의 테스트 — `bash tests/test-update-stateful.sh` ≥ 10 checks PASS
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-15-04): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-15-04-historical-regression-tests`
- [ ] **PR 생성**: `gh pr create --base phase-15-upgrade-safety`

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 |
| **예상 commit 수** | 6 (시나리오마다 별 commit) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-28 |
