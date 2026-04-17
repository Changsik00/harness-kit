# Implementation Plan: spec-06-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-06-01-cmd-prefix-rename`
- 시작 지점: `main`
- PR Target: `main`

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 변경 대상 9개 커맨드 파일명 확인

## 🎯 핵심 전략

### 변경 매핑

| 현재 | 변경 후 |
|---|---|
| `align.md` | `hk-align.md` |
| `bb-pr.md` | `hk-bb-pr.md` |
| `code-review.md` | `hk-code-review.md` |
| `gh-pr.md` | `hk-gh-pr.md` |
| `handoff.md` | `hk-handoff.md` |
| `plan-accept.md` | `hk-plan-accept.md` |
| `spec-new.md` | `hk-spec-new.md` |
| `spec-review.md` | `hk-spec-review.md` |
| `spec-status.md` | `hk-spec-status.md` |

### 참조 갱신 대상

| 파일 | 참조 커맨드 |
|---|---|
| `sources/governance/align.md` | `/align`, `/plan-accept` |
| `sources/governance/constitution.md` | `/gh-pr`, `/bb-pr` |
| `sources/governance/agent.md` | `/align`, `/plan-accept`, `/gh-pr`, `/bb-pr` |
| `sources/claude-fragments/CLAUDE.md.fragment` | `/align` |
| `install.sh` | `/align` |
| `agent/align.md` | `/align`, `/plan-accept` |
| `agent/constitution.md` | `/gh-pr`, `/bb-pr` |
| `agent/agent.md` | `/align`, `/plan-accept`, `/gh-pr`, `/bb-pr` |
| `CLAUDE.md` | `/align` |

## 📂 Proposed Changes

### Task 1: 커맨드 파일명 변경
- `sources/commands/` 내 9개 파일 rename
- `.claude/commands/` 내 9개 파일 rename (도그푸딩)

### Task 2: 거버넌스 참조 갱신
- `sources/governance/` 3개 파일 내 참조 갱신
- `agent/` 3개 파일 내 참조 갱신 (도그푸딩)
- `sources/claude-fragments/CLAUDE.md.fragment` 참조 갱신
- `install.sh` 참조 갱신
- `CLAUDE.md` 참조 갱신

## 🧪 검증 계획

```bash
# 구 이름으로 파일이 남아있지 않은지 확인
ls sources/commands/ | grep -v "^hk-"
# 참조 검색 (구 이름이 남아있지 않은지)
grep -r "/align\b" sources/governance/ agent/ CLAUDE.md install.sh | grep -v "hk-align"
```

## 🔁 Rollback Plan

- git revert로 원복 가능 (파일명 변경 + 참조 갱신이 전부)

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
