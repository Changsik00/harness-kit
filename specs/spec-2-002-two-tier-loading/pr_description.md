# refactor(spec-2-002): CLAUDE.md 2단계 로딩 전략

## 📋 Summary

### 배경 및 목적
매 세션 CLAUDE.md가 `@import`로 거버넌스 3파일(~2,713w)을 전량 로드하여 토큰을 낭비. FF 모드나 단순 질문에서도 불필요하게 소모됨. 2단계 로딩으로 전환: Tier 1 (항상) = 핵심 요약 ~124w, Tier 2 (/align 시) = 전체 거버넌스 ~2,713w.

### 주요 변경 사항
- [x] `CLAUDE.md.fragment`에서 `@agent/` import 3줄 제거
- [x] `CLAUDE.md` 본체 동기화
- [x] `/align` 커맨드는 변경 없음 (이미 전체 로드 담당)

### Phase 컨텍스트
- **Phase**: `phase-2` — 토큰 최적화 & 거버넌스 경량화
- **본 SPEC 의 역할**: 비-align 세션 토큰 84% 절감 (~3,200w → ~524w)

## 🎯 Key Review Points

1. **@import 제거 안전성**: 핵심 규칙 요약 8줄이 비-align 세션에서 충분한 가드레일인지. hook(check-plan-accept, check-branch)이 여전히 기계적으로 강제하므로 실질적 위험 낮음.
2. **install.sh 호환성**: 새 프로젝트에 설치 시 fragment가 올바르게 적용되는지.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-two-tier-loading.sh
```

**결과 요약**:
- ✅ fragment/CLAUDE.md에 @import 없음
- ✅ align 커맨드에 @import 유지
- ✅ fragment 124w ≤ 150w
- ✅ 핵심 규칙 요약 유지

## 📦 Files Changed

### 🆕 New Files
- `tests/test-two-tier-loading.sh`: 2단계 로딩 검증 테스트 (7 checks)

### 🛠 Modified Files
- `sources/claude-fragments/CLAUDE.md.fragment` (+1, -5): @import 제거
- `CLAUDE.md` (+1, -5): HARNESS-KIT 블록 동기화

**Total**: 3 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (7/7)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-2.md`
- Walkthrough: `specs/spec-2-002-two-tier-loading/walkthrough.md`
