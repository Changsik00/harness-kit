# Implementation Plan: spec-09-010

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-010-command-path-fix`
- 시작 지점: `phase-09-install-conflict-defense`

## 🎯 핵심 전략

단순 문자열 치환. `./scripts/harness/bin/sdd` 및 `scripts/harness/bin/sdd` → `.harness-kit/bin/sdd` 일괄 교체.

## 📂 Proposed Changes

#### [MODIFY] `sources/commands/hk-ship.md` — 5곳
#### [MODIFY] `sources/commands/hk-plan-accept.md` — 2곳
#### [MODIFY] `sources/commands/hk-phase-ship.md` — 2곳
#### [MODIFY] `sources/commands/hk-code-review.md` — 1곳
#### [MODIFY] `sources/commands/hk-spec-critique.md` — 1곳
#### [MODIFY] `.claude/commands/hk-*.md` — 도그푸딩 사본 동기화

## 🧪 검증

```bash
grep -r "scripts/harness/bin/sdd" sources/commands/ .claude/commands/
# 결과: 0건이어야 함
```

## 📦 Deliverables 체크

- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
