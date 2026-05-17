# Task List: spec-17-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] phase-17.md 의 spec-17-01 중복 행 수동 정리 (sdd marker append 버그 — 본 spec 의 fix 대상이지만 fix 전에는 수동)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

### 1-1. 브랜치 생성
- [x] `git checkout -b spec-17-01-sdd-marker-bugs-fix` (from `phase-17-coherence-fix`)
- [x] Commit: 없음

### 1-2. phase-17.md dedupe + 기획 산출물 commit
- [x] phase-17.md 의 중복 spec-17-01 행 수동 정리 — *마지막 수동 dedupe*
- [x] `git add backlog/phase-17.md backlog/queue.md specs/spec-17-01-sdd-marker-bugs-fix/`
- [x] Commit: `chore(spec-17-01): add planning artifacts + dedupe phase-17 marker (last manual dedupe before fix)` (12a48ea)

---

## Task 2: TDD Red — fixture + 실패 테스트

### 2-1. 테스트 스크립트 작성
- [x] `tests/test-sdd-marker-idempotent.sh` 작성 — 3 시나리오
- [x] `chmod +x tests/test-sdd-marker-idempotent.sh`
- [x] Test 1 FAIL 확인 (pre-fix)
- [x] Commit: `test(spec-17-01): add failing test for sdd marker idempotency` (f34282f)

---

## Task 3: TDD Green Step 1 — `cmd_spec_new` fix

### 3-1. sources/bin/sdd 의 spec_new 함수 marker 매칭 확장
- [x] `sources/bin/sdd:1170` 주변 — backtick OR plain text 매칭 분기 추가
- [x] install 미러 sync
- [x] Test 1, 2 PASS 확인
- [x] Commit: `fix(spec-17-01): match plain-text Backlog row in cmd_spec_new` (dcd69a0)

---

## Task 4: TDD Green Step 2 — `cmd_ship` fix

### 4-1. sources/bin/sdd 의 ship 함수에 Backlog 행 제거 로직 추가
- [x] `sources/bin/sdd:1434-1445` — awk 에 short_sid Backlog 행 삭제 분기 추가
- [x] install 미러 sync (diff OK)
- [x] 회귀 없음 (test-drift-stale-adr 3/3)
- [x] Commit: `fix(spec-17-01): remove Backlog row in cmd_ship after Merged update` (9e621c1)

---

## Task 5: TDD Green Step 3 — `queue_mark_done` normalize

### 5-1. sources/bin/sdd 의 queue_mark_done 진입부 normalize
- [x] `sources/bin/sdd:993` 진입부에 case normalize 추가
- [x] install 미러 sync
- [x] Test 3 PASS (`**phase-99** — Marker Test Fixture` 정상 출력)
- [x] Commit: `fix(spec-17-01): normalize phase_id in queue_mark_done` (4d6bc2d)

---

## Task 6: 회귀 점검

### 6-1. 기존 테스트 PASS 확인
- [x] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS
- [x] `bash .harness-kit/bin/sdd status` → 정상 출력 (Active Phase phase-17, Active Spec spec-17-01)
- [x] phase-08 ~ 16 본문 변경 없음
- [x] Commit: 없음 (검증만)

---

## Task 7: 통합 시나리오 (phase-17.md 시나리오 1)

### 7-1. 본 spec self-cleanup 시연
- [x] fixture phase-99 시나리오: spec new → 행 수 1, Active
- [x] phase done `99` → entry `**phase-99** — Marker Test Fixture` 형식 ✓
- [x] cleanup (trap)
- [x] Commit: 없음

---

## Task 8: Ship

- [x] **walkthrough.md 작성** — 6 결정 + 검증 + 발견 4
- [x] **pr_description.md 작성** — 9 파일 + RCA-001 prevention 직접 명시
- [ ] **Ship Commit**: `docs(spec-17-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-17-01-sdd-marker-bugs-fix`
- [ ] **PR 생성**: `gh pr create --base phase-17-coherence-fix`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 (Pre-flight 별도) |
| **예상 commit 수** | 6 (planning + test + 3 fix + ship) — Task 6/7 검증만 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-17 |
