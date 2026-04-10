# Walkthrough: spec-2-002

> CLAUDE.md 2단계 로딩 전략 증거 로그.

## 📋 실제 구현된 변경사항

- [x] `sources/claude-fragments/CLAUDE.md.fragment`에서 `@agent/` import 3줄 제거
- [x] 안내 문구를 "SDD 작업 시작 시 `/align` 호출하면 전체 거버넌스 로드"로 변경
- [x] `CLAUDE.md` 본체 HARNESS-KIT 블록 동기화
- [x] `/align` 커맨드는 변경 없음 (이미 @import로 전체 로드)

## 🧪 검증 결과

### 1. 자동화 테스트

#### 단위 테스트
- **명령**: `bash tests/test-two-tier-loading.sh`
- **결과**: ✅ Passed (7/7 checks)
- **로그 요약**:
```text
Check 1: fragment @import 없음 ✅
Check 2: CLAUDE.md HARNESS-KIT 블록 @import 없음 ✅
Check 3: align 커맨드 @import 유지 (constitution, agent, align) ✅✅✅
Check 4: fragment 124w ≤ 150w ✅
Check 5: 핵심 규칙 요약 유지 ✅
```

### 2. 수동 검증

1. **Action**: fragment word count 확인
   - **Result**: 124 words (기존 ~180 words에서 감소)
2. **Action**: `/align` 미호출 시 자동 로드 토큰 추정
   - **Result**: CLAUDE.md 본문 ~400w + HARNESS-KIT ~124w = ~524w (목표 ~500w 달성)

## 🔍 발견 사항

- @import 제거로 인한 토큰 절감: ~2,713w (constitution + agent.md + align.md)
- 비-align 세션 토큰: ~3,200w → ~524w (**84% 감소**)

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + Dennis |
| **작성 기간** | 2026-04-10 |
| **최종 commit** | `b77a5a5` |
