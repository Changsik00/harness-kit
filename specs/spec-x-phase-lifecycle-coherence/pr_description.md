# docs(spec-x-phase-lifecycle-coherence): Phase lifecycle 의 state·문서·protocol 일관성 회복

## 📋 Summary

### 배경 및 목적
직전 세션에서 Spec PR 리뷰 핑퐁 대응을 위해 `walkthrough.md` 를 living decision log 로 명시 (constitution §5.6 + agent.md §6.3 bullet 7). 그러나 Phase Ship 단계엔 같은 보강 없음.

사용자 보고: **"phase PR 만든 후 새 세션을 열거나 핑퐁 도중 컨텍스트가 끊어지면 에이전트가 다시 PR 을 만들겠다고 함"** — 실제 실패 모드.

원인: `hk-phase-ship.md` step 5 가 PR 생성 직후 `sdd phase done` 호출 → state 즉시 리셋 (`phase=null`) → review 기간 동안 컨텍스트 표류. Spec 패턴 (state 가 PR review 동안 살아있음) 과 비대칭.

### 주요 변경 사항
- [x] **constitution §3.1** Phase Exit Condition 보정 — "User go/no-go + (base mode) Phase PR merge"
- [x] **constitution §6.3** ADR 위치 정의에 escalation 트리거 한 줄 추가
- [x] **agent.md §6.3 bullet 7** 일반화 — review pivot 의 *scope* 에 따라 walkthrough/plan/ADR 분기
- [x] **agent.md §6.3.2** 신설 — Post-Merge Protocol for Phase (mode 분기 + Phase living decision log)
- [x] **hk-phase-ship.md** step 5 mode 분기 (5a base / 5b non-base) — base mode 는 `sdd phase done` 미호출, non-base 는 즉시 호출
- [x] **phase.md** 템플릿에 `📌 결정 기록 (Review)` 섹션 추가 — Phase 레벨 living decision log
- [x] 도그푸딩 sync (`.harness-kit/agent/`, `.claude/commands/`)
- [x] 거버넌스 word 한도 5000w 정확히 달성 (압축 + §6.3.1 의 의미 중복 closing rationale 한 문장 제거)

## 🎯 Key Review Points

1. **Mode 분기 정확성**: `state.json baseBranch != null` ↔ `null` 로 판별. base 모드는 phase PR boundary 가 의미 있는 머지 시점이므로 spec 패턴과 동일하게 deferred. Non-base 는 spec PR 들이 이미 main 에 머지되어 phase 가 사실상 완성 → bookkeeping 만.
2. **§6.3.1 closing rationale 제거의 적절성**: "This protocol ensures context continuity across PR boundaries — the Agent always knows what's next" 는 step 1~4 절차에 이미 내포 → 의미 손실 없음.
3. **Phase 레벨 living doc = `phase.md`**: 별도 파일 신설 X (YAGNI). Spec 의 `walkthrough.md` 와 의미적 대칭, phase.md 가 이미 phase 의 중심 문서.
4. **bullet 7 escalation 표기**: 압축 우선 — 한 줄에 (default → walkthrough / substantial → plan.md / architectural → ADR) 의 분기 표기.

## 🧪 Verification

```bash
bash tests/test-governance-dedup.sh    # 8/8 PASS (정확히 5000w)
bash tests/test-two-tier-loading.sh    # 7/7 PASS
```

### 수동 검증 시나리오
1. base 모드 phase 진행 시: `/hk-phase-ship` → PR 만 생성, state 활성 유지 → 사용자 머지 신호 후 `sdd phase done` 실행
2. 비-base 모드: `/hk-phase-ship` 의 5b 분기 → `sdd phase done` 즉시 실행, 별도 PR 없이 완료 알림
3. PR review 핑퐁 시: phase.md 의 결정 기록 섹션에 누적, `gh pr edit --body-file` 로 PR body 동기화
4. 새 세션 진입 시: state 가 `phase=X, spec=null` → `/hk-align` 이 phase 가 active 임을 보고 → review 중인 phase PR 로 컨텍스트 재구성 가능

## 📦 Files Changed

### 🛠 Modified Files
- `sources/governance/constitution.md` (+2, -1): §3.1 + §6.3 ADR
- `sources/governance/agent.md` (+8, -7): §6.3 bullet 7 일반화 + §6.3.1 trailing rationale 제거 + §6.3.2 신설
- `sources/commands/hk-phase-ship.md` (+20, -8): step 5 mode 분기
- `sources/templates/phase.md` (+10): 📌 결정 기록 (Review) 섹션
- `.harness-kit/agent/{constitution,agent}.md` + templates/phase.md + .claude/commands/hk-phase-ship.md: dogfood sync

### 🆕 New Files
- `specs/spec-x-phase-lifecycle-coherence/{spec,plan,task,walkthrough,pr_description}.md`

## ✅ Definition of Done

- [x] 거버넌스 + slash command + template 갱신
- [x] 도그푸딩 sync
- [x] 회귀 테스트 PASS
- [x] walkthrough.md / pr_description.md ship commit
- [ ] 사용자 검토 요청 알림 완료 (PR 생성 후)

## 🔗 관련 자료

- 직전 세션 commit: `f48cc4c docs(governance): clarify walkthrough as living decision log during PR review` (Spec 레벨)
- 본 PR: Phase 레벨 등가 보강 + state lifecycle 일관성 회복
