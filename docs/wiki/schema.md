---
kind: catalog
sources: []
linked:
  - "[[wiki/index]]"
updated: 2026-10-22
---

# docs/wiki/ — 스키마 (에이전트·사람 공용 운영 규약)

> "human curates, LLM maintains" — Karpathy LLM Wiki 패턴

## 이 디렉토리의 역할

`docs/wiki/`는 harness-kit의 **지식 증류 레이어**입니다.

- **raw layer** (`archive/specs/`, ADR, RCA): 111개+ 원본 산출물 — 상세하지만 탐색 불가
- **wiki layer** (이 디렉토리): raw에서 *의미 있는 것만* 증류 — 새 세션에서 즉시 참조 가능

새 세션에서 "이 프로젝트가 X에 대해 어떻게 결정했지?" 라는 질문에 raw 111개를 뒤지지 않고 `docs/wiki/decisions.md` 하나로 답할 수 있는 것이 목표입니다.

## 핵심 파일

| 파일 | kind | 역할 |
|---|---|---|
| `schema.md` | catalog | 이 문서 — 목적·스키마·운영 규칙 (Ingest/Query/Lint) |
| `index.md` | catalog | wiki 페이지 + ADR/RCA 인벤토리 |
| `log.md` | catalog | 인제스트 이벤트 이력 |
| `decisions.md` | synthesis | 핵심 결정 증류 (ADR, 주요 walkthrough) |
| `patterns.md` | synthesis | good pattern + anti-pattern 증류 |

## Frontmatter 스키마

### wiki 페이지 (`docs/wiki/*.md`)

```yaml
---
kind: catalog | synthesis    # catalog: 운영 파일 / synthesis: 증류 지식
sources:                     # 이 페이지를 합성하는 데 사용한 원본 문서
  - docs/decisions/ADR-001-knowledge-types.md
  - specs/spec-XX-XX-slug/walkthrough.md
linked:                      # 관련 wiki/ADR/RCA wikilinks
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
updated: YYYY-MM-DD          # 마지막 갱신일
---
```

### 기존 ADR/RCA (backfill 필드)

기존 `type:`, `date:`, `status:` 필드는 그대로 유지. 아래 3개 필드만 추가:

```yaml
sources:                     # 이 문서를 만든 원인 spec
  - specs/spec-XX-XX-slug/walkthrough.md
linked:                      # 관련 wiki/ADR/RCA
  - "[[wiki/decisions]]"
  - "[[ADR-002]]"
updated: YYYY-MM-DD
```

> ADR-001의 `type:` 5어휘 vocabulary와 wiki의 `kind:` 는 별도 네임스페이스입니다.
> `type:` → ADR/RCA 전용 (decision/invariant/failure-pattern/convention/tradeoff)
> `kind:` → wiki 페이지 전용 (catalog/synthesis)

## wikilinks 컨벤션

| 참조 대상 | 형식 | 예시 |
|---|---|---|
| wiki 페이지 | `[[wiki/page-name]]` | `[[wiki/decisions]]` |
| ADR | `[[ADR-NNN]]` | `[[ADR-001]]` |
| RCA | `[[RCA-NNN]]` | `[[RCA-001]]` |
| spec | `[[spec-NN-NN]]` | `[[spec-16-01]]` |

Obsidian에서 `docs/` 를 vault root로 열면 자동 탐색됩니다.

## 운영 규칙

1. **synthesis 페이지는 LLM이 유지**: `/hk-wiki-ingest` 실행 시 archive된 spec의 walkthrough를 읽고 decisions.md / patterns.md 갱신
2. **catalog 페이지는 수동 유지**: index.md, log.md, schema.md는 사람이 직접 편집
3. **증류 원칙**: 반복되거나 중요한 결정/패턴만 포함. 모든 spec을 링크하지 않음
4. **sources[] 필수**: synthesis 페이지는 반드시 원본 출처를 `sources:` 에 명시
5. **본문 인용**: hallucination 방지를 위해 walkthrough 원문 인용 + "출처: spec-XX-XX §결정" 명시

## Ingest — 무엇을 쓰고 무엇을 버리나

실행: `/hk-wiki-ingest` (archive 후, 또는 `sdd doctor` 가 wiki 신선도 경고를 낼 때).

- **쓴다**: 이후 작업의 판단을 바꾸는 것 — 설계 결정과 그 이유, 재발한 함정, 검증된 패턴.
- **버린다**: 일회성 수정, 문구 정리, 이미 ADR/코드에 있는 사실의 복제. 모든 spec 을 링크하지 않는다.
- 새 항목은 *한 줄 결론 + 출처* 로 시작한다 (에이전트가 훑을 때 결론만 읽어도 쓸모 있게).
- 같은 내용이 이미 있으면 추가하지 않고 출처 태그만 보강한다. 기존 내용은 삭제·교체하지 않는다.

## Query — 에이전트가 wiki 를 읽는 시점

에이전트는 아래 상황에서 raw(`archive/specs/`) 를 뒤지기 *전에* wiki 를 먼저 본다 (CLAUDE.fragment 에 같은 규칙).

| 상황 | 먼저 읽을 곳 |
|---|---|
| "이 프로젝트가 X 를 왜 이렇게 했나 / 이미 결정됐나" | `decisions.md` |
| 새 spec·plan 착수 전, 비슷한 작업을 해본 적 있는지 | `patterns.md` (안티패턴 포함) |
| ADR/RCA 전체 목록이 필요할 때 | `index.md` |
| wiki 에 답이 없을 때 | 그제서야 `archive/specs/*/walkthrough.md` 를 검색 |

wiki 와 raw 가 충돌하면 raw(ADR·코드) 가 우선이며, 충돌을 발견하면 wiki 를 고치거나 `/hk-wiki-ingest` 대상으로 보고한다.

## Lint — 건강 상태 점검

`sdd doctor` 의 `wiki layer` 섹션이 자동 점검한다: 고아 `[[wikilink]]`, stale ADR/RCA(90일+), 신선도(wiki 에 없는 ADR, 마지막 인제스트 이후 archive 누적). 경고는 차단하지 않고 `/hk-wiki-ingest` 를 안내한다.
