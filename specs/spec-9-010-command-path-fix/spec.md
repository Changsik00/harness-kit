# spec-9-010: 슬래시 커맨드 경로 일괄 수정

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-9-010` |
| **Phase** | `phase-9` |
| **Branch** | `spec-9-010-command-path-fix` |
| **상태** | Planning |
| **타입** | Fix |
| **Integration Test Required** | no |
| **작성일** | 2026-04-15 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

spec-9-001에서 디렉토리 레이아웃을 `.harness-kit/`으로 변경했으나, `.claude/commands/hk-*.md`와 `sources/commands/hk-*.md` 슬래시 커맨드 내부의 `scripts/harness/bin/sdd` 경로가 갱신되지 않았다.

### 문제점

- 슬래시 커맨드 실행 시 `scripts/harness/bin/sdd: No such file or directory` 에러 발생
- `/hk-align`, `/hk-ship`, `/hk-plan-accept` 등 모든 sdd 참조 커맨드가 영향받음

### 해결 방안 (요약)

`scripts/harness/bin/sdd` → `.harness-kit/bin/sdd` 일괄 치환. `sources/commands/` (SSOT)와 `.claude/commands/` (도그푸딩 사본) 모두 수정.

## 🎯 요구사항

### Functional Requirements

1. `sources/commands/hk-*.md` 내 `scripts/harness/bin/sdd` → `.harness-kit/bin/sdd` 치환
2. `.claude/commands/hk-*.md` 내 동일 치환 (도그푸딩 사본)
3. `hk-cleanup.md`의 `diff scripts/harness/bin/sdd sources/bin/sdd` → `.harness-kit/bin/sdd` 경로로 수정

## 🚫 Out of Scope

- 커맨드 내용 변경 (경로 치환만)

## ✅ Definition of Done

- [ ] grep으로 `scripts/harness/bin/sdd` 잔재 0건 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-9-010-command-path-fix` 브랜치 push 완료
