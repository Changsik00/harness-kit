# Implementation Plan: spec-09-013

## 📋 Branch Strategy

- 신규 브랜치: `spec-09-013-auto-ship`
- 시작 지점: `phase-09-install-conflict-defense`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] Plan Accept의 위임 범위가 push+PR까지 확장됨 — "PR 생성은 사용자가 확인해야 한다"는 기존 원칙이 변경됨
> - [ ] 이 변경 후에도 테스트 실패/archive 실패 시 멈추는 안전장치는 유지됨

## 🎯 핵심 전략 (Core Strategy)

### 변경 전 vs 변경 후

```
변경 전 (현재)                         변경 후
─────────────────                     ─────────────────
task 완료 → 자동 진행                  task 완료 → 자동 진행
  ...                                   ...
마지막 task 완료                       마지막 task 완료
  ↓                                     ↓
/hk-ship 호출                         archive + push + PR 자동 진행
  ↓                                     ↓
archive ✅                             이상 없으면 PR URL 보고
  ↓                                     ↓
🔴 "push 할까요?" 대기                 사용자 머지 대기
  ↓ (사용자: Y)
push ✅
  ↓
🔴 "PR 생성할까요?" 대기
  ↓ (사용자: ok)
PR 생성 ✅
  ↓
PR URL 보고
  ↓
사용자 머지 대기
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **위임 범위** | Plan Accept = task + ship 모두 위임 | push/PR은 판단이 아닌 기계적 단계 |
| **안전장치** | 테스트/archive 실패 시만 멈춤 | 의미 있는 검증만 게이트로 유지 |
| **Phase Ship** | 변경 없음 | 릴리스 게이트는 별도 승인 필요 |

## 📂 Proposed Changes

### 거버넌스 문서

#### [MODIFY] `sources/governance/agent.md`

**§6.1 Strict Loop Rule 항목 7** 변경:
```
변경 전:
  The Ship task (push/PR) **always** requires explicit user confirmation.

변경 후:
  The Ship task (archive → push → PR) proceeds automatically if all checks pass.
  The Agent reports the PR URL and waits for User merge.
  If any check fails (test, archive, push), the Agent MUST stop and report.
```

**§6.3 Commit & Ship Enforcement** Walkthrough & Description Protocol 항목 6 변경:
```
변경 전:
  6. **Ship**: Notify the User. The Agent MAY create a PR via `/hk-pr-gh` or `/hk-pr-bb` with User confirmation.

변경 후:
  6. **Ship**: Push and create PR automatically. Report the PR URL to the User.
```

#### [MODIFY] `sources/governance/constitution.md`

**§10.2 Commit Protocol** PR Creation 변경:
```
변경 전:
  The Agent MAY create a PR ... but MUST obtain explicit User confirmation before executing.

변경 후:
  Once Plan is accepted (→ §7.1), the Agent is authorized to push the feature branch
  and create a PR as part of the Ship task. Explicit per-action confirmation is not required.
  The Agent MUST archive walkthrough/pr_description before PR creation.
```

**§7.1 Delegation Rule** 보강:
```
추가:
  - Push the feature branch and create a PR upon successful completion of all tasks.
```

### 슬래시 커맨드

#### [MODIFY] `sources/commands/hk-ship.md`

§4 "Push 확인 (사용자 승인 필요)" 섹션:
- 확인 블록(push 할까요? [Y/n])을 **정보 표시 블록**으로 변경 — 보고만 하고 자동 진행
- `--no-confirm` 플래그 관련 분기 제거 (기본 동작이 자동)

§5 "PR 생성" 섹션:
- "사용자 확인 후 실행" → push 성공 시 자동 실행
- host 감지 → `gh pr create` 또는 수동 안내

### 도그푸딩 동기화

#### [MODIFY] `.harness-kit/agent/agent.md`, `.harness-kit/agent/constitution.md`, `.claude/commands/hk-ship.md`

sources 원본과 동기화.

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오
1. agent.md에서 "always requires explicit user confirmation" 문구가 제거되었는지 확인
2. constitution.md에서 PR 생성의 "MUST obtain explicit User confirmation" 문구가 갱신되었는지 확인
3. hk-ship.md에서 push 확인 블록이 정보 표시로 변경되었는지 확인

## 🔁 Rollback Plan

- 거버넌스 문서 `git revert`로 이전 규칙 복원
- 도그푸딩 사본은 `install.sh`로 재동기화

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
