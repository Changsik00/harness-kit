# docs(spec-19-01): 문서 위키 레이어 설계 & 부트스트랩

## 📋 Summary

### 배경 및 목적
111개+ archived spec, ADR 2개, RCA 1개가 연결 없이 쌓여 있어 새 세션마다 결정 맥락을 재탐색해야 했다. Karpathy의 LLM Wiki 패턴을 차용해 `docs/wiki/` 지식 증류 레이어를 신설한다.

### 주요 변경 사항
- [x] `docs/wiki/` 신설 — `purpose.md`(스키마), `index.md`(카탈로그), `log.md`(이력), `decisions.md`(결정 증류), `patterns.md`(패턴 증류) 5개 파일
- [x] YAML frontmatter 스키마 확립 — wiki: `kind: catalog|synthesis`, `sources[]`, `linked[]`, `updated`
- [x] 기존 ADR-001, ADR-002, RCA-001 frontmatter에 `sources[]`, `linked[]`, `updated` backfill
- [x] `tests/test-wiki-structure.sh` — 32개 assertions, 32/32 PASS
- [x] ADR-001 `type:` 어휘와 wiki `kind:` 의 네임스페이스 분리 확립

### Phase 컨텍스트
- **Phase**: `phase-19` — 문서 지식 그래프 (Doc Knowledge Graph)
- **본 SPEC 의 역할**: wiki layer 기반 확립. spec-19-02의 `/hk-wiki-ingest` 커맨드와 템플릿 연동이 이 구조 위에서 동작함.

## 🎯 Key Review Points

1. **`kind:` vs `type:` 분리** (`docs/wiki/purpose.md`): ADR-001의 5어휘 closure는 ADR/RCA 전용. wiki 페이지는 `kind:` 사용해 `grep "^type:"` 쿼리 오염 방지. ADR-003으로 명문화 예정.
2. **decisions.md / patterns.md 증류 범위** (`docs/wiki/`): 전체 INDEX가 아닌 핵심만. ADR-001/002, RCA-001 합성. 패턴 5개 + anti-pattern 3개. `/hk-wiki-ingest`로 점진 누적 설계.
3. **테스트 frontmatter 파싱** (`tests/test-wiki-structure.sh`): `grep "^kind:"` 대신 awk로 frontmatter 범위 한정 — 본문에 스키마 예시가 있는 파일(purpose.md)에서 false positive 방지.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-wiki-structure.sh
```

**결과 요약**:
- ✅ Check 1: docs/wiki/ 존재
- ✅ Check 2: 필수 5개 파일 존재
- ✅ Check 3: frontmatter 유효성 (kind/sources/updated) — 15/15
- ✅ Check 4: kind 값 유효 (catalog|synthesis) — 5/5
- ✅ Check 5: ADR/RCA backfill (sources/updated) — 6/6
- **총계**: 32/32 PASS

### 수동 검증 시나리오
1. **Obsidian vault 열기** (docs/ 디렉토리): `[[wiki/decisions]]` 클릭 → decisions.md 탐색 가능
2. **grep 분리 확인**: `grep -rh "^type:" docs/decisions docs/rca` → ADR-001 어휘만 출력; `grep -rh "^kind:" docs/wiki` → catalog/synthesis만 출력

## 📦 Files Changed

### 🆕 New Files
- `docs/wiki/purpose.md`: wiki 목적·스키마·컨벤션 정의
- `docs/wiki/index.md`: wiki 카탈로그 + ADR/RCA 인벤토리
- `docs/wiki/log.md`: 인제스트 이벤트 이력
- `docs/wiki/decisions.md`: ADR-001, ADR-002, RCA-001 핵심 증류
- `docs/wiki/patterns.md`: good pattern 5개 + anti-pattern 3개 증류
- `tests/test-wiki-structure.sh`: wiki 구조 검증 테스트 (32 assertions)

### 🛠 Modified Files
- `docs/decisions/ADR-001-knowledge-types.md`: frontmatter `sources`, `linked`, `updated` 추가
- `docs/decisions/ADR-002-planning-economy.md`: frontmatter `sources`, `linked`, `updated` 추가
- `docs/rca/RCA-001-sdd-ship-spec-add-missing.md`: frontmatter `sources`, `linked`, `updated` 추가

**Total**: 9 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (32/32 PASS)
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-19.md`
- Walkthrough: `specs/spec-19-01-wiki-layer-bootstrap/walkthrough.md`
- 참조 ADR: `docs/decisions/ADR-001-knowledge-types.md`, `docs/decisions/ADR-002-planning-economy.md`
