# fix(spec-09-010): 슬래시 커맨드 경로 일괄 수정

## 📋 Summary

### 배경 및 목적

spec-09-001에서 디렉토리 레이아웃을 `.harness-kit/`으로 변경했으나, 슬래시 커맨드 내부의 `scripts/harness/bin/sdd` 경로가 갱신되지 않아 커맨드 실행 시 에러 발생.

### 주요 변경 사항
- [x] `scripts/harness/bin/sdd` → `.harness-kit/bin/sdd` 일괄 치환 (12개 파일)

### Phase 컨텍스트
- **Phase**: `phase-09`
- **본 SPEC의 역할**: spec-09-001 누락분 수정

## 🧪 Verification

```bash
grep -r "scripts/harness/bin/sdd" sources/commands/ .claude/commands/
# 결과: 0건
```

## 📦 Files Changed

- `sources/commands/hk-ship.md`, `hk-plan-accept.md`, `hk-phase-ship.md`, `hk-code-review.md`, `hk-spec-critique.md`
- `.claude/commands/hk-ship.md`, `hk-plan-accept.md`, `hk-phase-ship.md`, `hk-code-review.md`, `hk-spec-critique.md`, `hk-align.md`, `hk-cleanup.md`

**Total**: 12 files changed
