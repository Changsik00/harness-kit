# Task List: spec-16-03

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 — `sdd spec new` 가 처리 (수동 dedupe 필요 — Task 1-2)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-16-03-stale-decision-detect` (from `phase-16-reliability-layer`)
- [x] Commit: 없음 (브랜치 생성만)

### 1-2. 기획 산출물 + sdd ship 버그 dedupe
- [x] `phase-16.md` 의 중복된 spec-16-03 행 수동 정리 (sdd spec new 의 marker append 버그 회피)
- [x] `git add backlog/phase-16.md backlog/queue.md specs/spec-16-03-stale-decision-detect/`
- [x] Commit: `chore(spec-16-03): add planning artifacts (spec/plan/task) + dedupe phase-16 marker` (c038f7b)

---

## Task 2: TDD Red — fixture + 실패 테스트

### 2-1. 테스트 스크립트 작성
- [x] `tests/test-drift-stale-adr.sh` 작성 — 3 단계 (clean / fixture / 회귀) 검증
- [x] `chmod +x tests/test-drift-stale-adr.sh`
- [x] `bash tests/test-drift-stale-adr.sh` 실행 → 2 단계에서 FAIL 확인 (pre-implementation)
- [x] Commit: `test(spec-16-03): add failing test for stale ADR drift detection` (334a5dd)

---

## Task 3: TDD Green — `_drift_stale_adr()` 구현

### 3-1. sources/bin/sdd 함수 추가 + wire
- [x] `sources/bin/sdd` 의 `_drift_kit_version()` 직후에 `_drift_stale_adr()` 추가
- [x] `_status_drift()` 의 has_drift 체인에 `_drift_stale_adr && has_drift=1` 추가
- [x] `bash tests/test-drift-stale-adr.sh` 실행 → Task 4 sync 후 모두 PASS 확인 (테스트가 .harness-kit/ 경로 호출)
- [x] Commit: `feat(spec-16-03): add _drift_stale_adr to sdd drift chain` (ee44e3f)

---

## Task 4: install 미러 동기화

### 4-1. .harness-kit/bin/sdd 동기화
- [x] `cp sources/bin/sdd .harness-kit/bin/sdd`
- [x] `chmod +x .harness-kit/bin/sdd` (실행권한 보존)
- [x] `diff sources/bin/sdd .harness-kit/bin/sdd` → 차이 없음
- [x] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS
- [x] Commit: `feat(spec-16-03): sync sdd to install mirror` (ce25da9)

---

## Task 5: 통합 테스트 (phase 시나리오 2)

### 5-1. 통합 시나리오 수동 실행
- [x] Given: `docs/decisions/ADR-999-stale-integration.md` 임시 생성 (`src/removed-module.ts` 참조)
- [x] When: `HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status`
- [x] Then: 출력에 "stale ADR: 1 (missing-path) — docs/decisions/ADR-999-stale-integration.md" hit ✓
- [x] Cleanup: `rm docs/decisions/ADR-999-stale-integration.md`
- [x] 정리 후 재실행 → stale 라인 사라짐 (grep count = 0)
- [x] Commit: 없음 (통합 시나리오는 fixture-based, 영구 파일 X)

---

## Task 6: ADR-001 회귀 검증

### 6-1. 기존 ADR 검사
- [x] `HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status` → drift 섹션에 "stale ADR" 라인 *없음* ✓
- [x] ADR-001-knowledge-types 의 backtick 경로가 모두 valid 임을 간접 검증 (test step 3 + 수동)
- [x] Commit: 없음 (검증만)

---

## Task 7: Ship

> 모든 작업 task 완료 후 `/hk-ship` 절차를 따릅니다.

- [x] 코드 품질 점검 — pre-commit shellcheck 통과 (sources/bin/sdd 변경 시)
- [x] Task 2~6 검증 항목 전수 재확인
- [x] **walkthrough.md 작성** — 결정 기록 6 + 검증 로그 + 발견 5
- [x] **pr_description.md 작성** — 변경 파일 9 + PR target=phase-16-reliability-layer 명시
- [x] **Ship Commit**: `docs(spec-16-03): ship walkthrough and pr description` (1a7c47a)
- [x] **Push**: `git push -u origin spec-16-03-stale-decision-detect`
- [x] **PR 생성**: `gh pr create --base phase-16-reliability-layer` → https://github.com/Changsik00/harness-kit/pull/118
- [x] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight 별도) |
| **예상 commit 수** | 5 (planning + test + feat + sync + ship) — Task 5/6 은 commit 없음 |
| **현재 단계** | Shipped (PR #118) |
| **마지막 업데이트** | 2026-05-16 |
