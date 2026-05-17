# Task List: spec-x-sdd-state-guard

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. main 에서 브랜치 분기
- [x] `git checkout -b spec-x-sdd-state-guard`
- [x] Commit: 없음 (브랜치 생성만)

---

## Task 2: 가드 helper 테스트 추가 (TDD Red)

### 2-1. tests/test-sdd-state-guard.sh 신설 — 7 check 작성
- [ ] `tests/test-sdd-phase-activate.sh` 의 fixture 헬퍼 패턴 차용
- [ ] Check 1: 활성 spec-x 상태 + `phase activate` → die + state 보존
- [ ] Check 2: 활성 spec-x 상태 + `phase activate --force` → 통과 + state 덮어쓰기
- [ ] Check 3: 활성 spec-x 상태 + `phase new <slug>` → die + state 보존
- [ ] Check 4: 활성 spec-x 상태 + `phase new <slug> --force` → 통과
- [ ] Check 5: 활성 SDD-P spec 상태 + `spec new <slug>` → die + `sdd ship` 안내 포함
- [ ] Check 6: 활성 SDD-P spec 상태 + `spec new <slug> --force` → 통과
- [ ] Check 7: 활성 spec 없는 상태에서 모든 명령 → 정상 동작 (회귀 가드)
- [ ] `bash tests/test-sdd-state-guard.sh` 실행 → Fail 확인 (helper 미존재)
- [ ] Commit: `test(spec-x-sdd-state-guard): add failing tests for active-spec guard`

---

## Task 3: die_if_active_spec helper 추가 (TDD Green)

### 3-1. sources/bin/lib/state.sh 에 helper 추가
- [ ] `state_set` 함수 다음에 `die_if_active_spec()` 추가 (plan.md §Proposed Changes 의 코드 블록 그대로)
- [ ] `.harness-kit/bin/lib/state.sh` 에도 동일하게 반영 (도그푸딩)
- [ ] `bash tests/test-sdd-state-guard.sh` → helper 자체 동작은 통과 (Check 7) but 진입점 가드 미적용이라 Check 1-6 여전히 Fail 예상 — 명시적으로 확인
- [ ] Commit: `feat(spec-x-sdd-state-guard): add die_if_active_spec helper`

---

## Task 4: phase_activate 에 가드 적용

### 4-1. sources/bin/sdd 의 phase_activate 갱신
- [ ] `--force` 플래그 사전 파싱 추가 (기존 `--base` 파싱 위에)
- [ ] `die_if_active_spec "phase activate"` 호출 추가 (force=0 일 때만)
- [ ] `.harness-kit/bin/sdd` 동기화
- [ ] `cmd_help` 의 `phase activate` 설명에 `[--force]` 추가 + 한 줄 설명 갱신
- [ ] `bash tests/test-sdd-state-guard.sh` Check 1-2 PASS 확인
- [ ] `bash tests/test-sdd-phase-activate.sh` 9 check 회귀 PASS 확인
- [ ] Commit: `fix(spec-x-sdd-state-guard): guard active spec in phase activate`

---

## Task 5: phase_new 에 가드 적용

### 5-1. sources/bin/sdd 의 phase_new 갱신
- [ ] 기존 `force_mode` 파싱 위치는 변경 없음
- [ ] `die_if_active_spec "phase new"` 호출 추가 (force_mode=0 일 때만, 사전 정의 phase 가드 *전에* 위치)
- [ ] `.harness-kit/bin/sdd` 동기화
- [ ] `cmd_help` 의 `phase new` 설명에 활성 spec 가드 의미 보강
- [ ] `bash tests/test-sdd-state-guard.sh` Check 3-4 PASS 확인
- [ ] `bash tests/test-sdd-phase-activate.sh` 회귀 PASS 확인
- [ ] Commit: `fix(spec-x-sdd-state-guard): guard active spec in phase new`

---

## Task 6: spec_new 에 가드 적용

### 6-1. sources/bin/sdd 의 spec_new 갱신
- [ ] `--force` 플래그 사전 파싱 추가
- [ ] `die_if_active_spec "spec new"` 호출 추가 (force=0 일 때만, `_pre_spec_validation` *전에* 위치)
- [ ] `.harness-kit/bin/sdd` 동기화
- [ ] `cmd_help` 의 `spec new` 설명에 `[--force]` 추가
- [ ] `bash tests/test-sdd-state-guard.sh` Check 5-6 PASS 확인
- [ ] `bash tests/test-sdd-spec-new-seq.sh` 회귀 PASS 확인 (영향 있을 시)
- [ ] Commit: `fix(spec-x-sdd-state-guard): guard active spec in spec new`

---

## Task 7: 전체 회귀 테스트

### 7-1. 본 spec 관련 테스트 전부 실행
- [ ] `bash tests/test-sdd-state-guard.sh` → 7 check ALL PASS
- [ ] `bash tests/test-sdd-phase-activate.sh` → 9 check ALL PASS
- [ ] `bash tests/test-sdd-spec-new-seq.sh` → ALL PASS
- [ ] (선택) 도그푸딩 검증: 본 spec-x 자체에서 `sdd phase activate phase-01` → die 메시지 + `sdd specx done sdd-state-guard` 안내 확인 (state 손상 X)
- [ ] Commit: 없음 (검증만)

---

## Task 8: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [ ] **walkthrough.md 작성** — 단일평면 footgun 발견 경위, 가드 설계 시 고민 (메시지 분기, force 의미), state-namespace-split ADR carry-over 명시
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-x-sdd-state-guard): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-sdd-state-guard`
- [ ] **PR 생성**: `gh pr create` (Co-Authored-By / Generated with Claude Code 배지 모두 제외)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 (Pre-flight 별도) |
| **예상 commit 수** | 5 (Task 2-6 각 1 + Task 8 ship 1) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-17 |
