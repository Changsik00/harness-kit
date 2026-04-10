# feat(spec-4-002): /code-review 슬래시 커맨드 추가

## 📋 Summary

### 배경 및 목적
에이전트가 자기 코드를 자기가 검증하는 확인 편향을 완화하기 위해, 독립 sub-agent가 코드 변경을 리뷰하는 옵셔널 슬래시 커맨드를 추가한다. spec-4-001(`/spec-review`)이 기획 리뷰라면, 이 커맨드는 **코드 수준의 실질적 리뷰**에 집중한다.

### 주요 변경 사항
- [x] `sources/commands/code-review.md` — `/code-review` 슬래시 커맨드 신규 생성
- [x] `.claude/commands/code-review.md` — 도그푸딩용 복사

### Phase 컨텍스트
- **Phase**: `phase-4` (옵셔널 Sub-agent 리뷰 시스템)
- **본 SPEC 의 역할**: phase-4의 두 번째 spec으로, 코드 수준 리뷰 기능을 제공

## 🎯 Key Review Points

1. **리뷰 관점 3개**: spec 대비 구현 검증, 코드 품질(KISS/DRY/feature envy), 테스트 커버리지 — 추상적이지 않고 코드 수준의 실질적 검증
2. **출력 형식**: `파일경로:라인번호` 참조를 필수로 하여 actionable한 리뷰 결과 생성

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/code-review.md`: /code-review 슬래시 커맨드 정의
- `.claude/commands/code-review.md`: 도그푸딩용 복사본

**Total**: 2 files changed

## ✅ Definition of Done

- [x] `sources/commands/code-review.md` 슬래시 커맨드 파일 작성
- [x] `.claude/commands/code-review.md`로 복사 확인
- [x] 파일 존재 + frontmatter 검증 통과
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료

## 🔗 관련 자료

- Phase: `backlog/phase-4.md`
- Walkthrough: `specs/spec-4-002-code-review-cmd/walkthrough.md`
