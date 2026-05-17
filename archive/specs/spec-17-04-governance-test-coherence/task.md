# Task List: spec-17-04

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성 (sdd spec new — marker fix 정상 동작 ✓ 4 번째 실증)
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성 + Pre-flight commit

- [ ] `git checkout -b spec-17-04-governance-test-coherence` (from `phase-17-coherence-fix`)
- [ ] `git add backlog/phase-17.md backlog/queue.md specs/spec-17-04-governance-test-coherence/`
- [ ] Commit: `chore(spec-17-04): add planning artifacts`

---

## Task 2: W1 — §6.4 closure 표 표현 명확화

### 2-1. sources/governance/constitution.md
- [ ] §6.4 "Used in" 열에 *전용/공유* 마크 추가 (5 행)
- [ ] Rules 1 항 표현 부연 (closure 어휘 자체 vs 적합 산출물 구분)
- [ ] install 미러 sync: `.harness-kit/agent/constitution.md`
- [ ] 수동 검증: `grep -E "ADR only|RCA only|\(shared\)" sources/governance/constitution.md .harness-kit/agent/constitution.md` → 각 ≥4 hits
- [ ] Commit: `docs(spec-17-04): clarify §6.4 closure usage per artifact (W1)`

---

## Task 3: W3 — test-drift-stale-adr.sh 회귀 마커 fixture-based 전환

### 3-1. tests/test-drift-stale-adr.sh
- [ ] Step 3 을 ADR-998-valid-paths-fixture 기반으로 전환 (plan.md §W3 diff 그대로)
- [ ] trap cleanup 에 `cleanup_valid` 추가
- [ ] 실행 → 3/3 PASS
- [ ] 회귀 검증: ADR-001 본문에 임의 backtick 경로 추가/제거 후 재실행 → PASS 유지 (수동 시나리오 2)
- [ ] Commit: `test(spec-17-04): make stale-ADR regression marker fixture-based (W3)`

---

## Task 4: W4 — ADR 템플릿에 stale 검사 경로 가이드 추가

### 4-1. sources/templates/adr.md
- [ ] frontmatter 다음, Context 섹션 앞에 Note 블록 3 줄 추가 (plan.md §W4 diff 그대로)
- [ ] install 미러 sync: `.harness-kit/agent/templates/adr.md`
- [ ] 수동 검증: `grep -q "stale ADR 검사 대상" sources/templates/adr.md .harness-kit/agent/templates/adr.md` → 양쪽 hit
- [ ] Commit: `docs(spec-17-04): add stale-path guide to ADR template (W4)`

---

## Task 5: W7 — CLAUDE.md "릴리스 전략" CHANGELOG draft 룰 추가

### 5-1. CLAUDE.md
- [ ] "릴리스 전략" → "룰" 하위 bullet 에 `Phase ship 시 CHANGELOG draft 갱신` 항목 1-2 줄 추가 (plan.md §W7 diff 그대로)
- [ ] 수동 검증: `grep -q "Phase ship 시 CHANGELOG draft" CLAUDE.md`
- [ ] Commit: `docs(spec-17-04): add CHANGELOG draft rule for phase ship (W7)`

---

## Task 6: 회귀 + 통합 검증

- [ ] `bash tests/test-sdd-marker-idempotent.sh` → 3/3 PASS
- [ ] `bash tests/test-drift-stale-adr.sh` → 3/3 PASS
- [ ] `bash tests/test-phase16-integration.sh` → 3/3 PASS
- [ ] `bash .harness-kit/bin/sdd status` → 정상 출력 + drift 0
- [ ] `git status --porcelain` → 빈 출력 (cleanliness 유지)
- [ ] Commit: 없음 (검증만)

---

## Task 7: Ship

- [ ] **walkthrough.md 작성** — 4 항목 결정 + 검증 + 발견
- [ ] **pr_description.md 작성** — W1/W3/W4/W7 cleanup 요약 + 회귀 0 명시
- [ ] **Ship Commit**: `docs(spec-17-04): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-17-04-governance-test-coherence`
- [ ] **PR 생성**: `gh pr create --base phase-17-coherence-fix`
- [ ] **사용자 알림**: PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 7 (Pre-flight + 6 실행, Task 6 검증만) |
| **예상 commit 수** | 6 (planning + W1 + W3 + W4 + W7 + ship) |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-17 |
