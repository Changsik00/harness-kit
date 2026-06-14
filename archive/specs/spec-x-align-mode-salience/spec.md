# spec-x-align-mode-salience: align 모드 부각 + intent 잔재 정리

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-align-mode-salience` |
| **Phase** | 없음 (spec-x) |
| **Branch** | `spec-x-align-mode-salience` |
| **상태** | Planning |
| **타입** | Docs |
| **작성일** | 2026-06-14 |
| **소유자** | dennis |

## 배경 및 문제 정의

### 현재 상황

`/hk-align` 의 상태 보고(`align.md` §5)는 Active Phase/Spec/Branch/Plan Accept/Last Test 를 표시하지만 **`Active Mode`(governed/turbo)는 빠져 있다.** `sdd status` 자체는 Active Mode 와 Active Intent 를 출력하나, align.md 가 이를 보고에 부각하거나 잔재를 정리하라고 지시하지 않는다.

### 문제점 (이번 세션 RCA에서 도출)

- 사용자가 세션을 **turbo 로 착각**한 채 governed 로 진행 → "왜 Plan Accept 를 묻지?"의 근원(모드 모델 불일치). 에이전트가 모드를 보고에 부각하지 않아 잘못된 모델이 세션 내내 유지됨.
- 이전 turbo 세션이 깨끗이 종료되지 않아 **`Active Intent` 잔재**(예: `test goal`)가 남았고, 이것이 모드 혼선을 키웠으나 align 이 정리를 제안하지 않음.

### 해결 방안

`align.md` 에 ① 상태 보고에 `Active Mode` 를 항상 포함 + governed 이고 기능/PR 작업 착수 시 "Plan Accept 게이트 적용, 이 작업유형은 turbo 비대상(§2.4)"을 *spec 작성 전* 부각, ② `Active Intent` 잔재 감지 시 `sdd intent clear` 정리 제안(자동 금지)을 추가한다. 설치본 `.harness-kit/agent/align.md` 도 미러링한다.

## 요구사항

1. `align.md` §5 상태 보고 블록에 `- Active Mode: governed / turbo` 라인 추가.
2. **모드 부각 지시**: `governed` 이고 곧 기능/아키텍처/PR 작업을 시작하면, spec 작성 *전에* 한 줄로 알린다 — "governed 라 Plan Accept 1회 게이트, 이 작업이 기능/PR 대상이면 turbo 부적합(constitution §2.4)". 사용자가 알고 선택하게 한다.
3. **Intent 잔재 점검 지시**: `sdd status` 에 `Active Intent` 가 있으면(특히 `Active Mode: governed` 인데 잔존 시 이전 turbo 미종료 잔재 가능성) 보고에 포함하고 `sdd intent clear` 정리를 제안한다. **자동 정리 금지** — 아카이브 제안(§4)과 동일한 no-auto 패턴.
4. 설치본 `.harness-kit/agent/align.md` 를 sources 와 byte-identical 로 미러링(도그푸딩 sync).

## Out of Scope

- `constitution.md` / `agent.md` 수정 — 거버넌스 단어 budget(8000w) 압박으로 본 spec 범위 외. align.md 는 budget 비대상이라 여기만 손댄다.
- `sdd status` 코드 변경(예: stale-intent 명시 플래그 emit) — 현재 status 가 이미 Active Mode/Intent 를 출력하므로 doc 지시로 충분. 코드 강화는 doc 가이드가 부족할 때 별도 검토(Icebox).
- constitution §2.4 완화("소규모 기능 turbo 허용") — premature-execution 가드 약화 우려로 별도 ADR 논의 대상, 본 spec 아님.

## 핵심 전략

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| 변경 범위 | `align.md` 한 파일 + 설치본 미러 | 가장 가벼운 right-size. budget 비대상 |
| 감지 방식 | doc 지시 (코드 변경 없음) | `sdd status` 가 이미 모드/intent 출력 — align 이 "행동"만 지시하면 됨 |
| 잔재 정리 | 제안만, 자동 금지 | §4 아카이브 제안과 동일 no-auto 패턴(사용자 결정 존중) |

## Proposed Changes

#### [MODIFY] `sources/governance/align.md`
- §5 상태 보고 블록에 `Active Mode` 라인 추가.
- "모드 부각" 지시 추가(governed + 기능/PR 착수 시 Plan Accept/turbo 비대상 사전 고지).
- "Intent 잔재 점검" 지시 추가(`Active Intent` 감지 → `sdd intent clear` 제안, 자동 금지).

#### [MODIFY] `.harness-kit/agent/align.md`
- 위 변경을 byte-identical 로 미러링(도그푸딩 sync — sources↔설치본).

## 검증 계획

```bash
# 거버넌스/매니페스트 정합 회귀 (doc 변경이라 단위 테스트 없음)
bash tests/test-install-manifest-sync.sh
bash tests/run.sh --fast
```

수동 검증:
1. `sources/governance/align.md` 와 `.harness-kit/agent/align.md` `diff -q` → 동일.
2. align.md §5 블록에 `Active Mode` 포함 + 모드 부각/intent 잔재 지시 존재 확인.

## ADR 후보

- [ ] ADR 가치 있는 결정 있음
- [x] 없음 (기존 align 보강. §2.4 완화 논의는 별도 ADR 후보로 Out of Scope)

## ✅ Definition of Done

- [ ] 매니페스트/회귀 정합 PASS (신규 회귀 0)
- [ ] sources ↔ 설치본 align.md 동일
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-x-align-mode-salience` 브랜치 push 완료
