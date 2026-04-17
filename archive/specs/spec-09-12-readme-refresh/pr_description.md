# docs(spec-09-12): README v0.5.0 최신화

## 📋 Summary

### 배경 및 목적

README.md가 v0.3.0 기준으로 작성되어 있어, phase-09에서 변경된 `.harness-kit/` 디렉토리 레이아웃, `@import` 방식 CLAUDE.md, NOW/NEXT 제거 등이 반영되지 않았다.

### 주요 변경 사항

- [x] 버전 배지 `0.3.0` → `0.5.0`, 설치 레이아웃 트리 `.harness-kit/` 구조로 전면 교체
- [x] CLAUDE.md `@import` 방식, 경로 참조 일괄 교체, NOW/NEXT → `sdd status` 대체
- [x] 누락 항목 추가: `/hk-cleanup`, `--no-gitignore`, `cleanup.sh`, Post-Merge 흐름

### Phase 컨텍스트

- **Phase**: `phase-09`
- **본 SPEC의 역할**: phase-09 마지막 spec — 모든 변경사항을 README에 반영하여 문서 정합성 확보

## 🧪 Verification

### 수동 검증 시나리오

1. `grep "scripts/harness" README.md` → 0건
2. `.harness-kit/` prefix 없는 `agent/constitution` grep → 0건

## 📦 Files Changed

### 🛠 Modified Files

- `README.md` (+30, -25): v0.5.0 레이아웃/경로/워크플로 전면 갱신

**Total**: 1 file changed
