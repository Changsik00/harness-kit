# spec-17-04: Governance + Test Coherence (잡탕 cleanup)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-17-04` |
| **Phase** | `phase-17` (운영 성숙도) |
| **Branch** | `spec-17-04-governance-test-coherence` |
| **상태** | Planning |
| **타입** | Docs + Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

phase-16 회고의 *Warning 4 건* 이 phase-17 의 잔재. 각각 단발 fix 라 spec-x 분리 시 PR 4 개 누적 — 묶음으로 review 1 회.

**W1 — §6.4 closure rule 표현 모호**:
- `sources/governance/constitution.md` §6.4 의 "Used in" 열은 `failure-pattern` 을 RCA 전용으로 표시.
- 그러나 Rules 첫 항목 "RCA and ADR; both adopt the closure" 는 ADR 도 모든 어휘 사용 가능하다고 읽힘.
- ADR 템플릿 코멘트는 `decision | invariant | convention | tradeoff` 만 (failure-pattern 제외).
- 인간 작성자 혼선 — ADR-002 가 잘못 `failure-pattern` 사용해도 grep 은 통과, 의미는 위반.

**W3 — stale ADR 회귀 마커 fragile**:
- `tests/test-drift-stale-adr.sh` Step 3 (회귀 마커) 가 ADR-001 본문에 종속.
- ADR-001 본문이 *정상적으로* 갱신되면 false positive 가능 — 회귀 마커가 *외부 데이터에 결합*.
- 정석: 별 fixture (valid path 만 ADR-998 같은) 로 self-contained 검증.

