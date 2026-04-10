# refactor(spec-6-001): 슬래시 커맨드 `hk-` prefix 일괄 변경

## 📋 Summary

### 배경 및 목적
harness-kit이 설치하는 슬래시 커맨드와 사용자 커스텀 커맨드를 구분하기 위해, 모든 커맨드 파일명에 `hk-` prefix를 부여한다.

### 주요 변경 사항
- [x] `sources/commands/` 9개 파일 rename (`align.md` → `hk-align.md` 등)
- [x] `.claude/commands/` 9개 파일 rename (도그푸딩)
- [x] 거버넌스 문서 내 모든 커맨드 참조를 `hk-` prefix로 갱신
- [x] `install.sh`, `CLAUDE.md`, `CLAUDE.md.fragment` 참조 갱신

### Phase 컨텍스트
- **Phase**: `phase-6` (SDD UX 개선 및 커맨드 정리)

## 🎯 Key Review Points

1. **파일명 일관성**: 9개 커맨드 모두 `hk-` prefix가 붙었는지
2. **참조 무결성**: 구 이름(`/align`, `/plan-accept` 등)이 남아있지 않은지

## 📦 Files Changed

### 🔄 Renamed Files (18)
- `sources/commands/` 9개: `*.md` → `hk-*.md`
- `.claude/commands/` 9개: `*.md` → `hk-*.md`

### 🛠 Modified Files (7)
- `sources/governance/{align,constitution,agent}.md`: 커맨드 참조 갱신
- `agent/{align,constitution,agent}.md`: 커맨드 참조 갱신
- `sources/claude-fragments/CLAUDE.md.fragment`: 참조 갱신
- `install.sh`: 참조 갱신
- `CLAUDE.md`: 참조 갱신

**Total**: 25 files changed
