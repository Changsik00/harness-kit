# refactor(spec-07-003): standardize plan accept prompt and allowed responses

## 📋 Summary

### 배경 및 목적

Plan Accept 요청 시 에이전트마다 표현이 달라 사용자가 어떻게 응답해야 할지 혼란이 있었습니다. 허용 응답 목록을 `constitution.md` SSOT로 정의하고, 선택 프롬프트 순서와 형식을 표준화합니다.

### 주요 변경 사항

- [x] `constitution.md §4.2` — Plan Accept 허용 응답 목록 (SSOT) + Critique 진입 규칙 + 목록 외 응답 재요청 규칙 추가
- [x] `agent.md §4.4` — 선택 프롬프트 순서 변경 (1=Plan Accept, 2=Critique) + 슬래시 커맨드 병기 + constitution §4.2 참조
- [x] `hk-plan-accept.md` — 중복 목록 제거, constitution §4.2 참조로 대체

### Phase 컨텍스트

- **Phase**: `phase-07` — SDD 프로세스 일관성 및 품질 강화
- **본 SPEC의 역할**: 에이전트의 반복 행동(Plan Accept 요청) 표준화 — 사용자 응답 혼란 해소

## 🎯 Key Review Points

1. **SSOT 구조**: 허용 응답 목록이 `constitution.md §4.2` 한 곳에만 정의됨. `agent.md`와 `hk-plan-accept.md`는 참조만 함 — 향후 목록 변경 시 한 곳만 수정
2. **프롬프트 순서 변경**: spec-07-002에서 Critique를 1번으로 정의했으나, 기본 경로(Plan Accept)를 1번으로 변경 — 사용자 피드백 반영
3. **목록 외 응답 규칙**: "ㅇㅇ", "진행해" 등 모호한 응답 시 에이전트가 재요청하도록 명시

## 🧪 Verification

### 수동 검증 시나리오

1. **constitution.md §4.2** → 허용 목록 + 재요청 규칙 존재 확인 ✅
2. **agent.md §4.4** → 1=Plan Accept, 2=Critique 순서 + constitution 참조 확인 ✅
3. **hk-plan-accept.md** → constitution §4.2 참조 한 줄 존재 확인 ✅

## 📦 Files Changed

### 🛠 Modified Files

- `sources/governance/constitution.md` (+6): §4.2 허용 응답 SSOT 규칙 추가
- `agent/constitution.md` (+6): 동일 반영
- `sources/governance/agent.md` (+5, -3): §4.4 프롬프트 순서 변경 + 참조
- `agent/agent.md` (+5, -3): 동일 반영
- `sources/commands/hk-plan-accept.md` (+2): constitution 참조 추가
- `.claude/commands/hk-plan-accept.md` (+2): 동일 반영

**Total**: 6 files changed

## ✅ Definition of Done

- [x] `constitution.md §4.2` 허용 응답 목록 (SSOT) 추가 완료
- [x] `agent.md §4.4` 프롬프트 순서 및 형식 표준화 완료
- [x] `hk-plan-accept.md` 참조 방식으로 대체 완료
- [x] walkthrough.md / pr_description.md archive 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-07.md`
- Walkthrough: `specs/spec-07-003-plan-accept-consistency/walkthrough.md`
- 참고: spec-07-002 (`sources/governance/agent.md §4.4` 원본 정의)
