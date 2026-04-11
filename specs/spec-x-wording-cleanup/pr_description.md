# docs(spec-x-wording-cleanup): 커맨드·거버넌스 문서 워딩 최적화

## 📋 Summary

### 배경 및 목적

phase-4 ~ phase-7 에 걸쳐 점진적으로 추가된 슬래시 커맨드 9개와 거버넌스 파일 3개에 동일 개념에 대한 다른 표현이 혼재하게 되었습니다. 공통 워딩 통일, 언어 혼용 정리, 중복 제거, 누락 내용 추가를 한 번에 정비합니다.

### 주요 변경 사항

- [x] **긍정/거부 규칙 SSOT 참조**: `hk-gh-pr`, `hk-bb-pr`, `hk-handoff` 의 긍정/거부 예시 목록 제거 → `constitution §4.2` 참조 한 줄
- [x] **중복 제거**: `hk-handoff` §5-A·B 의 awk/bb-pr 코드 블록 → `/hk-gh-pr`, `/hk-bb-pr` 커맨드 참조로 대체
- [x] **Strict Loop 중복 제거**: `hk-plan-accept` §3 의 8단계 설명 → `agent.md §6.1` 참조 한 줄
- [x] **model 누락 보완**: `hk-code-review` 서브에이전트에 `model: "opus"` 추가 (hk-spec-critique 와 동일 수준)
- [x] **slug 인자 처리**: `hk-spec-new` 에 slug 인자 누락 시 안내 메시지 추가
- [x] **언어 혼용 정리**: `active spec/phase` → `활성 spec/phase`, `sub-agent` → `서브에이전트`, 커맨드명 오기 수정 (`/plan-accept` → `/hk-plan-accept`)
- [x] **constitution §4.2 제목**: `Plan Rules` → `Plan Accept & Critique 인식` (내용 반영)

### Phase 컨텍스트

- **Phase**: — (Solo Spec — 독립 docs 작업)
- **본 SPEC 의 역할**: 문서 일관성 확보로 에이전트의 오해/오작동 가능성 제거

## 🎯 Key Review Points

1. **긍정/거부 SSOT 참조**: 각 커맨드에서 예시 목록을 제거하고 constitution §4.2 만 참조하도록 했습니다. constitution §4.2 내용이 바뀌면 모든 커맨드에 자동 반영됩니다.
2. **`hk-code-review` model 추가**: 이전에는 model 지정 없이 서브에이전트를 호출했습니다. Opus 없이 code review 시 품질 저하 우려가 있어 명시했습니다.

## 🧪 Verification

### 자동 테스트

해당 없음 (docs-only 변경)

### 수동 검증 시나리오

1. **커맨드명 참조 일관성** → 모든 파일에서 `/hk-plan-accept`, `/hk-handoff`, `/hk-gh-pr`, `/hk-bb-pr` 정확히 사용 확인
2. **sources ↔ .claude/commands 쌍 일치** → 수정된 파일 12개 내용 일치 확인

## 📦 Files Changed

### 🛠 Modified Files

- `sources/commands/hk-gh-pr.md` + `.claude/commands/hk-gh-pr.md`: 도입 문장, 긍정/거부 참조
- `sources/commands/hk-bb-pr.md` + `.claude/commands/hk-bb-pr.md`: 도입 문장, 긍정/거부 참조
- `sources/commands/hk-handoff.md` + `.claude/commands/hk-handoff.md`: 도입 문장, §4 참조, §5-A·B 중복 제거
- `sources/commands/hk-plan-accept.md` + `.claude/commands/hk-plan-accept.md`: Strict Loop 축약, active → 활성
- `sources/commands/hk-code-review.md` + `.claude/commands/hk-code-review.md`: model 추가, 표현 통일
- `sources/commands/hk-spec-new.md` + `.claude/commands/hk-spec-new.md`: 인자 처리, active → 활성, 커맨드명 수정
- `sources/commands/hk-spec-critique.md` + `.claude/commands/hk-spec-critique.md`: active → 활성, 표현 통일
- `sources/commands/hk-spec-status.md` + `.claude/commands/hk-spec-status.md`: active → 활성, 커맨드명 수정
- `sources/commands/hk-align.md`: 커맨드명 수정
- `sources/governance/constitution.md` + `agent/constitution.md`: §4.2 제목 변경

**Total**: 6 commits, 13개 파일 변경

## ✅ Definition of Done

- [x] 8개 수정 항목 모두 반영
- [x] `sources/` 와 `.claude/commands/` 내용 일치
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Walkthrough: `specs/spec-x-wording-cleanup/walkthrough.md`
