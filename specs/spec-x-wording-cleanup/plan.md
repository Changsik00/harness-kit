# Implementation Plan: spec-x-wording-cleanup

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-wording-cleanup`
- 시작 지점: `main`
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] 통일 기준(spec.md §통일 기준 표) 동의 여부 — 기준이 확정되어야 전체 수정 방향이 결정됨

> [!WARNING]
> - [ ] 기능 변경 없음 (문서만 수정). Breaking change 없음.

## 🎯 핵심 전략

### 수정 방향

문서-only 변경이므로 TDD 불필요. 파일 그룹별로 하나의 commit 을 생성합니다.

### 파일 그룹 분류

| Task | 대상 파일 | 주요 변경 |
|:---:|:---|:---|
| 1 | `hk-gh-pr`, `hk-bb-pr`, `hk-handoff` | 긍정/거부 규칙 → constitution 참조, handoff §5 중복 코드 제거 |
| 2 | `hk-plan-accept` | Strict Loop 8단계 → agent.md §6.1 참조 한 줄로 |
| 3 | `hk-code-review` | `sub-agent` → `서브에이전트`, `model: "opus"` 추가 |
| 4 | `hk-spec-new` | slug 인자 누락 처리 추가 |
| 5 | `hk-spec-critique`, `hk-spec-status`, `hk-align` | `active spec/phase` → `활성 spec/phase`, 언어 혼용 정리 |
| 6 | `constitution.md` | §4.2 제목 변경 |

> `sources/` 와 `.claude/commands/` 는 항상 쌍으로 수정 (내용 동기화)

## 📂 Proposed Changes

### Task 1 — PR 커맨드 + Handoff

#### [MODIFY] `sources/commands/hk-gh-pr.md` + `.claude/commands/hk-gh-pr.md`
- §4 "PR 확인" 내 긍정/거부 예시 목록 제거 → `긍정/거부 규칙 → constitution §4.2 참조` 한 줄로 대체
- `본 명령은` → `이 명령은`

#### [MODIFY] `sources/commands/hk-bb-pr.md` + `.claude/commands/hk-bb-pr.md`
- 동일 (긍정/거부 예시 목록 → 참조 한 줄)
- `본 명령은` → `이 명령은`

#### [MODIFY] `sources/commands/hk-handoff.md` + `.claude/commands/hk-handoff.md`
- §5-A: `/gh-pr` 요지 코드 블록(awk) 제거 → "`/hk-gh-pr` 슬래시 커맨드의 절차를 따릅니다." 한 줄
- §4 긍정/거부 예시 목록 → constitution 참조
- `본 명령으로` → 제거 (도입 문장 재작성)

### Task 2 — Plan Accept

#### [MODIFY] `sources/commands/hk-plan-accept.md` + `.claude/commands/hk-plan-accept.md`
- §3 Strict Loop 8단계 → `이제 Strict Loop 모드로 진입합니다 (→ agent.md §6.1).` 한 줄
- `이 명령은 신중하게 사용하세요` 표현 — 유지 (맥락상 적절)

### Task 3 — Code Review

#### [MODIFY] `sources/commands/hk-code-review.md` + `.claude/commands/hk-code-review.md`
- `sub-agent 에게 전달할 프롬프트` → `서브에이전트에게 전달할 프롬프트`
- Agent tool 호출 부분에 `model: "opus"` 추가 (`hk-spec-critique.md` 와 동일하게)

### Task 4 — Spec New

#### [MODIFY] `sources/commands/hk-spec-new.md` + `.claude/commands/hk-spec-new.md`
- §1 사전 점검에 slug 인자 누락 처리 추가:
  ```
  - 인자($1)가 없으면: "slug 인자가 필요합니다. 예: /hk-spec-new <slug>" 안내 후 중단
  ```

### Task 5 — 언어 혼용 정리

#### [MODIFY] `sources/commands/hk-spec-critique.md` + `.claude/commands/hk-spec-critique.md`
- `active spec이 없으면` → `활성 spec이 없으면`

#### [MODIFY] `sources/commands/hk-spec-status.md` + `.claude/commands/hk-spec-status.md`
- 언어 혼용 항목이 있다면 정리

#### [MODIFY] `sources/commands/hk-align.md` + `.claude/commands/hk-align.md`
(`.claude/commands/hk-align.md` 는 skill로 관리되므로 sources 만)
- `active phase` → `활성 phase`, `active spec` → `활성 spec`

### Task 6 — Constitution

#### [MODIFY] `sources/governance/constitution.md` + `agent/constitution.md`
- §4.2 제목: `Plan Rules` → `Plan Accept & Critique 인식`

## 🧪 검증 계획

### 수동 검증 시나리오
1. 각 파일의 변경 전후 내용을 `git diff` 로 확인
2. `sources/` 와 `.claude/commands/` 의 동일 파일 내용이 일치하는지 확인
3. constitution 참조가 정확한 절 번호를 가리키는지 확인

## 🔁 Rollback Plan

- `git revert` 또는 `git reset --hard` 로 되돌림
- 기능 변경이 없으므로 실제 시스템 영향 없음

## 📦 Deliverables 체크

- [x] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
