---
id: ADR-001
type: decision
date: 2026-05-16
status: accepted
---

# ADR-001: Knowledge Type Vocabulary (5 어휘 closure)

## 📚 Context

AI-assisted engineering 환경에서 *결정* / *실패 패턴* / *불변식* 같은 산출물이 walkthrough 결정 표나 자유 형식 RCA 안에 흩어져 있어 다음 두 가지 비용을 유발했다:

- **검색 비용**: "invariant 만 추출" / "failure-pattern 만 추출" 같은 grep 이 불가능. 자유 태그(free-form tags)는 어휘 폭주로 closure 가 깨진다.
- **인지 비용**: 새 산출물을 작성할 때 *이게 어느 카테고리에 해당하는가* 가 매번 즉흥적으로 결정되어, 후속 reviewer 가 분류 의도를 재구성해야 한다.

외부 진단 (velog `80-problem-in-agentic-coding` §2 Decision Ledger / §3 RCA) 도 동일한 결손을 지적했다 — *결정과 실패가 grep 가능한 자산으로 누적되지 않는다*.

## 🎯 Decision

산출물 frontmatter 의 `type:` 슬롯에 다음 5 어휘 closure 를 도입한다. closure 외 값은 거버넌스 위반.

| Type | 의미 | 첫 사용자 |
|---|---|---|
| `decision` | 비자명한 설계 선택, 장기 자산 | ADR |
| `invariant` | 시스템이 보존해야 할 속성 | ADR / runbook |
| `failure-pattern` | 재발하는 실패 (재현 + 예방) | RCA |
| `convention` | 일관성을 위한 명명/구조 규칙 | ADR / style guide |
| `tradeoff` | 기각된 안에 명시적 비용이 있는 선택 | ADR |

어휘 변경 (추가 / 이름 변경 / 제거) 자체가 ADR 대상 (`type: decision`).

## 📊 Consequences

- **긍정**:
  - `grep -rh "^type:" docs/rca docs/decisions` 로 type 별 추출 가능 — *invariant 만* / *failure-pattern 만* 같은 query 가 1 명령에 끝난다.
  - 산출물 간 인지적 일관성. 새 산출물 작성 시 *분류 사고* 가 줄어든다.
  - 후속 spec-16-03 (stale 탐지) 가 type 별로 다른 검증 규칙을 박을 수 있는 기반.
- **부정**:
  - 어휘 변경 자체가 ADR 대상 — 메타 결정의 비용. 그러나 closure 의 핵심 보장이므로 의도된 비용.
  - 새 산출물 작성 시 type 선택이 강제됨 — 사소한 cognitive load.
- **중립**:
  - 기존 산출물 (frontmatter 없는 RCA / ADR) 의 backfill 은 강제하지 않음 — *신규 산출물* 에만 적용.

## 🔀 Alternatives

- **자유 태그 (free-form tags)**: 진입 장벽 0 / closure 없음. 비채택 이유: 검색 가능성이 어휘 폭주로 즉시 무력화 — 본 결정의 목적인 grep 가능성을 정면 위배.
- **2 어휘 (decision / failure-pattern 만)**: 최소 closure / 학습 곡선 ↓. 비채택 이유: `invariant`, `convention`, `tradeoff` 가 `decision` 에 흡수되어 표현력 손실 — 후속 stale 탐지(spec-16-03) 가 결정 종류별로 다른 규칙을 적용하기 어려워진다.
- **계층 카테고리 (트리)**: 표현력 ↑. 비채택 이유: 본 단계의 산출물 규모(<10) 에 비해 과도. 평면 closure 가 grep 단순성에 부합.

## 📌 Status

Accepted (2026-05-15, spec-16-01 머지 시점).

- **첫 사용자**: RCA — `RCA-001-sdd-ship-spec-add-missing.md` 가 `type: failure-pattern` 으로 도입.
- **두 번째 사용자**: ADR — 본 ADR (spec-16-02 머지 시점) 이 `type: decision` 으로 합류.
- **closure 무결성**: `grep -rh "^type:" docs/rca docs/decisions | sort -u` 가 정규 어휘 부분집합만 출력.

## 🔗 Related

- **spec-16-01** — Knowledge Type Vocabulary 도입 (본 결정의 원 spec).
- **spec-16-02** — ADR 활성화 트리거 (본 ADR 작성 spec, ADR 슬롯의 두 번째 사용자 합류).
- **constitution §6.4** — Knowledge Type Vocabulary 규약.
- **외부 진단**: https://velog.io/@typo/80-problem-in-agentic-coding (§2 Decision Ledger / §3 RCA)
