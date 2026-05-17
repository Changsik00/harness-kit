# Task List: spec-x-sdd-state-guard

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. main 에서 브랜치 분기
- [x] `git checkout -b spec-x-sdd-state-guard`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 가드 helper 테스트 추가 (TDD Red)

### 2-1. tests/test-sdd-state-guard.sh 신설 — 7 check 작성
- [x] `tests/test-sdd-phase-activate.sh` 의 fixture 헬퍼 패턴 차용
- [x] Check 1-7 작성
- [x] `bash tests/test-sdd-state-guard.sh` 실행 → Fail 확인 (5 PASS / 8 FAIL)
- [x] Commit: `test(spec-x-sdd-state-guard): add failing tests for active-spec guard` (e87b6ee)

---

## Task 3: die_if_active_spec helper 추가 (TDD Green)

### 3-1. state.sh 에 helper 추가
- [x] `sources/bin/lib/state.sh` 에 `die_if_active_spec()` 추가
- [x] `.harness-kit/bin/lib/state.sh` 동기화 (도그푸딩)
- [x] 회귀 확인: state-guard 5 PASS 유지 (진입점 가드 미적용이라 8 FAIL 유지)
- [x] Commit: `feat(spec-x-sdd-state-guard): add die_if_active_spec helper` (720cce7)

---

## Task 4: phase_activate 에 가드 적용

### 4-1. sources/bin/sdd 의 phase_activate 갱신
- [x] `--force` 플래그 사전 파싱 추가
- [x] `die_if_active_spec "phase activate"` 호출 추가
- [x] `.harness-kit/bin/sdd` 동기화
- [x] `cmd_help` 의 `phase activate` 설명 갱신
- [x] state-guard Check 1-2 PASS (9 PASS / 4 FAIL)
- [x] phase-activate 회귀 13/13 PASS
- [x] Commit: `fix(spec-x-sdd-state-guard): guard active spec in phase activate` (200107b)

---

## Task 5: phase_new 에 가드 적용

### 5-1. sources/bin/sdd 의 phase_new 갱신
- [x] `die_if_active_spec "phase new"` 호출 추가 (기존 `force_mode` 재사용)
- [x] `.harness-kit/bin/sdd` 동기화
- [x] `cmd_help` 의 `phase new` 설명 보강
- [x] state-guard Check 3-4 PASS (11 PASS / 2 FAIL)
- [x] phase-activate 회귀 13/13 PASS
- [x] Commit: `fix(spec-x-sdd-state-guard): guard active spec in phase new` (1134bd3)

---

## Task 6: spec_new 에 가드 적용

### 6-1. sources/bin/sdd 의 spec_new 갱신
- [x] `--force` 플래그 사전 파싱 추가
- [x] `die_if_active_spec "spec new"` 호출 추가
- [x] `.harness-kit/bin/sdd` 동기화
- [x] `cmd_help` 의 `spec new` 설명 갱신
- [x] state-guard Check 5-6 PASS (13/13 ALL PASS)
- [x] spec-new-seq 회귀 5/5 PASS
- [x] Commit: `fix(spec-x-sdd-state-guard): guard active spec in spec new` (7704ccf)

---

## Task 7: 전체 회귀 테스트

### 7-1. 본 spec 관련 테스트 + 인접 회귀 실행
- [x] `bash tests/test-sdd-state-guard.sh` → 13/13 ALL PASS
- [x] `bash tests/test-sdd-phase-activate.sh` → 13/13 ALL PASS
- [x] `bash tests/test-sdd-spec-new-seq.sh` → 5/5 ALL PASS
- [x] `bash tests/test-sdd-phase-done-accuracy.sh` → 4/4 ALL PASS
- [x] `bash tests/test-sdd-spec-completeness.sh` → 4/4 ALL PASS
- [x] `bash tests/test-sdd-ship-completion.sh` → 9/9 ALL PASS
- [x] `sdd test passed` 기록
- [x] Commit: 없음 (검증만)

---

## Task 8: Ship

- [x] **walkthrough.md 작성** — 결정 기록 + 발견 사항 + 이월 항목 (state-namespace-split ADR carry-over 포함)
- [x] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-sdd-state-guard): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-sdd-state-guard`
- [ ] **PR 생성**: `gh pr create`
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 |
| **실제 commit 수** | 5 + 1 (ship) |
| **현재 단계** | Ship |
| **마지막 업데이트** | 2026-05-17 |
