# refactor(spec-23-01): 외부 확장 조건부 우선 사용 거버넌스 + 권장 유도

## 📋 Summary

### 배경 및 목적
`/hk-extend` 로 Serena(LSP 코드 인텔리전스 MCP)를 붙일 수 있으나, 설치돼도 에이전트가 자발적으로 쓰지 않아(설치 ≠ 사용) 가치를 못 냈다. 동시에 키트는 "컨텍스트 비용 0 우선(MCP 최후)"(CLAUDE.md #2) 원칙이 있다. 본 PR 은 이 둘을 **조건부 우선 사용**(설치됨 + 그 도구의 강점 영역일 때 우선)으로 화해시키고, extend 를 권장 톤으로 전환하며, 코드 프로젝트에서 미설치 시 `sdd status` 가 1줄 권장을 띄운다.

### 주요 변경 사항
- [x] **ADR-008** (tradeoff): MCP 상시비용 vs 컨텍스트 절감 — 조건부 우선 사용 채택 근거
- [x] **agent.md §6.5**: "Extension-First (conditional)" 규칙 추가 (영어, sources 미러)
- [x] **hk-extend**: opt-in 유지하되 LSP 코드 프로젝트엔 설치 권장 톤
- [x] **sdd drift**: `_drift_extension_recommend()` — 코드 프로젝트 + 미설치 시 1줄 권장

### Phase 컨텍스트
- **Phase**: `phase-23` (extension-first) 의 단일 spec
- **역할**: "외부 확장을 권장 + 우선 사용"으로의 전환을 거버넌스·도구·UX 에 일관 반영.

## 🎯 Key Review Points

1. **조건부 프레이밍**: "무조건"이 아님. 비-LSP/단순 작업엔 원칙 #2 가 그대로 적용 — agent.md 규칙 + ADR-008 의 Alternatives 참조.
2. **overfit 회피**: detection 은 LSP 언어 tracked 파일 + 미설치 둘 다 만족 시에만 발동. 본 저장소(bash + serena 설치)에선 미출력 — 자기과적합 없음.
3. **미러 무결성**: agent.md / sdd / hk-extend.md 3쌍 모두 byte-identical.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-drift-extension-recommend.sh
bash tests/run.sh --fast
```

**결과 요약**:
- ✅ T1 코드+미설치 → 권장 출력
- ✅ T2 비코드 → 무출력
- ✅ T3 설치됨 → 무출력
- ✅ 미러 3쌍 `diff -q` 동일

### 수동 검증 시나리오
1. 본 저장소 `sdd status` → 권장 라인 0 (serena 설치됨 + bash) → 정상

## 📦 Files Changed

### 🆕 New Files
- `docs/decisions/ADR-008-extension-preferential-use.md`: 조건부 우선 사용 결정 (tradeoff)
- `tests/test-drift-extension-recommend.sh`: drift 권장 감지 3 시나리오

### 🛠 Modified Files
- `.harness-kit/agent/agent.md` + `sources/governance/agent.md`: Extension-First 규칙
- `.claude/commands/hk-extend.md` + `sources/commands/hk-extend.md`: 권장 톤
- `.harness-kit/bin/sdd` + `sources/bin/sdd`: `_drift_extension_recommend()`
- `backlog/phase-23.md`, `specs/spec-23-01-prefer-extensions/*`: SDD 산출물

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] 미러 3쌍 byte-identical
- [x] 하드 워드 버짓(8000) 미만 (7786w; 7000 soft-warn 은 사전 존재 → Icebox)
- [x] walkthrough / pr_description ship commit

## 🔗 관련 자료

- ADR: `docs/decisions/ADR-008-extension-preferential-use.md`
- Spec: `specs/spec-23-01-prefer-extensions/spec.md`
- Phase: `backlog/phase-23.md`
