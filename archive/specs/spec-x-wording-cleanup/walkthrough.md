# Walkthrough: spec-x-wording-cleanup

> 본 문서는 *증거 로그* 입니다. "무엇을 했고 어떻게 검증했는지" 를 미래의 자신과 리뷰어에게 남깁니다.

## 📋 실제 구현된 변경사항

- [x] `hk-gh-pr`, `hk-bb-pr`: `본 명령은` → `이 명령은`, 긍정/거부 예시 목록 → constitution §4.2 참조 한 줄
- [x] `hk-handoff`: 도입 문장 재작성, §5-A·B awk/bb-pr 코드 블록 제거 (커맨드 참조로 대체), §4 긍정/거부 → constitution 참조
- [x] `hk-plan-accept`: Strict Loop 8단계 → `agent.md §6.1` 참조 한 줄, `active` → `활성`
- [x] `hk-code-review`: description `sub-agent` → `서브에이전트`, `model: "opus"` 추가, 프롬프트 도입 문구 통일
- [x] `hk-spec-new`: slug 인자 누락 처리 추가, `active phase` → `활성 phase`, `/plan-accept` → `/hk-plan-accept`
- [x] `hk-spec-critique`, `hk-spec-status`: `active spec` → `활성 spec`, `/handoff` → `/hk-handoff`
- [x] `hk-align`: `/plan-accept` → `/hk-plan-accept`
- [x] `constitution.md`: §4.2 제목 `Plan Rules` → `Plan Accept & Critique 인식`
- [x] 위 모든 변경은 `sources/` + `.claude/commands/`(또는 `agent/`) 쌍으로 동기화

## 🧪 검증 결과

### 1. 자동화 테스트

docs-only 변경 — 자동화 테스트 없음 (Integration Test Required = no)

### 2. 수동 검증

1. **`git diff main...HEAD --stat`** 확인 → 변경 파일 12개, 대상 파일 외 변경 없음
2. **긍정/거부 규칙 참조 위치** 확인 → `constitution.md §4.2` 절 제목이 내용과 일치하는지 검토
3. **`sources/` ↔ `.claude/commands/` 쌍 일치** 확인 → 각 수정 파일의 내용 동일함
4. **커맨드 이름 참조** 확인 → `/plan-accept` → `/hk-plan-accept`, `/handoff` → `/hk-handoff` 모두 반영

## 🔍 발견 사항

- `hk-align.md` 는 `.claude/commands/` 에 없고 skill 로만 관리됨 — sources 만 수정. 이 구조는 이전부터 의도된 것으로 보임.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-04-11 |
| **최종 commit** | `0bb8398` |
