# fix(spec-x-drift-stale-adr-glob): exclude glob tokens from stale ADR check

## 📋 Summary

### 배경 및 목적
`sdd status` 의 drift 섹션에 있는 `_drift_stale_adr()` 는 ADR 본문의 backtick 경로 토큰을 추출해 실제 파일 존재를 검사한다. 그런데 `docs/wiki/*.md`, `docs/decisions/ADR-*.md` 같은 **설명용 glob 패턴** 을 리터럴 파일로 오인해, 내용에 문제가 없는 `ADR-003` 을 매번 `stale ADR: 1 (missing-path)` 로 오탐했다. 본 PR 은 glob 메타문자(`*`, `?`) 포함 토큰을 검사에서 제외한다.

### 주요 변경 사항
- [x] `_drift_stale_adr()` 토큰 필터에 glob 제외 규칙 추가 (`*`, `?` 포함 토큰 skip)
- [x] `.harness-kit/bin/sdd` 와 `sources/bin/sdd` byte-identical 미러 적용
- [x] glob-only fixture(ADR-997) 회귀 테스트 케이스 추가

### Phase 컨텍스트
- **Phase**: 없음 (spec-x — 독립 fix)
- **본 SPEC 의 역할**: drift 진단 신호의 정확도 회복 — 거짓 경고 제거로 진짜 stale ADR 가시성 확보.

## 🎯 Key Review Points

1. **glob 제외 범위**: `[*?]` 만 대상. `[...]` 문자 클래스는 실제 경로에서도 쓰일 수 있어 과배제 방지를 위해 제외하지 않음.
2. **미러 정합성**: 두 `sdd` 파일이 byte-identical 이어야 함 (`diff -q` exit 0). install-manifest-sync 회귀 없음 확인됨.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-drift-stale-adr.sh
```

**결과 요약**:
- ✅ clean state: no stale ADR line
- ✅ fixture ADR (1 missing path) → stale ADR: 1 detected
- ✅ regression: ADR-998 (all-valid-paths) → no stale line
- ✅ glob fixture: ADR-997 (glob-only) → no stale line

### 수동 검증 시나리오
1. **시나리오 1**: `HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status` → `stale ADR` 라인 사라짐
2. **시나리오 2**: `diff -q .harness-kit/bin/sdd sources/bin/sdd` → 동일(exit 0)

## 📦 Files Changed

### 🛠 Modified Files
- `.harness-kit/bin/sdd` (+2, -0): `_drift_stale_adr()` glob 제외 한 줄
- `sources/bin/sdd` (+2, -0): 동일 미러
- `tests/test-drift-stale-adr.sh` (+29, -1): glob fixture 회귀 케이스

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
- [x] 미러 byte-identical 확인

## 🔗 관련 자료

- Spec: `specs/spec-x-drift-stale-adr-glob/spec.md`
- Walkthrough: `specs/spec-x-drift-stale-adr-glob/walkthrough.md`
- 관련 ADR: `docs/decisions/ADR-003-wiki-frontmatter-schema.md` (오탐 대상 — 내용 변경 없음)