**W4 — ADR 작성 가이드 누락**:
- `_drift_stale_adr` 는 *inline backtick + 슬래시 + 확장자* 패턴만 검사 (의도된 한계 — spec-16-03 walkthrough 명시).
- 그러나 ADR 작성자에게 *어떤 경로 표기가 stale 검사 대상인지* 알려주는 가이드 부재.
- 사용자가 code fence (` ``` `) 안 또는 backtick 없이 경로 적으면 stale 검사 우회됨 — 도구가 *일하는 척만* 함.

**W7 — CHANGELOG.md phase 통합 정책 부재**:
- phase-16 (4 spec) / phase-17 (4 spec) 의 entry 가 CHANGELOG.md 에 미반영.
- version bump 없으므로 형식적으로 OK 하나, 다음 release 시 8 spec 분량 catch-up 부담.
- CLAUDE.md "릴리스 전략" 섹션에 "phase ship 시 CHANGELOG draft entry 추가" 룰 부재.

### 문제점

- 인간 작성자가 governance 의 표현 충돌 (W1) 로 잘못된 type 사용 가능 — grep closure 는 통과하나 *의미* 위반.
- 회귀 마커가 fragile (W3) — 정상 ADR-001 갱신이 테스트 실패 trigger.
- 도구의 한계 (W4) 가 *사용자에게 노출 안 됨* — silent gap.
- Release 정책 (W7) 누락으로 CHANGELOG catch-up 부담 누적.

### 해결 방안 (요약)

4 항목 한 spec 묶음 cleanup:
1. **W1**: constitution.md §6.4 "Used in" 열 표현 명확화 — RCA 전용 vs ADR 전용 vs 공유 명시.
2. **W3**: `tests/test-drift-stale-adr.sh` 의 Step 3 회귀 마커를 별 fixture (ADR-998-valid-paths) 로 분리.
3. **W4**: ADR 템플릿 (`sources/templates/adr.md`) 에 "경로 표기 가이드" 1 줄 추가 — *inline backtick + 슬래시 + 확장자만 stale 검사 대상* 명시.
4. **W7**: CLAUDE.md "릴리스 전략" 섹션에 "phase ship 시 CHANGELOG draft entry 추가" 룰 추가.

## 🎯 요구사항

### Functional Requirements

1. **W1 — `sources/governance/constitution.md` §6.4 "Used in" 열 표현 명확화**:
   - 각 type 의 "Used in" 항목에 *전용/공유* 마크 명시:
     - `decision` — ADR 전용 (RCA 부적합)
     - `invariant` — ADR + runbook (공유)
     - `failure-pattern` — RCA 전용 (ADR 부적합)
     - `convention` — ADR + style guide (공유)
     - `tradeoff` — ADR 전용
   - Rules 의 "RCA and ADR; both adopt the closure" 표현은 *closure 어휘 자체* 가 두 산출물 모두에 적용되나, *각 type 의 적합 산출물* 은 "Used in" 열을 따른다는 점을 명시.
2. **W3 — `tests/test-drift-stale-adr.sh` 회귀 마커 self-contained 화**:
   - Step 3 ("ADR-001 paths all valid") 을 *fixture-based* 검증으로 전환.
   - 임시 fixture `ADR-998-valid-paths-fixture.md` 생성 (모든 backtick 경로 valid — 예: `sources/bin/sdd` 같이 항상 존재하는 파일만 참조). stale 검사 → "stale ADR" 라인 출력 *없음* 확인 → cleanup.
   - ADR-001 본문 변경에 회귀 마커 종속 안 함.
3. **W4 — ADR 템플릿에 stale 검사 경로 가이드**:
   - `sources/templates/adr.md` 의 본문 시작 부분 (frontmatter 다음, Context 전) 또는 Related 섹션 다음에 가이드 1-3 줄 추가:
     ```markdown
     > **Note: 본 ADR 의 backtick 경로 표기** (예: `src/foo.ts`) 는 `sdd status` 의 stale 검사 대상입니다.
     > 검사 대상 패턴: *inline backtick + 슬래시 + 확장자*. code fence (```) 안 경로 / 슬래시 없는 토큰 / URL 은 무시.
     ```
   - install 미러 (`.harness-kit/agent/templates/adr.md`) 동기화.
4. **W7 — CLAUDE.md "릴리스 전략" 섹션 룰 추가**:
   - 현 CLAUDE.md 의 "릴리스 전략" 섹션에 "phase ship 시 CHANGELOG draft entry 추가" 룰 1-2 줄:
     ```
     - **Phase ship 시 CHANGELOG draft 갱신**: phase 머지 commit 직후, 다음 release 시점에 사용할 *unreleased* draft entry 를 CHANGELOG.md 최상단의 "## [Unreleased]" 섹션에 추가. release commit 에서 일괄 [X.Y.Z] 로 stamp.
     ```
   - 다음 release (post-phase-17) 가 본 룰의 첫 실증.

### Non-Functional Requirements

1. **install 미러 동기화** — sources 변경 항목 (constitution.md, adr.md) 의 `.harness-kit/agent/` 미러 동기화.
2. **회귀 0** — 기존 테스트 (test-sdd-marker-idempotent / test-drift-stale-adr / test-phase16-integration) 모두 PASS 유지.
3. **bash 3.2+ 호환** — test fixture 변경 시.

## 🚫 Out of Scope

- **CHANGELOG.md 의 phase-16 / phase-17 entry backfill** — 본 spec 은 *정책* 만 추가. 실제 entry 작성은 다음 release commit 시점.
- **ADR-002 작성** — 본 spec 의 §6.4 변경은 ADR 가치 있을 수 있으나, *문서 표현 명확화* 만으로 invariant 변경 아님. ADR 승격은 추가 결정 누적 후.
- **stale ADR 검사 확대 (code fence 안 경로 포함)** — spec-16-03 의 의도된 한계. 본 spec 은 *가이드 노출* 만, 검사 로직 확장 아님.
- **CLAUDE.md 의 다른 섹션 정리** — "릴리스 전략" 섹션 1 줄 추가만.

## ✅ Definition of Done

- [ ] W1: `sources/governance/constitution.md` §6.4 "Used in" 열 표현 명확화 + install 미러 sync
- [ ] W3: `tests/test-drift-stale-adr.sh` Step 3 fixture-based 로 전환 + 3/3 PASS 유지
- [ ] W4: `sources/templates/adr.md` 에 stale 검사 가이드 추가 + install 미러 sync
- [ ] W7: CLAUDE.md "릴리스 전략" 섹션에 CHANGELOG draft 룰 추가
- [ ] 회귀: test-sdd-marker-idempotent / test-drift-stale-adr / test-phase16-integration 모두 PASS
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] PR 생성 (target: `phase-17-coherence-fix`)
