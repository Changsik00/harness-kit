# Task List: spec-x-governance-distribute-workflow-patterns

## Pre-flight
- [x] Spec ID 확정 + 디렉토리 생성
- [x] spec.md
- [x] plan.md
- [x] task.md
- [ ] Plan Accept

---

## Task 1: 브랜치 생성
- [x] `git checkout -b spec-x-governance-distribute-workflow-patterns`

## Task 2: LIMIT 상향 + §6.7 + version bump + CHANGELOG + README
- [x] LIMIT 5000 → 6000 + 코멘트
- [x] §6.7 Workflow Patterns 신설 (5 패턴)
- [x] version.json 0.7.0 → 0.8.0
- [x] CHANGELOG.md [0.8.0] entry
- [x] README.md example 0.6.3 → 0.8.0 (test enforce)
- [x] Commit: `docs(spec-x-governance-distribute-workflow-patterns): governance §6.7 + version 0.8.0 + CHANGELOG + word limit 6000`

## Task 3: 도그푸딩 sync + 회귀
- [x] `.harness-kit/agent/agent.md` sync
- [x] `.harness-kit/installed.json` kitVersion sync
- [x] governance-dedup 8/8 PASS
- [x] two-tier-loading 7/7 PASS
- [x] version-bump Checks 1-5 분리 검증 PASS
- [x] Commit: `chore(spec-x-governance-distribute-workflow-patterns): sync installed agent.md and installed.json kitVersion`

## Task 4: Ship
- [x] walkthrough.md / pr_description.md
- [ ] Commit: `docs(spec-x-governance-distribute-workflow-patterns): ship walkthrough and pr description`
- [ ] Push + PR

---

| 항목 | 값 |
|---|---|
| 총 Task | 4 |
| 예상 commit | 3 |
| 단계 | Planning |
