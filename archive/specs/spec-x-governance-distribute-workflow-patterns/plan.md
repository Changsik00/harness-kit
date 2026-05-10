# Implementation Plan: spec-x-governance-distribute-workflow-patterns

## 📋 Branch Strategy
- 신규 브랜치: `spec-x-governance-distribute-workflow-patterns`
- 시작 지점: `main`

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **한도 6000 의 정당성**: 5000 → 6000 (20% 상향). 현재 5000 가득 차서 generic-useful 패턴 거버넌스화가 막힘. 한도가 본질 (가이드 배포) 을 막는 상태 → 합당한 헤드룸 확보. 6500/7000 같은 이상 상향은 안 함.
> - [ ] **메모리 retire 시점**: PR 머지 후 사용자 직접 또는 별도 단계. 본 PR 에선 거버넌스화만.

> [!WARNING]
> - [ ] **version 0.8.0 의미**: 5 PR + 본 PR = minor bump. major (0.x.x → 1.0.0) 는 안 함. patch (0.7.0 → 0.7.1) 는 변경 양 대비 작음.

## 🎯 핵심 변경

### 1. `tests/test-governance-dedup.sh` LIMIT 상향

```diff
- # 합계 5000w 이하 유지 (비대화 방지 상한선)
- LIMIT=5000
+ # 합계 6000w 이하 유지 (비대화 방지 상한선)
+ # 2026-05-10: 5000 → 6000 상향. generic-useful 워크플로우 패턴 (model transparency,
+ # parallel-by-default, archive timing) 을 §6.7 로 거버넌스화하면서 한도가 *본질
+ # (가이드 배포) 을 막지 않도록* 헤드룸 확보. 무절제 상향은 금지 — 6500+ 은 별도 정당화 필요.
+ LIMIT=6000
```

### 2. `sources/governance/agent.md` §6.7 Workflow Patterns 신설

위치: `### 6.6 Model Allocation Strategy` 다음, `## 7. Deviation & Hard Stop` 앞.

```markdown
### 6.7 Workflow Patterns

Generic agent behavior patterns that improve UX, latency, and cost without per-task tuning.

**Model transparency**: Announce session model once at session start (e.g., `[Opus 4.7 — main]`). On sub-agent dispatch, declare model and role (e.g., `Sonnet sub-agent, result-only, background`). Repeat only on model change — silence is fine when stable.

**Parallel by default**: Independent operations (regression suites, file syncs, multi-section drafting) MUST be dispatched in a single message with multiple tool calls. Sequential processing is the wrong default when tasks have no dependency.

**Background for long-running**: Operations 5+ seconds (test suites, builds, install verification, `gh pr create` polling) SHOULD use `run_in_background: true`. Continue with other work and resume on completion notification.

**Sub-agent dispatch threshold**: Single short commands (`git commit`, single `cp`) stay in main thread — dispatch overhead exceeds savings. Only dispatch when work is bundled (3+ commands or multi-step routine) or genuinely needs independent context (review, critique).

**Archive timing**: `sdd archive` is an intentional checkpoint operation, not mid-flow housekeeping. Run when working tree is clean (between Specs, post-merge cleanup, accumulation review). Mid-Spec archive forces drift handling that defeats the cleanup intent.

**Version + CHANGELOG paired update**: When `version.json` changes, `CHANGELOG.md` MUST gain a corresponding entry in the same commit. Conversely, never bump version without summarizing changes since the last release.
```

### 3. `version.json`

```diff
- {"version": "0.7.0"}
+ {"version": "0.8.0"}
```

### 4. `CHANGELOG.md` `## [0.8.0]` entry

직전 세션 (2026-05-09 ~ 2026-05-10) 의 변경:

```markdown
## [0.8.0] — 2026-05-10

### Added
- `sdd archive` 가 완료된 spec-x 디렉토리도 정리 (queue.md done 섹션 등록 기준) (#102)
- `agent.md §6.3.2` Post-Merge Protocol for Phase 신설 — base mode/non-base mode 분기 + Phase living decision log (#105)
- `agent.md §6.7` Workflow Patterns 신설 — model transparency, parallel-by-default, background, archive timing (THIS)
- `phase.md` 템플릿 `📌 결정 기록 (Review)` 섹션 — Phase 레벨 living decision log (#105)
- `tests/test-sdd-dir-archive.sh` Check 7~9 — spec-x archive / dry-run / drift 보호 (#102, #103)
- `tests/test-git-precommit-hook.sh` Test 12~13 — no-active-spec bypass / legacy state (#104)

### Fixed
- `sdd archive` 의 `git add -A` 가 무관한 워킹트리 변경을 흡수 — `git mv` 가 이미 stage 했으므로 add 라인 제거 (#103)
- pre-commit / check-plan-accept hook 이 활성 SPEC 없을 때도 production commit 차단 — `state.spec == null` 시 통과 추가 (#104)
- `install.sh` self-host 모드에서 `# harness-kit` 헤더 잡음 추가 — self-host guard 뒤로 이동 + 한도 헤더 skip (FF 85d2462)
- `/hk-phase-ship` 의 `sdd phase done` 호출 시점 — PR 생성 → 사용자 phase 머지 신호 후로 이동 (base mode) (#105)

### Changed
- `constitution §3.1` Phase Exit Condition — `(base mode) Phase PR merge` 추가 (#105)
- `constitution §5.6` Opinion Divergence — 결정 기록 대상에 `walkthrough.md` 추가 + PR review 분기 명시 (FF f48cc4c)
- `constitution §6.3` ADR — escalation 트리거 한 줄 (architectural / cross-Spec / long-lived) (#105)
- `agent.md §6.3 bullet 7` — Living artifacts during review, scope 별 분기 (walkthrough/plan.md/ADR) (FF f48cc4c, #105)
- 거버넌스 word 한도 5000 → 6000 — generic-useful workflow 패턴 거버넌스화 헤드룸 (THIS)
```

### 5. 도그푸딩 sync

- `cp sources/governance/agent.md .harness-kit/agent/agent.md`

### 5. 메모리 retire (본 PR 외 후속)

본 PR 머지 후 사용자 메모리 디렉토리에서:
- `feedback_archive_clean_timing.md`
- `feedback_model_transparency.md`
- `feedback_parallel_default.md`
- `MEMORY.md` 의 해당 엔트리 라인 3개 제거

→ 별도 단계 (PR 안 함).

## 📂 Proposed Changes

| 파일 | 변경 |
|---|---|
| `tests/test-governance-dedup.sh` | LIMIT 5000 → 6000 + 코멘트 |
| `sources/governance/agent.md` | §6.7 Workflow Patterns 신설 |
| `.harness-kit/agent/agent.md` | sync |
| `version.json` | 0.7.0 → 0.8.0 |
| `CHANGELOG.md` | `## [0.8.0]` entry 추가 |

## 🧪 검증 계획

```bash
bash tests/test-governance-dedup.sh    # 새 한도 6000 통과 확인
bash tests/test-two-tier-loading.sh    # 회귀
bash tests/test-version-bump.sh        # 버전 형식 검증
```

### 수동 검증
1. `cat version.json` → 0.8.0 확인
2. `agent.md §6.7` 섹션이 §6.6 다음, §7 앞에 존재 확인
3. governance-dedup 출력의 word count: 6000 이하

## 🔁 Rollback
- 단일 PR git revert.

## 📦 Deliverables
- [ ] task.md
- [ ] Plan Accept
- [ ] 모든 task 완료
- [ ] walkthrough / pr_description ship
