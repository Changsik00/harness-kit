---
kind: catalog
sources: []
linked:
  - "[[wiki/index]]"
updated: 2026-05-28
---

# Wiki Ingest Log

> 인제스트 이벤트 이력. `/hk-wiki-ingest` 실행 시 자동 추가.

## 형식

```
### YYYY-MM-DD — <이벤트 제목>
- **대상**: <archive된 phase 또는 spec>
- **갱신된 wiki 페이지**: decisions.md, patterns.md, ...
- **추가된 내용 요약**: <1~3줄>
```

---

### 2026-05-28 — phase 01~17 아카이브 일괄 인제스트 (105 walkthrough)

- **대상**: archive/specs/ 전체 (spec-01-01 ~ spec-17-05 + spec-x 다수) — 105개 walkthrough 추출 결정/발견
- **갱신된 wiki 페이지**: decisions.md, patterns.md
- **추가된 내용 요약**:
  - decisions.md: 신규 결정 4건 — [[spec-15-05]](state.json exclusion 보존), [[spec-x-sdd-version-source-fix]](kitVersion SSOT=installed.json), [[spec-13-02]](선택 도구 graceful degradation), [[spec-08-02]](fixture lib `bin/lib/` 심링크)
  - patterns.md good 4건 — `dogfooding-as-regression-detector`, `install-directory-glob`, `grep-fixed-string-verification`, `dual-binary-dogfood-sync`
  - patterns.md anti 5건 — `sdd-marker-append-not-idempotent`(phase 10~17 최다 반복 버그), `install-overwrite-then-restore`, `defensive-git-add-A`, `regex-grep-c-over-awk-exact`, `install-resets-state`
  - 단일 컨텍스트 한정 발견(특정 fixture slug, 특정 awk 필드 번호 등)과 기존 wiki 중복분(SIGPIPE, frontmatter-range, phase-FF, ceremony-over-work 등)은 제외

---

### 2026-05-28 — phase-19 spec-19-01/02/03 인제스트

- **대상**: specs/spec-19-01-wiki-layer-bootstrap, specs/spec-19-02-hk-wiki-ingest, specs/spec-19-03-doctor-wiki-slim
- **갱신된 wiki 페이지**: decisions.md, patterns.md
- **추가된 내용 요약**:
  - decisions.md: [[ADR-003]] wiki `kind:` vs ADR `type:` 네임스페이스 분리 결정 추가
  - patterns.md: `bash-pipeline-sigpipe-trap` (SIGPIPE 오탐) + `frontmatter-range-grep` (frontmatter 범위 파싱) 신규 패턴 2개 추가
  - spec-19-02/03의 기술적 발견 (install 경로, SDD_ROOT 재정의 불가)은 spec 수준 메모로 보존, wiki 보편화 불필요

---

### 2026-05-27 — 초기 부트스트랩

- **대상**: ADR-001, ADR-002, RCA-001 (기존 문서 합성)
- **갱신된 wiki 페이지**: decisions.md, patterns.md, index.md
- **추가된 내용 요약**:
  - decisions.md: ADR-001(5어휘 closure), ADR-002(Planning Economy), RCA-001(sdd ship 버그) 초기 증류
  - patterns.md: phase-08~18에서 확인된 good pattern 5개 + anti-pattern 3개 초기 기록
  - spec-19-01 wiki-layer-bootstrap 작업의 일환으로 수동 생성
