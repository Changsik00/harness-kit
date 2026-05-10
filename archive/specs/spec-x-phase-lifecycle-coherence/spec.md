# spec-x-phase-lifecycle-coherence: Phase lifecycle 의 state·문서·protocol 일관성 회복

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-phase-lifecycle-coherence` |
| **Phase** | (없음 — Solo Spec) |
| **Branch** | `spec-x-phase-lifecycle-coherence` |
| **상태** | Planning |
| **타입** | Fix (governance + slash command + template) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-10 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황
직전 세션에서 `walkthrough.md` 가 living decision log 임을 명시 (constitution §5.6, agent.md §6.3 bullet 7). Spec 레벨 protocol 보강. 그러나 **Phase 레벨에는 같은 보강이 없음** — Phase Ship 후 PR review 핑퐁이 발생하면 컨텍스트와 문서 갱신이 표류.

### 사용자가 실제 겪은 실패 모드
"phase pr 을 요청한 상태에서 새 세션을 열거나 핑퐁 도중 컨텍스트가 끊어지면 에이전트가 다시 PR 을 만들겠다고 함."

### 정밀 진단 (5 결함 + 7 흐름 갭)

**정책 충돌·결함**
1. `constitution §3.1` Phase Exit Condition 이 "User go/no-go" 만 명시. Phase PR 머지 누락.
2. `hk-phase-ship.md` step 5.3 의 `sdd phase done` 호출이 PR 생성 시점에 실행 → state 즉시 리셋 (`phase=null`) → review 중 컨텍스트 손실.
3. `agent.md §6.3 bullet 7` (직전 추가) 이 walkthrough 만 명시. plan.md / ADR escalation 분기 없음.
4. ADR 발생 트리거 기준이 거버넌스에 없음 (위치만 명시).
5. Phase 레벨 living doc 디스크 산출물이 없음. `phase-ship.md` 는 템플릿 → PR body 1회 렌더, 디스크에 안 남음.

**실사용 흐름 갭**
- α: Phase PR review 중 success criterion 수정 시 갱신 위치 미정
- β: review 중 "Phase 절반 미루자" 같은 분할 요청 처리 protocol 없음
- γ: Spec PR review 가 plan.md 절반 뒤엎는 변경 — bullet 7 이 plan.md 미언급
- δ: 다중 디바이스 — state 리셋 때문에 디바이스 B 가 상황 모름
- ε: `/hk-phase-ship` 도중 fail → fix 후 재시도 protocol 미정 (out of scope, 현재는 사용자 판단)
- η: review 중 architectural decision → ADR escalation 기준 없음
- (ζ 회고 timing 은 사용자 확인으로 거버넌스 대상 아님 — 드롭)

### 해결 방안 (요약)
**P0 + P1 + P2 단일 spec-x**.
- P0: `sdd phase done` 호출 시점 이동 + `§6.3.2 Post-Merge Protocol for Phase` 신설 + `§3.1` Exit Condition 보정. Mode 분기 (base / non-base).
- P1: `phase.md` 에 `## 📌 결정 기록 (Review)` 섹션 추가 → Phase living doc 으로 지정.
- P2: `§6.3 bullet 7` 일반화 (walkthrough / plan.md / ADR 분기) + ADR escalation 기준 한 줄.

## 🎯 요구사항

### Functional Requirements
1. **F1 (P0)**: `hk-phase-ship.md` step 5 가 phase base branch mode 와 non-base mode 로 분기:
   - base: PR 생성까지만, `sdd phase done` 호출하지 않음
   - non-base: `sdd phase done` 즉시 실행 (PR 없이 bookkeeping)
2. **F2 (P0)**: `agent.md` 에 `§6.3.2 Post-Merge Protocol for Phase` 신설 — 사용자가 phase 머지 신호 시 (base mode) `sdd phase done` 실행 후 다음 안내.
3. **F3 (P0)**: `constitution §3.1` Exit Condition 마지막 줄에 "+ Phase PR merge (when base branch mode)" 추가.
4. **F4 (P1)**: `phase.md` 템플릿에 `## 📌 결정 기록 (Review)` 섹션 추가 — Spec walkthrough 의 결정 기록 표 패턴 동일.
5. **F5 (P1)**: `agent.md §6.3.2` 안에 "Phase PR review 중 결정/변경은 phase.md 의 결정 기록 섹션에 누적, PR body 는 `gh pr edit --body-file` 로 동기화" 명시.
6. **F6 (P2)**: `agent.md §6.3 bullet 7` 일반화 — review 변경의 *범위* 에 따라 갱신 대상 분기:
   - 결정·발견 사항 → `walkthrough.md`
   - 설계 절반 이상 변경 → `plan.md` 도 함께
   - 아키텍처/cross-cutting/장수명 결정 → 새 ADR + spec.md/phase.md 에서 참조
7. **F7 (P2)**: `constitution §6.3` 에 ADR 트리거 한 줄 추가 — 위 escalation 의 본질만.

### Non-Functional Requirements
1. **N1**: 거버넌스 산출물은 영어 (constitution.md, agent.md). 템플릿 산출물은 한국어 (phase.md, slash command).
2. **N2**: 도그푸딩 sync — `sources/` 와 `.harness-kit/agent/`, `.claude/commands/` 일관성.
3. **N3**: 회귀 — `test-governance-dedup.sh`, `test-two-tier-loading.sh` PASS 유지.

## 🚫 Out of Scope
- ε (phase-ship 도중 fail 처리 protocol) — 현재는 사용자 판단으로 OK, 데이터 더 모은 후 결정.
- `sdd status` 가 open Phase PR 을 표시 — gh CLI 의존 + 도구 변경, 별개 spec-x 후보 (P3).
- `hk-phase-review` timing 명시화 — 사용자 확인으로 거버넌스 대상 아님.
- ADR 자동 생성/숫자 할당 자동화 — escalation 기준만 명시, 자동화는 별개.

## ✅ Definition of Done
- [ ] 거버넌스 + slash command + template 갱신 (sources/)
- [ ] 도그푸딩 sync (.harness-kit/, .claude/commands/)
- [ ] 회귀 테스트 PASS (governance-dedup, two-tier-loading)
- [ ] walkthrough / pr_description ship
- [ ] push + PR
