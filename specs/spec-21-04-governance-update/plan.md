# Implementation Plan: spec-21-04

## 📋 Branch Strategy

- 신규 브랜치: `spec-21-04-governance-update`
- 시작 지점: `phase-21-turbo-mode`
- PR 대상: `phase-21-turbo-mode`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] constitution.md / agent.md 는 영문 전용 — Mode D 조항도 영문으로 작성
> - [ ] 기존 Mode A/B/C 섹션 번호 유지 (2.1~2.4 → 2.5 Mode D 추가, 2.4 Decision Tree 내에 Turbo 분기 삽입)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **constitution Mode D 위치** | §2.5 신규 섹션 | Mode A/B/C 번호 변경 없음 |
| **Decision Tree Turbo 분기** | §2.4 에 "Step 0 — Is Turbo active?" 추가 | Turbo 는 게이트가 아닌 mode — 전제 조건으로 먼저 체크 |
| **agent.md Turbo 행** | §3.1 표 맨 끝에 추가 | 기존 행 순서 보존 |
| **/hk-turbo 구조** | 현재 모드 확인 → 전환 안내 → sdd mode 실행 | 간단하고 일관성 있는 slash command |

### 📑 ADR 후보

- [ ] 없음

## 📂 Proposed Changes

### [거버넌스 문서]

#### [MODIFY] `.harness-kit/agent/constitution.md`
§2 Work Modes 끝에 `### 2.5 Mode D — Turbo` 추가:
```
### 2.5 Mode D — Turbo
- Activated by: `sdd mode turbo`
- No Plan Accept gate — edits proceed without ceremony.
- post-commit-verify Stop hook automatically runs intent.test or precheck after each commit.
- Auto-reverts on test failure.
- Use `sdd intent "<goal>" [--test <cmd>]` to declare session-local verification.
- Exit with: `sdd mode governed`
- **NOT for**: Architectural changes, cross-cutting refactors, anything requiring PR review.
```

§2.4 Decision Tree 앞에 Step 0 추가:
```
Step 0 — Is Turbo mode active? (`sdd mode status`)
  YES → Execute freely; post-commit-verify guards quality. Skip Steps 1–2.
  NO  → Step 1
```

#### [MODIFY] `.harness-kit/agent/agent.md`
§3.1 Work Type Behavior Table 에 Turbo 행 추가:
```
| **Turbo** | `sdd mode turbo` + optional `sdd intent "<goal>" --test <cmd>` | Free edits; post-commit-verify auto-runs on Stop | `sdd mode governed` to exit; verify no stray intent.yaml |
```

#### [NEW] `.claude/commands/hk-turbo.md`
`/hk-turbo` 슬래시 커맨드 — 현재 모드 확인 + 전환 안내.

#### [MODIFY] `sources/governance/constitution.md`
동일 변경 미러링.

#### [MODIFY] `sources/governance/agent.md`
동일 변경 미러링.

#### [NEW] `sources/commands/hk-turbo.md`
동일 내용 미러링.

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-governance-update.sh
```

6개 케이스:
- T01: `.harness-kit/agent/constitution.md` 에 "Mode D" 포함
- T02: `.harness-kit/agent/constitution.md` 에 "Turbo" + "sdd mode turbo" 포함
- T03: `.harness-kit/agent/agent.md` 에 "Turbo" 행 포함
- T04: `.claude/commands/hk-turbo.md` 존재
- T05: `sources/governance/constitution.md` 에 Mode D 포함
- T06: `sources/commands/hk-turbo.md` 존재

## 🔁 Rollback Plan

- git revert 로 문서 변경 되돌리기
- 기능 코드 변경 없음 — Turbo 모드 기능 자체는 영향 없음

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
