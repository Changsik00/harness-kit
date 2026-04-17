# Implementation Plan: spec-11-005

## 📋 Branch Strategy

- 신규 브랜치: `spec-11-005-archive-cmd`
- 시작 지점: `main`

## 🎯 핵심 전략 (Core Strategy)

기존 `/hk-ship` 커맨드 패턴을 따라 `/hk-archive` 생성. 단순 래퍼.

## 📂 Proposed Changes

#### [NEW] `sources/commands/hk-archive.md`
dry-run → 확인 → 실행 흐름의 슬래시 커맨드

#### [NEW] `.claude/commands/hk-archive.md`
도그푸딩 동기화

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] 모든 task 완료
- [ ] walkthrough.md / pr_description.md ship commit
