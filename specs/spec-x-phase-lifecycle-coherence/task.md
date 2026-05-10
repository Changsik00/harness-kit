# Task List: spec-x-phase-lifecycle-coherence

## Pre-flight
- [x] Spec ID 확정 + 디렉토리 생성
- [x] spec.md
- [x] plan.md
- [x] task.md
- [ ] Plan Accept

---

## Task 1: 브랜치 생성
- [x] `git checkout -b spec-x-phase-lifecycle-coherence`

## Task 2: 거버넌스 갱신 (sources/governance)
- [x] §3.1 / §6.3 ADR / §6.3 bullet 7 / §6.3.2
- [x] Commit: `docs(spec-x-phase-lifecycle-coherence): governance — phase lifecycle, ADR escalation, review pivot`

## Task 3: slash command 갱신
- [x] `hk-phase-ship.md` step 5 mode 분기
- [x] Commit: `docs(spec-x-phase-lifecycle-coherence): hk-phase-ship — split step 5 by base branch mode`

## Task 4: 템플릿 갱신
- [x] `phase.md` 결정 기록 섹션 추가
- [x] Commit: `docs(spec-x-phase-lifecycle-coherence): phase template — add review decision log section`

## Task 5: 도그푸딩 sync + 압축
- [x] sync 4 files
- [x] 거버넌스 word 한도 5000w 달성 (§6.3.1 trailing rationale 제거 + 압축)
- [x] governance-dedup 8/8, two-tier-loading 7/7 PASS
- [x] Commit: `chore(spec-x-phase-lifecycle-coherence): sync installed governance/templates/commands and compress to fit governance bloat limit`

## Task 6: Ship
- [x] walkthrough.md / pr_description.md
- [ ] Commit: `docs(spec-x-phase-lifecycle-coherence): ship walkthrough and pr description`
- [ ] Push + PR

---

| 항목 | 값 |
|---|---|
| 총 Task | 6 |
| 예상 commit | 5 |
| 단계 | Planning |
