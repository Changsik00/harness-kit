# spec-11-005: /hk-archive 슬래시 커맨드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-11-005` |
| **Phase** | `phase-11` |
| **Branch** | `spec-11-005-archive-cmd` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-17 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`sdd archive` 명령은 CLI로 직접 실행해야 한다. Claude Code 사용자는 슬래시 커맨드(`/hk-*`)로 작업하는 것이 자연스럽다.

### 문제점

아카이브 기능은 있지만 슬래시 커맨드가 없어 `/hk-` 에코시스템과 불일치.

### 해결 방안 (요약)

`/hk-archive` 슬래시 커맨드를 추가하여 dry-run 미리보기 → 확인 → 실행하는 대화형 UX 제공.

## 🎯 요구사항

### Functional Requirements

1. `/hk-archive` 슬래시 커맨드: `sdd archive --dry-run`으로 미리보기 → 사용자 확인 → `sdd archive` 실행
2. `--keep=N` 옵션 안내 포함
3. `sources/commands/hk-archive.md` + `.claude/commands/hk-archive.md` 동기화

## 🚫 Out of Scope

- `sdd archive` 기능 변경 (이미 spec-11-003에서 완료)

## ✅ Definition of Done

- [ ] 슬래시 커맨드 파일 생성
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-11-005-archive-cmd` 브랜치 push 완료
