# Implementation Plan: spec-x-phase-lifecycle-coherence

## 📋 Branch Strategy
- 신규 브랜치: `spec-x-phase-lifecycle-coherence`
- 시작 지점: `main`

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **Mode 분기 정확성**: phase base branch mode 의 detection 기준은 `state.json` 의 `baseBranch` 필드 (현재 `null` 이면 non-base, `phase-N-{slug}` 이면 base). hk-phase-ship.md 의 분기 조건도 이 기준.
> - [ ] **post-merge 신호 인식**: 사용자의 phase 머지 알림은 자유 형식 ("phase 머지 했어", "phase merged" 등). agent.md 의 §6.3.1 spec post-merge 와 동일 패턴.

> [!WARNING]
> - [ ] **In-flight phase 영향 없음**: 현재 active phase 없음 (`sdd status` 확인 완료). 본 변경은 다음 phase 부터 적용. 진행 중 phase 가 있다면 별도 마이그레이션 필요했을 것.

## 🎯 핵심 변경

### 1. `sources/governance/constitution.md` (영어)

**§3.1 Phase Exit Condition 보정:**
```diff
- - **Exit Condition**: All Specs merged, phase-level integration tests PASS, and User final approval via `/hk-phase-ship`.
+ - **Exit Condition**: All Specs merged, phase-level integration tests PASS, User final approval via `/hk-phase-ship`, and (when phase base branch mode) Phase PR merged into main.
```

**§6.3 ADR 위치 설명에 트리거 한 줄 추가:**
```diff
- ADR: `docs/decisions/ADR-{NNN}-{slug}.md`
+ ADR: `docs/decisions/ADR-{NNN}-{slug}.md` — created when a decision affects architecture, crosses Spec/Phase boundaries, or has rationale that must outlive the current Phase. Routine decisions stay in `walkthrough.md` / `plan.md` / `phase.md`.
```

### 2. `sources/governance/agent.md` (영어)

**§6.3 bullet 7 일반화 (직전 추가본을 확장):**
```diff
- 7. **Living document during review**: After Ship, `walkthrough.md` remains the *living decision log* — not frozen. If PR review feedback changes scope, surfaces new constraints, or pivots the approach, the Agent MUST update `walkthrough.md` (decision rows / 사용자 협의 / 발견 사항) and push the update before merge. ...
+ 7. **Living document during review**: After Ship, the SPEC artifacts remain living. PR review pivots are recorded based on *scope of change*:
+    - Decisions / discoveries / agreed direction → `walkthrough.md` (primary, default)
+    - Approach or design substantially changes (rewriting half of plan) → also update `plan.md`
+    - Architectural / cross-cutting / long-lived rationale → add a new ADR under `docs/decisions/` and reference it from `spec.md` / `phase.md`
+    Push updates before merge. Frozen-at-Ship artifacts lose the *why* of subsequent changes.
```

**새 §6.3.2 Post-Merge Protocol for Phase:**
```
### 6.3.2 Post-Merge Protocol for Phase

When the User signals that the Phase PR has been merged (base branch mode only — e.g., "phase merged", "phase 머지", "phase 병합"):

1. Run `bash .harness-kit/bin/sdd phase done` — resets state and moves phase to done section in queue.md.
2. Run `bash .harness-kit/bin/sdd status` to confirm idle.
3. Suggest next step: another phase candidate from `backlog/queue.md` 대기 Phase, idle, or `/hk-phase-review` for retrospective.
4. Wait for User decision.

For non-base mode, `sdd phase done` is invoked at /hk-phase-ship time directly (no PR exists). This protocol does not apply.

**Phase PR review 중 결정 기록**: `phase.md` 의 `📌 결정 기록 (Review)` 섹션이 Phase 레벨 living decision log. PR review 핑퐁의 결정·합의·발견은 여기 누적. PR body 도 갱신이 필요하면 `gh pr edit --body-file` 로 동기화.
```

### 3. `sources/commands/hk-phase-ship.md` (한국어)

