# Task List: spec-19-01

> 모든 task 는 한 commit 에 대응합니다 (One Task = One Commit).
> 매 commit 직후 본 파일의 체크박스를 갱신해야 합니다.

## Pre-flight (Plan 작성 단계)

- [x] Spec ID 확정 및 디렉토리 생성
- [x] spec.md 작성
- [x] plan.md 작성
- [x] task.md 작성 (이 파일)
- [x] 백로그 업데이트 (phase-19.md SPEC 표 갱신 — sdd 자동)
- [ ] 사용자 Plan Accept

---

## Task 1: 브랜치 생성

### 1-1. 브랜치 생성
- [ ] `git checkout -b spec-19-01-wiki-layer-bootstrap` (base: `phase-19-doc-knowledge-graph`)
- [ ] Commit: 없음 (브랜치 생성만)

---

## Task 2: wiki 구조 테스트 작성 (TDD Red)

### 2-1. 테스트 파일 작성
- [ ] `tests/test-wiki-structure.sh` 작성 — 아래 assertions 포함:
  - `docs/wiki/` 디렉토리 존재
  - 5개 필수 파일 존재 (purpose.md, index.md, log.md, decisions.md, patterns.md)
  - 각 wiki 파일에 `kind:` 필드 존재
  - 각 wiki 파일에 `sources:` 필드 존재
  - 각 wiki 파일에 `updated:` 필드 존재
  - ADR-001/002, RCA-001 frontmatter에 `sources:` 필드 존재
- [ ] 테스트 실행 → 전부 FAIL 확인 (docs/wiki/ 미존재)
- [ ] Commit: `test(spec-19-01): add wiki structure validation test`

---

## Task 3: wiki purpose.md 작성

### 3-1. docs/wiki/purpose.md 생성
- [ ] wiki 목적, frontmatter 스키마(`kind:`, `sources[]`, `linked[]`, `updated`), wikilink 컨벤션 문서화
- [ ] `kind: catalog` frontmatter 포함
- [ ] Commit: `docs(spec-19-01): add docs/wiki/purpose.md with schema and conventions`

---

## Task 4: wiki index.md + log.md 작성

### 4-1. docs/wiki/index.md 생성
- [ ] 모든 wiki 페이지 카탈로그, 관련 ADR/RCA 목록, wikilink 색인
- [ ] `kind: catalog` frontmatter 포함

### 4-2. docs/wiki/log.md 생성
- [ ] 초기 부트스트랩 이벤트 기록 (타임스탬프, 대상, 방법)
- [ ] `kind: catalog` frontmatter 포함
- [ ] Commit: `docs(spec-19-01): add docs/wiki/index.md and log.md`

---

## Task 5: wiki decisions.md 합성

### 5-1. docs/wiki/decisions.md 생성
- [ ] ADR-001 핵심 증류: 5어휘 closure, 왜 필요한가, grep 가능성
- [ ] ADR-002 핵심 증류: SDD ceremony 비용, phase plan은 draft, pre-spec 재검증
- [ ] RCA-001 핵심 증류: sdd ship 버그 패턴, invariant, prevention
- [ ] `[[wikilinks]]`로 원본 ADR/RCA 역참조
- [ ] `kind: synthesis` frontmatter 포함
- [ ] Commit: `docs(spec-19-01): add docs/wiki/decisions.md synthesizing ADR-001/002 and RCA-001`

---

## Task 6: wiki patterns.md 합성

### 6-1. docs/wiki/patterns.md 생성
- [ ] **Good patterns** (phase-08~18 발견): bundle-before-spec-x, phase-FF, hook-gradual-escalation, TDD-red-green-commit, human-curates-llm-maintains
- [ ] **Anti-patterns**: ceremony-over-work, silent-inter-spec-drift, doc-accumulation-without-wiki
- [ ] 각 패턴에 출처 spec/phase 태그
- [ ] `kind: synthesis` frontmatter 포함
- [ ] Commit: `docs(spec-19-01): add docs/wiki/patterns.md with good patterns and anti-patterns`

---

## Task 7: 기존 ADR/RCA frontmatter 확장 + 테스트 Green

### 7-1. ADR-001, ADR-002, RCA-001 frontmatter 필드 추가
- [ ] `docs/decisions/ADR-001-knowledge-types.md` — `sources`, `linked`, `updated` 추가
- [ ] `docs/decisions/ADR-002-planning-economy.md` — `sources`, `linked`, `updated` 추가
- [ ] `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` — `sources`, `linked`, `updated` 추가
- [ ] 본문 내용 미수정 확인
- [ ] `bash tests/test-wiki-structure.sh` → 전부 PASS 확인
- [ ] Commit: `docs(spec-19-01): extend ADR/RCA frontmatter with sources, linked, updated fields`

---

## Task 8: Ship

- [ ] 전체 테스트 실행 → PASS: `bash tests/test-wiki-structure.sh`
- [ ] Obsidian 수동 검증: `[[wiki/decisions]]` 링크 탐색 가능 확인
- [ ] **walkthrough.md 작성**
- [ ] **pr_description.md 작성**
- [ ] **Ship Commit**: `docs(spec-19-01): ship walkthrough and pr description`
- [ ] **Push**: `git push -u origin spec-19-01-wiki-layer-bootstrap`
- [ ] **PR 생성**: `/hk-pr-gh` 실행 (base: `phase-19-doc-knowledge-graph`)
- [ ] **사용자 알림**: 푸시 완료 + PR URL 보고

---

## 진행 요약

| 항목 | 값 |
|---|---|
| **총 Task 수** | 8 (브랜치 1 + 작업 6 + Ship 1) |
| **예상 commit 수** | 7 |
| **현재 단계** | Planning |
| **마지막 업데이트** | 2026-05-27 |
