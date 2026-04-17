# feat(spec-11-005): /hk-archive 슬래시 커맨드

## 📋 Summary

### 배경 및 목적
`sdd archive` 기능(spec-11-003)에 대응하는 슬래시 커맨드가 없어 `/hk-*` 에코시스템과 불일치.

### 주요 변경 사항
- [x] `/hk-archive` 슬래시 커맨드 생성: dry-run 미리보기 → 확인 → 실행 UX
- [x] `--keep=N` 옵션 안내 포함

### Phase 컨텍스트
- **Phase**: `phase-11` — 식별자 체계 개선 및 디렉토리 아카이브

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/hk-archive.md`: 슬래시 커맨드 정의
- `.claude/commands/hk-archive.md`: 도그푸딩 동기화

**Total**: 2 files added

## ✅ Definition of Done

- [x] 슬래시 커맨드 생성
- [x] `walkthrough.md` ship commit 완료
- [x] `pr_description.md` ship commit 완료
