# spec-24-04: 논블로킹 결정 (기본값 + 로그)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-24-04` |
| **Phase** | `phase-24` |
| **Branch** | `spec-24-04-nonblocking-decision` |
| **Base 브랜치** | `main` (phase-24 는 base 브랜치 없음 — 각 spec → main) |
| **상태** | Planning |
| **타입** | Feature (CLI resolver + 거버넌스 서술) |
| **작성일** | 2026-06-21 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

auto 모드의 *안전판*(정지규칙 ②③ + 결정 로그 `sdd decision`)은 24-03 까지 구현됐다. 그러나 auto 의 핵심 동작 — **결정 지점에서 멈추지 않기** — 는 아직 정의되지 않았다.

### 문제점

ADR-009 auto 규약 2: 결정이 필요한 순간(통상 `AskUserQuestion`) auto 는 *합리적 기본값으로 진행 + 근거 로깅* 해야 하고, 사람을 기다리며 멈추면 안 된다. 두 가지가 빠져 있다:
- **행동 규칙 부재**: agent 가 auto 에서 결정 지점을 어떻게 처리할지(기본값 채택·`sdd decision` 로깅·언제만 멈추는지=① 방향 모호)에 대한 거버넌스 서술이 없다.
- **ask-mode 해석 부재**: agent 는 `uxMode`(interactive/text)로 `AskUserQuestion` 사용 여부를 정하는데, auto 일 때 이를 text(=기본값, 미대기)로 *강제* 하는 단일 해석점이 없다.

### 해결 방안

(1) auto 일 때 effective ux-mode 를 `text` 로 해석하는 `sdd config ux-mode effective` resolver 를 추가해 agent 가 질의할 단일 SSOT 를 만들고, (2) agent.md §8.4 에 auto 논블로킹 결정 행동 규칙(기본값+`sdd decision` 로깅, ① 방향 모호 시에만 hard stop)을 *린하게* 서술한다.

## 요구사항

1. **effective ux-mode resolver**: `sdd config ux-mode effective` → `state.mode=auto` 이면 항상 `text`, 그 외엔 저장된 `uxMode` 값. 기존 `ux-mode`(조회/설정/toggle) 동작 불변.
2. **agent.md §8.4 auto 서술**(린): auto 결정 지점 → 합리적 기본값 채택 + `sdd decision add` 로깅, *미대기*. ① 방향 모호(기본값을 정당화할 수 없는 갈림)일 때만 hard stop(정지규칙 ①). ask-mode 는 `sdd config ux-mode effective` 로 해석(auto=text). 상세는 ADR-009 규약 2 포인터.
3. 도그푸딩 미러(`.harness-kit/`) 반영. 거버넌스 단어수 8000 한도 유지(현재 7786 — 추가분 린하게, 초과 시 rule-prune).
4. 신규 테스트 PASS + 전체 회귀 없음.

## Out of Scope

- 결정 로그의 phase-ship 일괄 노출 + spec 전환 테스트 게이트 → spec-24-05.
- auto 모드 전체 e2e(`test-e2e-auto-mode.sh`) → 24-05(phase-ship 체크포인트)에서 통합.
- 정지규칙 ②③ 엔진(24-03 완료) / agent 가 실제 `AskUserQuestion` 을 호출하는 런타임 자체(거버넌스 서술로 규율 — 기계적 강제 대상 아님).

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] auto 논블로킹 결정은 *거버넌스 서술 + resolver* 로 규율 — `AskUserQuestion` 호출 자체를 막는 hook 은 없음(agent 행동 규약). 결정·근거는 `sdd decision`(24-03)으로 사후 검토.
> - [ ] ① 방향 모호 정지는 agent 판단(기본값 정당화 불가 시) — 기계적 hook 아님.

> [!WARNING]
> - [ ] agent.md 추가로 거버넌스 단어수 증가(7786 → 한도 8000). 린하게 유지, 초과 시 rule-prune(phase-FF).

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **ux-mode resolver** | `effective` 서브값 추가 — auto→text, else 저장값 | agent 가 질의할 단일 SSOT. 기존 동작 불변(조기 return) |
| **agent.md §8.4** | auto 행동 규칙 *린 서술* + ADR-009 포인터 | 결정 처리는 agent 행동 규약 영역 — 상세는 ADR, 거버넌스엔 표/포인터(단어예산) |

**①·②·③ 정리**: ②비가역·③반복실패 = 24-03 기계적 엔진. **①방향 모호 = 본 spec** 의 agent 행동 규칙(기본값 불가 시 hard stop). 결정 로깅 = 24-03 `sdd decision` 재사용.

## Proposed Changes

#### [MODIFY] `sources/bin/sdd`
`_config_ux_mode` 에 `effective` 분기 추가: `state.mode=auto` → `text`, 아니면 저장된 `uxMode`. 조기 return(설정 경로 미진입). `cmd_help` 의 ux-mode 설명에 `effective` 한 줄 추가.

#### [MODIFY] `sources/governance/agent.md`
§8.4 에 auto 논블로킹 결정 행동 규칙 린 서술(기본값+`sdd decision` 로깅·미대기, ① 방향 모호 hard stop, ask-mode=effective text). ADR-009 규약 2 포인터.

#### [NEW] `tests/test-ask-mode-auto.sh`
`sdd config ux-mode effective` 검증: auto→text(저장값 무관), governed+interactive→interactive, governed+text→text, toggle/조회 회귀.

#### [MODIFY] `.harness-kit/bin/sdd` · [MODIFY] `.harness-kit/agent/agent.md`
도그푸딩 미러.

## 검증 계획

```bash
bash tests/test-ask-mode-auto.sh        # 신규
bash tests/test-sdd-config.sh           # ux-mode 회귀
bash tests/test-mode-auto.sh            # auto 모드 회귀
cat sources/governance/constitution.md sources/governance/agent.md | wc -w   # ≤ 8000
for t in tests/test-*.sh; do bash "$t" >/dev/null 2>&1 && echo "PASS $t" || echo "FAIL $t"; done
```

수동 검증 시나리오:
1. `sdd mode auto` → `sdd config ux-mode effective` → `text` (저장 uxMode 가 interactive 여도).
2. `sdd mode governed` + uxMode=interactive → effective `interactive`.

## 롤백 계획

- `git revert`. resolver 는 신규 분기·기존 경로 불변, agent.md 서술 추가뿐 — state/외부 효과 없음.

## ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 — ADR-009 규약 2 가 거버닝. 본 spec 은 그 구현·서술.

## ✅ Definition of Done

- [ ] 모든 테스트 PASS (신규 + 회귀) + 거버넌스 단어수 ≤ 8000
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-24-04-nonblocking-decision` 브랜치 push 완료
