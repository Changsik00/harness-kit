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
- [ ] `git checkout -b spec-17-01-sdd-marker-bugs-fix` (from `phase-17-coherence-fix`)
- [ ] Commit: 없음

### 1-2. phase-17.md dedupe + 기획 산출물 commit
- [ ] phase-17.md 의 중복 spec-17-01 행 수동 정리 (Pre-flight 항목 실현)
- [ ] `git add backlog/phase-17.md backlog/queue.md specs/spec-17-01-sdd-marker-bugs-fix/`
- [ ] Commit: `chore(spec-17-01): add planning artifacts + dedupe phase-17 marker (last manual dedupe before fix)`

---

## Task 2: TDD Red — fixture + 실패 테스트

### 2-1. 테스트 스크립트 작성
- [ ] `tests/test-sdd-marker-idempotent.sh` 작성 — 3 시나리오 (spec new 멱등 / spec new 후 Active / phase done normalize)
- [ ] `chmod +x tests/test-sdd-marker-idempotent.sh`
- [ ] `bash tests/test-sdd-marker-idempotent.sh` 실행 → spec new 멱등 시나리오 FAIL 확인 (pre-fix)
- [ ] Commit: `test(spec-17-01): add failing test for marker idempotency`

---

## Task 3: TDD Green Step 1 — `cmd_spec_new` fix

### 3-1. sources/bin/sdd 의 spec_new 함수 marker 매칭 확장
- [ ] `sources/bin/sdd:1170` 주변 — backtick OR plain text 둘 다 매칭하도록 분기 추가 (plan.md §Proposed Changes Fix 1)
- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd && chmod +x .harness-kit/bin/sdd`
- [ ] `bash tests/test-sdd-marker-idempotent.sh` 재실행 → Test 1, 2 (spec new) PASS 확인. Test 3 (phase done) 은 여전히 FAIL 가능
- [ ] Commit: `fix(spec-17-01): match plain-text Backlog row in cmd_spec_new`

---

## Task 4: TDD Green Step 2 — `cmd_ship` fix

### 4-1. sources/bin/sdd 의 ship 함수에 Backlog 행 제거 로직 추가
- [ ] `sources/bin/sdd:1433-1440` 주변 — awk 패턴에 동일 short_id 의 Backlog 행 삭제 분기 추가 (plan.md §Proposed Changes Fix 2)
- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd && chmod +x .harness-kit/bin/sdd`
- [ ] 통합 시나리오 수동 확인 — fixture phase + spec + ship 시 Backlog 행 사라짐
- [ ] Commit: `fix(spec-17-01): remove Backlog row in cmd_ship after Merged update`

---

## Task 5: TDD Green Step 3 — `queue_mark_done` normalize

### 5-1. sources/bin/sdd 의 queue_mark_done 진입부 normalize
- [ ] `sources/bin/sdd:993` 주변 — phase_id case normalize (plan.md §Proposed Changes Fix 3)
- [ ] `cp sources/bin/sdd .harness-kit/bin/sdd && chmod +x .harness-kit/bin/sdd`
- [ ] `bash tests/test-sdd-marker-idempotent.sh` 재실행 → 3 시나리오 모두 PASS
- [ ] Commit: `fix(spec-17-01): normalize phase_id in queue_mark_done`

---

## Task 6: 회귀 점검

### 6-1. 기존 테스트 PASS 확인
- [ ] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS (회귀 없음)
- [ ] `bash .harness-kit/bin/sdd status` → 정상 출력
- [ ] phase-08 ~ 16 본문 변경 없는지 확인 (`git status`)
- [ ] Commit: 없음 (검증만)

---

## Task 7: 통합 시나리오 (phase-17.md 시나리오 1)

### 7-1. 본 spec self-cleanup 시연
- [ ] fix 머지 후 임시 fixture phase 만들어서 spec new 반복 시 행 수 1 유지 확인
- [ ] phase done `99` → entry `**phase-99**` 형식 확인
- [ ] cleanup
- [ ] Commit: 없음

---

## Task 8: Ship

- [ ] **walkthrough.md 작성** — 3 버그 root cause + fix 결정 + 검증 로그
- [ ] **pr_description.md 작성** — 변경 파일 + PR target=phase-17-coherence-fix + RCA-001 prevention 명시
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
