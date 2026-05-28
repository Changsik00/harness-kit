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
