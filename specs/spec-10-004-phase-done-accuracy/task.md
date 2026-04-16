# Task List: spec-10-004

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase.md SPEC 표 자동 갱신 완료)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + 테스트 작성

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-10-004-phase-done-accuracy` (base: `phase-10-status-reliability`)
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 테스트 작성 (TDD Red)
- [x] 테스트 파일 생성: `tests/test-sdd-phase-done-accuracy.sh`
  - 시나리오 1: Done 잔류 시 "모든 Merged" 미출력
  - 시나리오 2: 모든 spec Merged → "모든 Merged" 출력
  - 시나리오 3: Done + Backlog → NEXT가 Done spec (archive 우선)
  - 시나리오 4: git에 모두 머지 + phase.md Done 잔류 → git 기반 안내
- [x] 테스트 실행 → Fail 확인 (PASS=1, FAIL=3)
- [x] Commit: `test(spec-10-004): add failing tests for phase done accuracy`

---

## Task 2: `_check_phase_all_merged` 수정

### 2-1. Done 카운트 + $5 필드 비교 전환
- [x] `_check_phase_all_merged()` awk를 `$5` 필드 비교로 전환, Merged 아닌 모든 상태 카운트
- [x] git 기반 교차 확인 추가 — phase.md non-Merged이지만 git에 모두 머지 → 추가 안내
- [x] 테스트 실행 → 시나리오 1, 2 Pass (4는 status에서 확인 필요 → Task 3 후 재확인)
- [x] Commit: `fix(spec-10-004): count Done as incomplete in _check_phase_all_merged`

---

## Task 3: `compute_next_spec` 개선

### 3-1. Done 우선 검색 + git 기반 phase done 안내
- [x] `compute_next_spec()` awk에 Done 우선 검색 추가
- [x] `_status_diagnose()`에 git 기반 phase done 안내 추가
- [x] 테스트 실행 → 전체 4/4 Pass
- [x] Commit: `fix(spec-10-004): prioritize Done specs in compute_next_spec`

---

## Task 4: 도그푸딩 동기화

### 4-1. .harness-kit/bin/sdd 동기화
- [x] `sources/bin/sdd` → `.harness-kit/bin/sdd` 복사
- [x] 전체 회귀 테스트 17개 파일 전부 PASS
- [x] Commit: `chore(spec-10-004): sync sdd to .harness-kit`

---

## Task 5: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 전체 테스트 실행 → 17개 파일 전부 PASS
- [x] **walkthrough.md 작성**
- [x] **pr_description.md 작성**
- [ ] **Archive Commit**: `docs(spec-10-004): archive walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-10-004-phase-done-accuracy`
- [ ] **PR 생성**: `/hk-pr-gh`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 5 |
| **예상 commit 수** | 6 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-04-16 |
