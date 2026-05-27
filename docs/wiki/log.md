---
kind: catalog
sources: []
linked:
  - "[[wiki/index]]"
updated: 2026-05-27
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

### 2026-05-27 — 초기 부트스트랩

- **대상**: ADR-001, ADR-002, RCA-001 (기존 문서 합성)
- **갱신된 wiki 페이지**: decisions.md, patterns.md, index.md
- **추가된 내용 요약**:
  - decisions.md: ADR-001(5어휘 closure), ADR-002(Planning Economy), RCA-001(sdd ship 버그) 초기 증류
  - patterns.md: phase-08~18에서 확인된 good pattern 5개 + anti-pattern 3개 초기 기록
  - spec-19-01 wiki-layer-bootstrap 작업의 일환으로 수동 생성
