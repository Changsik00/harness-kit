# feat(spec-4-001): /spec-review 슬래시 커맨드 추가

## 📋 Summary

### 배경 및 목적
단일 에이전트의 확인 편향 문제를 완화하기 위해, 독립 sub-agent가 spec.md + plan.md를 비판적으로 리뷰하는 옵셔널 슬래시 커맨드를 추가한다. 사용자가 필요할 때만 호출하여 토큰 비용을 통제한다.

### 주요 변경 사항
- [x] `sources/commands/spec-review.md` — `/spec-review` 슬래시 커맨드 신규 생성
- [x] `.claude/commands/spec-review.md` — 도그푸딩용 복사

### Phase 컨텍스트
- **Phase**: `phase-4` (옵셔널 Sub-agent 리뷰 시스템)
- **본 SPEC 의 역할**: phase-4의 첫 번째 spec으로, spec/plan 리뷰 기능을 제공하여 독립 검증 체계의 기반을 마련

## 🎯 Key Review Points

1. **리뷰 프롬프트 품질**: sub-agent에게 전달되는 리뷰 관점 5개 항목(요구사항 빈틈, 모호한 DoD, 누락된 엣지 케이스, 과도한 범위, 아키텍처 리스크)이 실효성 있는지
2. **출력 형식**: review.md의 구조(요약 + 상세 + 권고사항)가 실제 의사결정에 유용한지

## 🧪 Verification

### 수동 검증 시나리오
1. **파일 존재**: `sources/commands/spec-review.md` 존재 확인 → OK
2. **Frontmatter**: `---` / `description:` / `---` 형식 확인 → OK
3. **도그푸딩**: `.claude/commands/spec-review.md` 존재 확인 → OK

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/spec-review.md`: /spec-review 슬래시 커맨드 정의
- `.claude/commands/spec-review.md`: 도그푸딩용 복사본

**Total**: 2 files changed

## ✅ Definition of Done

- [x] `sources/commands/spec-review.md` 슬래시 커맨드 파일 작성
- [x] `.claude/commands/spec-review.md`로 복사 확인
- [x] 파일 존재 + frontmatter 검증 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-4.md`
- Walkthrough: `specs/spec-4-001-spec-review-cmd/walkthrough.md`
