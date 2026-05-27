# Implementation Plan: spec-19-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-19-01-wiki-layer-bootstrap`
- 시작 지점: `phase-19-doc-knowledge-graph` (phase base branch)
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요

> [!IMPORTANT]
> - [ ] **wiki frontmatter `kind:` 스키마**: ADR-001의 `type:` 5어휘와 별도 공간(`kind:`)으로 분리. 기존 ADR/RCA에는 `sources[]`, `linked[]`, `updated` 필드만 추가 (기존 `type:` 유지)
> - [ ] **기존 ADR/RCA 파일 수정**: ADR-001, ADR-002, RCA-001 frontmatter에 필드 추가 — 기존 내용은 변경 없음

## 🎯 핵심 전략

### wiki frontmatter 스키마

**wiki 페이지 (`docs/wiki/*.md`)**:
```yaml
---
kind: catalog | synthesis
sources:
  - docs/decisions/ADR-001-knowledge-types.md
  - specs/spec-XX-XX-slug/walkthrough.md
linked:
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
updated: YYYY-MM-DD
---
```

- `kind: catalog` — index.md, log.md, purpose.md (메타/운영 파일)
- `kind: synthesis` — decisions.md, patterns.md (증류된 지식 파일)

**기존 ADR/RCA (필드 추가)**:
```yaml
# 기존 필드 유지, 아래 3개 추가
sources:
  - specs/spec-XX-XX-slug/walkthrough.md
linked:
  - "[[wiki/decisions]]"
  - "[[ADR-002]]"
updated: YYYY-MM-DD
```

### wikilink 컨벤션

| 참조 대상 | 형식 | 예시 |
|---|---|---|
| wiki 페이지 | `[[wiki/page-name]]` | `[[wiki/decisions]]` |
| ADR | `[[ADR-NNN]]` | `[[ADR-001]]` |
| RCA | `[[RCA-NNN]]` | `[[RCA-001]]` |
| spec | `[[spec-NN-NN]]` | `[[spec-16-01]]` |

Obsidian에서 `docs/` 를 vault root로 열면 `[[wiki/decisions]]` → `docs/wiki/decisions.md` 자동 해석.

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **wiki frontmatter** | `kind:` (catalog/synthesis) | ADR-001의 `type:` 5어휘와 네임스페이스 분리, 충돌 방지 |
| **wikilink 형식** | `[[wiki/path]]` | Obsidian 표준, bash grep 가능 |
| **부트스트랩 방식** | 수동 합성 (LLM이 직접 작성) | 자동화는 spec-19-02. 첫 wiki는 품질 기준을 먼저 확립 |
| **ADR/RCA backfill** | frontmatter 필드 추가만 | 본문 변경 없음 — merged 산출물 immutable 원칙 유지 |

### 📑 ADR 후보

- [x] `wiki-frontmatter-schema` (type: convention) — `kind:` vs `type:` 공존 규칙 → spec 머지 후 ADR-003 작성

## 📂 Proposed Changes

### [NEW] `docs/wiki/purpose.md`
wiki의 목적, 스키마 정의, wikilink 컨벤션, 운영 규칙 문서

### [NEW] `docs/wiki/index.md`
모든 wiki 페이지 카탈로그 + 관련 ADR/RCA 목록

### [NEW] `docs/wiki/log.md`
인제스트 이력 (초기 부트스트랩 이벤트 기록)

### [NEW] `docs/wiki/decisions.md`
핵심 결정 증류 페이지:
- ADR-001 요약: 5어휘 closure, 왜 필요한가
- ADR-002 요약: SDD ceremony 비용 인식, phase plan은 draft
- RCA-001 요약: sdd ship 버그 → 교훈

### [NEW] `docs/wiki/patterns.md`
반복 패턴 증류 페이지:
- **Good patterns**: bundle-before-spec-x, phase-FF, hook-gradual-escalation, TDD-red-green-commit
- **Anti-patterns**: ceremony-over-work (1-2 task에 SDD), silent-inter-spec-drift, wiki-layer-absence

### [MODIFY] `docs/decisions/ADR-001-knowledge-types.md`
frontmatter에 `sources`, `linked`, `updated` 필드 추가

### [MODIFY] `docs/decisions/ADR-002-planning-economy.md`
frontmatter에 `sources`, `linked`, `updated` 필드 추가

### [MODIFY] `docs/rca/RCA-001-sdd-ship-spec-add-missing.md`
frontmatter에 `sources`, `linked`, `updated` 필드 추가

### [NEW] `tests/test-wiki-structure.sh`
wiki 구조 검증 테스트:
- docs/wiki/ 존재 확인
- 5개 필수 파일 존재 확인
- 각 파일 frontmatter 유효성 (kind, sources, updated 필드)
- 기존 ADR/RCA에 새 frontmatter 필드 존재 확인

## 🧪 검증 계획

### 단위 테스트 (필수)
```bash
bash tests/test-wiki-structure.sh
```

### 수동 검증 시나리오
1. `docs/` 를 Obsidian vault로 열기 → `[[wiki/decisions]]` 링크 클릭 → decisions.md 열림 확인
2. `grep -rh "^kind:" docs/wiki/` → catalog/synthesis 값만 출력 확인
3. `grep -rh "^type:" docs/decisions docs/rca` → ADR-001 어휘(decision/invariant/failure-pattern/convention/tradeoff)만 출력 확인 (kind 값 없음)

## 🔁 Rollback Plan

- wiki 파일들은 신규 생성이므로 롤백 = 삭제. 기존 ADR/RCA 수정은 git revert로 복구 가능.
- 본문 미수정 원칙으로 기존 ADR/RCA 내용 손상 위험 없음

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