**Step 5 mode 분기:**
```diff
 ## 5. Phase PR Creation (승인 후)

 사용자 승인을 받은 후:

-1. **PR 본문 작성**: `.harness-kit/agent/templates/phase-ship.md` 템플릿을 읽고 Phase PR 본문을 작성합니다.
-
-2. **PR 생성**:
-```bash
-# phase base branch 모드
-gh pr create --base main --head {phase-branch} --title "{title}" --body "{body}"
-
-# 일반 모드 (base branch 없는 경우)
-# 이미 main에 직접 merge되는 구조이므로 별도 PR 불필요할 수 있음 — 사용자에게 확인
-```
-
-3. **State 업데이트**:
-```bash
-./.harness-kit/bin/sdd phase done
-```
-
-4. **사용자 알림**: PR URL 보고 + phase 완료 축하 메시지
+state.json 의 `baseBranch` 필드로 모드 판별:
+
+### 5a. Phase base branch 모드 (`baseBranch != null`)
+
+1. **PR 본문 작성**: `.harness-kit/agent/templates/phase-ship.md` 템플릿으로 작성.
+2. **PR 생성**:
+```bash
+gh pr create --base main --head {phase-branch} --title "{title}" --body "{body}"
+```
+3. **PR URL 보고** + 사용자에게 머지 후 알려달라고 안내.
+4. **`sdd phase done` 호출하지 않음** — Post-Merge Protocol (agent.md §6.3.2) 에서 사용자 머지 신호 시 실행.
+
+### 5b. 일반 모드 (`baseBranch == null`)
+
+이미 spec PR 들이 main 에 직접 머지되어 phase 가 사실상 완성됨. PR 불필요.
+
+1. **`sdd phase done` 즉시 실행** — bookkeeping 만 수행.
+```bash
+./.harness-kit/bin/sdd phase done
+```
+2. **완료 알림** + 다음 phase 또는 idle 안내.
```

### 4. `sources/templates/phase.md` (한국어)

`📌 결정 기록 (Review)` 섹션 추가 (Phase 레벨 living decision log).

위치: `🎯 성공 기준` 다음, `🧪 통합 테스트 시나리오` 앞.

```markdown
## 📌 결정 기록 (Review)

> Phase PR review 중 발생한 결정·합의·발견을 누적합니다. Spec walkthrough 의 결정 기록과 동일 패턴.

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| <이슈 1> | A 또는 B | A | <이유> |
```

### 5. 도그푸딩 sync

- `cp sources/governance/{constitution,agent}.md .harness-kit/agent/`
- `cp sources/commands/hk-phase-ship.md .claude/commands/hk-phase-ship.md`
- `cp sources/templates/phase.md .harness-kit/agent/templates/phase.md`

## 📂 Proposed Changes

| 파일 | 변경 |
|---|---|
| `sources/governance/constitution.md` | §3.1 exit + §6.3 ADR 트리거 |
| `sources/governance/agent.md` | §6.3 bullet 7 확장 + §6.3.2 신설 |
| `sources/commands/hk-phase-ship.md` | step 5 mode 분기 |
| `sources/templates/phase.md` | 결정 기록 섹션 추가 |
| `.harness-kit/agent/constitution.md` | sync |
| `.harness-kit/agent/agent.md` | sync |
| `.harness-kit/agent/templates/phase.md` | sync |
| `.claude/commands/hk-phase-ship.md` | sync |

## 🧪 검증 계획

```bash
bash tests/test-governance-dedup.sh    # 회귀
bash tests/test-two-tier-loading.sh    # 회귀
```

`hk-phase-ship.md` 자체엔 테스트 없음. 변경은 분기 로직 + 텍스트 → 수동 검증 (다음 실제 phase ship 시).

### 수동 검증 시나리오
1. `state.json baseBranch=null` 상태에서 `/hk-phase-ship` 호출 → step 5b (즉시 done) 분기 확인
2. `state.json baseBranch="phase-N-foo"` 상태에서 `/hk-phase-ship` 호출 → step 5a (PR 만 생성) 분기 확인
3. (장기) 다음 실제 phase 머지 후 사용자가 "phase 머지" 신호 → 에이전트가 `§6.3.2` 따라 `sdd phase done` 호출

## 🔁 Rollback
- 단일 PR git revert.

## 📦 Deliverables
- [ ] task.md
- [ ] Plan Accept
- [ ] 모든 task 완료
- [ ] walkthrough / pr_description ship
