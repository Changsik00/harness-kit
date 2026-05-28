---
id: ADR-003
type: convention
date: 2026-05-27
status: accepted
sources:
  - specs/spec-19-01-wiki-layer-bootstrap/walkthrough.md
linked:
  - "[[wiki/decisions]]"
  - "[[ADR-001]]"
---

# ADR-003: Wiki Frontmatter — `kind:` vs `type:` 네임스페이스 분리

## 📚 Context

spec-19-01 wiki 레이어 부트스트랩 중 두 가지 frontmatter 슬롯이 충돌했다.

- `docs/wiki/*.md` 는 `kind:` 슬롯을 사용 (`catalog` / `synthesis`)
- `docs/decisions/ADR-*.md` 와 `docs/rca/RCA-*.md` 는 `type:` 슬롯을 사용 (constitution §6.4 closure: `decision`, `invariant`, `convention`, `tradeoff`, `failure-pattern`)

두 슬롯 모두 "이 파일이 무엇인가"를 기술하지만 적용 대상과 어휘가 다르다. 혼용하면 grep 도구 오작동과 vocabulary closure 위반이 발생한다.

## 🎯 Decision

**두 슬롯을 네임스페이스로 분리하여 공존시킨다.**

| 슬롯 | 적용 대상 | 어휘 |
|------|----------|------|
| `kind:` | `docs/wiki/*.md` | `catalog` \| `synthesis` |
| `type:` | ADR, RCA | constitution §6.4 closure (5 어휘) |

- `docs/wiki/*.md` 는 `kind:` 만 사용, `type:` 없음.
- ADR / RCA 는 `type:` 만 사용, `kind:` 없음.
- 두 슬롯이 같은 파일에 공존하는 경우는 존재하지 않는다.

## 📊 Consequences

- **긍정**: 각 슬롯의 어휘 closure 가 독립 유지됨. `grep 'kind:'` 로 wiki 파일만, `grep 'type:'` 로 ADR/RCA 만 필터링 가능.
- **부정**: "type vs kind" 이름이 직관적이지 않음 — 신규 기여자에게 혼란 가능.
- **중립**: `test-wiki-structure.sh` 는 `kind:` 를, constitution §6.4 grep 도구는 `type:` 를 검사.

## 🔀 Alternatives

- **단일 `type:` 통합**: wiki 파일도 `type: catalog|synthesis` 로 통일 — 비채택 이유: constitution §6.4 closure (5 어휘)에 `catalog`/`synthesis` 를 추가하면 ADR/RCA vocabulary 가 오염됨.
- **단일 `kind:` 통합**: ADR/RCA 도 `kind:` 로 전환 — 비채택 이유: constitution §6.4 는 `type:` 을 명시하며 grep 도구가 이미 `type:` 기준. 변경 비용 대비 이점 없음.

## 📌 Status

Accepted (2026-05-27, spec-19-01 walkthrough 결정 기록 기반). 첫 사용자: `docs/wiki/`, `docs/decisions/`, `docs/rca/`.

## 🔗 Related

- [[ADR-001]] — Knowledge Type Vocabulary (5 어휘 closure, `type:` 슬롯 정의)
- [[wiki/decisions]] — 이 결정의 증류 요약 포함
