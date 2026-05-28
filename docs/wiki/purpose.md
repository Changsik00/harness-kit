---
kind: catalog
sources: []
linked:
  - "[[wiki/index]]"
updated: 2026-05-27
---

# docs/wiki/ — 목적 & 스키마

> "human curates, LLM maintains" — Karpathy LLM Wiki 패턴

## 이 디렉토리의 역할

`docs/wiki/`는 harness-kit의 **지식 증류 레이어**입니다.

- **raw layer** (`archive/specs/`, ADR, RCA): 111개+ 원본 산출물 — 상세하지만 탐색 불가
- **wiki layer** (이 디렉토리): raw에서 *의미 있는 것만* 증류 — 새 세션에서 즉시 참조 가능

새 세션에서 "이 프로젝트가 X에 대해 어떻게 결정했지?" 라는 질문에 raw 111개를 뒤지지 않고 `docs/wiki/decisions.md` 하나로 답할 수 있는 것이 목표입니다.

## 핵심 파일

| 파일 | kind | 역할 |
|---|---|---|
| `purpose.md` | catalog | 이 문서 — 목적·스키마·컨벤션 |
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

## [[wikilinks]] 컨벤션

| 참조 대상 | 형식 | 예시 |
|---|---|---|
| wiki 페이지 | `[[wiki/page-name]]` | `[[wiki/decisions]]` |
| ADR | `[[ADR-NNN]]` | `[[ADR-001]]` |
| RCA | `[[RCA-NNN]]` | `[[RCA-001]]` |
| spec | `[[spec-NN-NN]]` | `[[spec-16-01]]` |

Obsidian에서 `docs/` 를 vault root로 열면 자동 탐색됩니다.

## 운영 규칙

1. **synthesis 페이지는 LLM이 유지**: `/hk-wiki-ingest` 실행 시 archive된 spec의 walkthrough를 읽고 decisions.md / patterns.md 갱신
2. **catalog 페이지는 수동 유지**: index.md, log.md, purpose.md는 사람이 직접 편집
3. **증류 원칙**: 반복되거나 중요한 결정/패턴만 포함. 모든 spec을 링크하지 않음
4. **sources[] 필수**: synthesis 페이지는 반드시 원본 출처를 `sources:` 에 명시
5. **본문 인용**: hallucination 방지를 위해 walkthrough 원문 인용 + "출처: spec-XX-XX §결정" 명시
