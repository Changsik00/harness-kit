# Task List: spec-x-planning-economy

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (`sdd specx new planning-economy`)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

- [ ] `git checkout -b spec-x-planning-economy` (from `main`)
- [ ] `git add backlog/queue.md specs/spec-x-planning-economy/`
- [ ] `sdd plan accept` (선제 호출 — hook 차단 회피)
- [ ] Commit: `chore(spec-x-planning-economy): add planning artifacts`

---

## Task 2: agent.md §planning-economy 신설

### 2-1. sources/governance/agent.md
- [ ] `agent.md` 현 §구조 확인 후 적절한 위치 결정 (예: §6/§7 직후)
- [ ] §planning-economy (영어, 5 subsection: N.1 Ceremony Cost / N.2 Thresholds / N.3 Re-Validation / N.4 Re-Adjustment / N.5 Tool Support) 작성
- [ ] install 미러 sync: `.harness-kit/agent/agent.md`
- [ ] 수동 검증: `grep -c "Planning Economy" sources/governance/agent.md .harness-kit/agent/agent.md` → 양쪽 hit / `diff` 0
- [ ] Commit: `docs(spec-x-planning-economy): add §planning-economy to agent.md`

---

## Task 3: sdd cmd_spec_new pre-flight 강화

### 3-1. sources/bin/sdd
- [ ] `_pre_spec_validation()` helper 함수 신설 (plan.md §Component 2 diff 그대로 — phase active + 직전 merged spec 존재 시만 출력)
- [ ] `cmd_spec_new()` 본문 — slug 검증 직후, 디렉토리 생성 직전에 `_pre_spec_validation "$slug"` 호출 추가
- [ ] install 미러 sync: `.harness-kit/bin/sdd`
- [ ] 수동 검증: `grep -c "_pre_spec_validation" sources/bin/sdd .harness-kit/bin/sdd` → 양쪽 hit / `diff` 0
- [ ] 비파괴 검증: `sdd specx new test-noop` (phase 없음 — pre-flight 출력 *없어야 함*) → 정상 동작 → 즉시 `rm -rf specs/spec-x-test-noop && git restore backlog/queue.md` cleanup
- [ ] Commit: `feat(spec-x-planning-economy): add pre-spec validation to sdd cmd_spec_new`

---

## Task 4: ADR-002 작성

### 4-1. docs/decisions/ADR-002-planning-economy.md
- [ ] frontmatter (id: ADR-002 / type: invariant / date / status: accepted) 작성
- [ ] stale 검사 가이드 Note 블록 포함 (spec-17-04 W4 패턴)
- [ ] Context / Decision (3 invariant) / Consequences / Alternatives / Status / Related 작성 (plan.md §Component 3 골격)
- [ ] 수동 검증:
  - `grep -q "^id: ADR-002" docs/decisions/ADR-002-planning-economy.md` PASS
  - `grep -q "^type: invariant" docs/decisions/ADR-002-planning-economy.md` PASS
  - `bash tests/test-drift-stale-adr.sh` → 3/3 PASS (Step 1 의 clean state 가 ADR-002 backtick 경로를 valid 로 인식)
- [ ] Commit: `docs(spec-x-planning-economy): add ADR-002 planning economy & inter-spec re-validation`

---

## Task 5: 회귀 + 통합 검증

- [ ] `bash tests/test-sdd-marker-idempotent.sh` → 3/3 PASS
- [ ] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS (ADR-002 포함)
- [ ] `bash tests/test-phase16-integration.sh` → 3/3 PASS
- [ ] `bash tests/test-phase17-integration.sh` → 3 passed / 1 skipped
- [ ] `bash .harness-kit/bin/sdd status` → 정상 + drift 0
- [ ] `git status --porcelain` → 빈 출력
- [ ] Commit: 없음 (검증만)

---

## Task 6: Ship

- [ ] **walkthrough.md 작성** — 3 묶음 결정 + ADR-002 승격 / 검증 / 발견
- [ ] **pr_description.md 작성** — §planning-economy + sdd pre-flight + ADR-002 sweep 요약 + target: main
- [ ] **Ship Commit**: `docs(spec-x-planning-economy): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-x-planning-economy`
- [ ] **PR 생성**: `gh pr create --base main`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 6 (Pre-flight + 5 실행, Task 5 검증만) |
| **예상 commit 수** | 5 (planning + agent.md + sdd + ADR-002 + ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-17 |
