# spec-25-01: AskUserQuestion 리다이렉트 hook (auto 논블로킹 기계적 백스톱)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-25-01` |
| **Phase** | `phase-25` |
| **Branch** | `spec-25-01-askquestion-redirect-hook` |
| **Base 브랜치** | `main` (phase-25 비-base 모드) |
| **상태** | Planning |
| **타입** | Feature |
| **작성일** | 2026-06-22 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

phase-24 가 auto 모드를 구현했다. auto 의 핵심 약속은 "결정 지점에서 멈추지 않음"이다. 그러나 그 약속은 현재 **agent.md §8.4 산문 한 줄**("In `auto` mode the Agent MUST NOT block on `AskUserQuestion`")에만 의존한다. 기계적 강제가 전혀 없다.

spec-24-04 는 이 산문-only 설계를 의도적으로 선택했고, 그 근거로 *"`AskUserQuestion` 호출 여부는 agent 행동이라 hook 으로 못 막는다"* 고 했다.

### 문제점

1. **전제가 틀렸다.** Claude Code 공식 문서상 `AskUserQuestion` 은 PreToolUse matcher 목록에 명시돼 있고, PreToolUse hook 이 exit 2 + stderr 로 호출을 차단하고 그 stderr 를 에이전트에 피드백한다. 즉 호출을 *가로챌 수 있다*. (→ ADR-009 Addendum, GitHub #181)
2. **약한 지렛대.** Claude Code 시스템 프롬프트는 결정 지점에서 `AskUserQuestion` 을 *권장*한다. auto 의 "안 멈춤"은 모델 기본 행동과 산문 한 줄로 싸우는 구조다 — 에이전트가 습관적으로 한 번 물으면 unattended 세션이 그대로 멈춘다. 사용자의 핵심 우려: "askMode 때문에 다시 멈춘다면 auto 가 의미 있나?"
3. **routine 멈춤과 ① 멈춤이 구분되지 않는다.** 멈춤에는 두 종류가 있다 — routine 결정(work mode·plan-accept·PR 확인·idea capture)은 *안 멈춰야* 하고(버그), 정지규칙 ①(기본값 정당화 불가한 진짜 모호)은 *멈춰야* 한다(기능). 현재는 둘 다 `AskUserQuestion` 으로 흘러 구분 불가.

### 해결 방안

`state.mode == auto` 일 때 `AskUserQuestion` 호출을 PreToolUse hook 으로 가로채 차단(exit 2)하고, stderr 로 **리다이렉트 지침**을 에이전트에 전달한다 — routine 이면 기본값 채택 + `sdd decision add` 후 진행, 정지규칙 ① 이면 `sdd decision add "미해결:..." + 턴 종료`(→ Stop 훅이 notify 발송). governed/turbo 에서는 hook 이 무간섭(exit 0). 이로써 auto 의 논블로킹이 산문 외에 **기계적 백스톱**을 얻고, "routine 멈춤(버그)"과 "① 멈춤(기능)"이 단일 채널로 분리된다.

## 요구사항

1. `state.mode == auto` 에서 `AskUserQuestion` 호출 시 hook 이 발동하여 도구 호출을 차단한다.
2. 차단 시 stderr 로 리다이렉트 지침을 출력한다: (a) routine → 기본값 + `sdd decision add` 후 진행, (b) ① 진짜 모호 → `sdd decision add` 로 미해결 기록 후 턴 종료.
3. `state.mode != auto`(governed / turbo)에서는 hook 이 즉시 통과(exit 0) — 질문 정상 동작.
4. hook 은 기존 `_lib.sh` 헬퍼(`hook_state`, `hook_resolve_mode`) 와 hook 단계론 관례를 따르되, **기본 모드는 block**(이 hook 은 warn 이 무의미 — §핵심 전략 참조).
5. 테스트가 auto=차단 / governed·turbo=통과 / 리다이렉트 메시지 존재를 고정한다.
6. 도그푸딩 미러: `sources/` 변경을 `.harness-kit/` 설치본 + `.claude/settings.json` 에 byte-identical 반영(sync 테스트 회귀 방지).

## Out of Scope

- **사후 테스트 신뢰**(가짜 green 방어) — spec-25-02 (#212 칸0).
- **auto e2e**(실제 사이클 측정) — spec-25-03. 본 spec 은 hook 단위 검증까지.
- **정지규칙 ② 차단 승격** — spec-25-04.
- **`ExitPlanMode` 차단** — auto 에서 plan mode 진입은 별도 관심사. 본 spec 은 `AskUserQuestion` 만.
- agent.md §8.4 산문의 대규모 개정 — 기계적 백스톱 1줄 포인터만 (단어 예산 7850/8000).

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **차단 방식**: exit 2 + stderr (기존 `hook_violation` 관례) vs 구조화 JSON `permissionDecision: "deny"` + reason. 권장: **exit 2 + stderr** — 기존 7개 hook 과 동일 관례, bash 3.2 단순, stderr 가 에이전트에 전달됨이 문서로 확인됨. (구조화 deny 는 -p headless 엣지에 더 견고하나 본 키트는 attended auto 가 기본이라 불필요. ADR 후보로 기록)
> - [ ] **block 기본의 예외성**: CLAUDE.md #5 "새 hook 은 경고 모드 시작" 원칙의 의도적 예외 — 경고(exit 0)는 질문 블로킹을 못 막아 무의미. auto 한정 발동이라 위험 격리됨.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **발동 조건** | `hook_state mode` == `auto` 만. 그 외 exit 0 | tool_input 파싱 불필요 — settings matcher 가 `AskUserQuestion` 만 필터, hook 은 mode 만 확인 |
| **차단 수단** | block 모드(exit 2) + stderr 리다이렉트 | 가이드/공식문서 확인 — exit 2 가 AskUserQuestion 호출 차단 + stderr 를 에이전트에 피드백 |
| **기본 모드** | **block** (warn 아님) | warn(exit 0)은 질문을 막지 못해 무의미. 이 hook 의 존재 이유가 차단. `HARNESS_HOOK_MODE_ASKQUESTION` 로 override 가능 |
| **routine vs ①** | 둘 다 차단하되 stderr 가 분기 지침 제공 | hook 은 agent 의도를 못 읽음 → AskUserQuestion 전면 비활성, ① 은 `decision add + 턴 종료` 단일 채널로 (ADR-009 Addendum) |
| **선검증** | Task 1 spike — 더미 hook 으로 exit 2 가 실제 AskUserQuestion 을 차단하는지 경험적 확인 | 문서로는 확인됐으나 phase-25 최상위 리스크 — 본 구현 전 1회 실증 |

## Proposed Changes

#### [NEW] `sources/hooks/check-askquestion-auto.sh`
PreToolUse hook (matcher: `AskUserQuestion`). `_lib.sh` source → `hook_resolve_mode "ASKQUESTION" "block"`. `hook_state mode` != `auto` → `exit 0`. == `auto` → `hook_violation` 로 차단 + 리다이렉트 지침(routine / ① 분기) 출력.

#### [MODIFY] `sources/claude-fragments/settings.json.fragment`
`PreToolUse` 배열에 `{ "matcher": "AskUserQuestion", "hooks": [{ "type": "command", "command": ".harness-kit/hooks/check-askquestion-auto.sh" }] }` 블록 추가.

#### [MODIFY] `sources/governance/agent.md` (§8.4, 최소)
auto 논블로킹 서술에 1줄 포인터 추가 — "기계적으로 `check-askquestion-auto.sh` 가 강제(spec-25-01)". 단어 예산 준수(≤8000).

#### [NEW] `tests/test-askquestion-auto.sh`
시나리오: ① mode=auto → 차단(exit 2) + stderr 에 리다이렉트 문구. ② mode=governed → 통과(exit 0). ③ mode=turbo → 통과(exit 0). ④ `HARNESS_HOOK_MODE_ASKQUESTION=warn` override 동작.

#### [MODIFY] 도그푸딩 미러 (설치본)
`.harness-kit/hooks/check-askquestion-auto.sh` (sources 와 byte-identical), `.claude/settings.json` PreToolUse 에 동일 matcher 블록 추가.

## 검증 계획

```bash
bash tests/test-askquestion-auto.sh
bash tests/run.sh          # 전체 회귀 (72/72 유지 + 신규)
```

수동 검증 시나리오:
1. `sdd mode auto` → AskUserQuestion 호출 유도 → hook 이 exit 2 로 차단, stderr 리다이렉트 확인 (Task 1 spike + Ship 전 1회).
2. `sdd mode governed` → AskUserQuestion 정상 동작 (차단 안 됨).
3. sources ↔ .harness-kit 미러 동일성: 기존 sync 테스트 PASS 유지.

## 롤백 계획

- `git revert` — 코드 변경만(hook 파일 + settings 블록 + 테스트). state/마이그레이션 영향 없음.
- settings.json 의 추가된 matcher 블록 제거 시 hook 미발동 — 기존 동작으로 즉시 복귀.

## ADR 후보

- [x] ADR 가치 있는 결정 있음 → 후보: 차단 방식(exit 2 vs 구조화 deny) + block-기본 예외 (type: tradeoff). 단, ADR-009 Addendum 이 이미 설계 방향을 담고 있어 **walkthrough 결정 기록으로 충분할 수 있음** — Ship 시 판단.
- [ ] 없음

## ✅ Definition of Done

- [ ] `tests/test-askquestion-auto.sh` 신규 PASS + 전체 회귀 PASS
- [ ] auto 차단 / governed·turbo 통과 / 리다이렉트 메시지 고정
- [ ] sources ↔ 설치본 미러 동일 (sync 테스트 PASS)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-25-01-askquestion-redirect-hook` 브랜치 push 완료
