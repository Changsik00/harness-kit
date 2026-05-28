# spec-19-01: 문서 위키 레이어 설계 & 부트스트랩

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-19-01` |
| **Phase** | `phase-19` |
| **Branch** | `spec-19-01-wiki-layer-bootstrap` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | yes |
| **작성일** | 2026-05-27 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

harness-kit은 17개 phase, 111개+ archived spec, ADR 2개(ADR-001 Knowledge Types, ADR-002 Planning Economy), RCA 1개(RCA-001 sdd ship 버그)를 보유한다. 각 문서는 개별 파일로 존재하며 상호 연결이 없다.

### 문제점

- **지식 누적 없음**: 새 세션마다 "archive strategy는 어떻게 결정됐지?"에 답하려면 111개 파일을 재탐색해야 한다
- **ADR/RCA 고립**: ADR-001, ADR-002가 어떤 배경과 어떤 패턴과 연결되는지 해당 문서를 전부 읽어야만 파악 가능
- **패턴 증류 없음**: "bundle before spec-x" 같은 good pattern이 여러 phase에서 반복 확인됐지만 어디에도 체계적으로 기록되어 있지 않음
- **raw layer 비현실적**: 111개 spec.md/walkthrough.md를 LLM 컨텍스트에 올리는 것은 불가능

### 해결 방안 (요약)

Karpathy의 LLM Wiki 패턴을 차용해 `docs/wiki/` 지식 증류 레이어를 신설한다. raw 111개를 읽지 않고도 핵심 결정·패턴을 즉시 참조할 수 있는 5개 wiki 페이지를 생성하고, `[[wikilinks]]`와 YAML frontmatter로 wiki↔raw 역참조를 유지한다.

## 📊 개념도

```
Raw Layer (읽지 않아도 됨)       Wiki Layer (즉시 참조)
────────────────────────         ──────────────────────────────
archive/specs/ (111개)   →→→    docs/wiki/decisions.md
docs/decisions/ADR-001   →→→    docs/wiki/patterns.md
docs/decisions/ADR-002   →→→    docs/wiki/index.md   (카탈로그)
docs/rca/RCA-001         →→→    docs/wiki/log.md     (인제스트 이력)
                                 docs/wiki/purpose.md (스키마/컨벤션)

             [[wikilinks]] + sources[] 역참조로 연결 유지
```

## 🎯 요구사항

### Functional Requirements

1. `docs/wiki/` 에 5개 핵심 파일 생성: `purpose.md`, `index.md`, `log.md`, `decisions.md`, `patterns.md`
2. 각 wiki 파일은 YAML frontmatter 포함: `kind`, `sources[]`, `linked[]`, `updated`
3. `docs/wiki/decisions.md`는 ADR-001·ADR-002·RCA-001 핵심 내용을 증류하여 포함
4. `docs/wiki/patterns.md`는 phase-08~18에서 확인된 good pattern + anti-pattern 포함
5. 기존 `docs/decisions/ADR-*.md`, `docs/rca/RCA-*.md`에 `sources[]`, `linked[]`, `updated` 필드 추가
6. `[[wikilinks]]` 컨벤션 정의: `[[wiki/page-name]]`, `[[ADR-NNN]]`, `[[RCA-NNN]]` 형식

### Non-Functional Requirements

1. Obsidian 호환: `[[wikilinks]]`는 Obsidian 표준 wikilink로 자동 인식
2. bash 파싱 가능: frontmatter는 `grep`/`sed`로 추출 가능한 단순 YAML
3. ADR-001 어휘 비충돌: wiki 페이지는 `type:` 필드 미사용, 대신 `kind:` 사용 (`catalog` / `synthesis`)

## 🚫 Out of Scope

- `/hk-wiki-ingest` 슬래시 커맨드 구현 → spec-19-02
- `sdd archive` 연동 → spec-19-02
- 모든 artifact 템플릿에 "관련 문서" 섹션 추가 → spec-19-02
- `sdd doctor` wiki 검증 추가 → spec-19-03
- CLAUDE.md 슬림화 → spec-19-03
- wiki 자동 갱신 (이번은 수동 초기 부트스트랩)

## 📑 ADR 후보

- [x] ADR 가치 있는 결정 있음 → `wiki-frontmatter-schema` (type: convention) — ADR-001 어휘와 wiki frontmatter `kind:` 스키마의 공존 규칙 명문화

## ✅ Definition of Done

- [ ] `tests/test-wiki-structure.sh` 모든 assertions PASS
- [ ] `docs/wiki/` 5개 핵심 파일 존재 및 frontmatter 유효
- [ ] `docs/wiki/decisions.md`에 ADR-001, ADR-002, RCA-001 핵심 내용 증류 포함
- [ ] 기존 ADR-001, ADR-002, RCA-001 frontmatter에 `sources[]`, `linked[]`, `updated` 추가
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-19-01-wiki-layer-bootstrap` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
