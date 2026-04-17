# refactor(spec-07-004): standardize pr/push confirm ux across all commands

## 📋 Summary

### 배경 및 목적

PR 생성 및 Push 전 에이전트가 보여주는 정보와 확인 방식이 커맨드마다 달라 신뢰감이 떨어졌습니다. 고정 형식의 확인 블록과 통일된 긍정/거부 규칙을 전체 커맨드에 적용합니다.

### 주요 변경 사항

- [x] `hk-gh-pr.md` — PR 확인 블록 (브랜치/제목/커밋 수/파일 변경) + `[Y/n]` + `--no-confirm`
- [x] `hk-handoff.md` — Push 확인 블록 고정 형식 + 동일 규칙
- [x] `hk-bb-pr.md` — 동일 확인 블록 형식 적용
- [x] `hk-spec-critique.md` — 반영 항목 선택 프롬프트에 긍정/거부 규칙 명시

### 긍정/거부 규칙 (전체 공통)

- **긍정**: 거부 표현 외 모든 응답 (엔터, `Y`, `ok`, `go`, `ㅇㅇ`, `해`, `.` 등)
- **거부**: `n`, `no`, `아니`, `취소`, `cancel`
- **`--no-confirm`**: 확인 블록 생략 (자동화 시나리오용)

### Phase 컨텍스트

- **Phase**: `phase-07` — SDD 프로세스 일관성 및 품질 강화
- **본 SPEC의 역할**: 에이전트 반복 행동(PR/Push 확인) 표준화 — 마지막 phase-07 spec

## 🎯 Key Review Points

1. **확인 블록 4개 항목**: 브랜치, 제목, 커밋 수, 파일 변경 수 — 항상 표시
2. **긍정 응답 범위**: "거부 표현 외 모든 응답"으로 정의 — 목록 기반이 아닌 opt-out 방식
3. **`--no-confirm`**: 자동화/반복 사용 시 마찰 최소화

## 🧪 Verification

### 수동 검증 시나리오

1. `hk-gh-pr.md §4` → 확인 블록 + 긍정/거부 규칙 + `--no-confirm` 존재 확인 ✅
2. `hk-handoff.md §4` → Push 확인 블록 고정 형식 존재 확인 ✅
3. `hk-bb-pr.md §3` → 동일 확인 블록 존재 확인 ✅
4. `hk-spec-critique.md §4` → 긍정/거부 규칙 명시 확인 ✅

## 📦 Files Changed

### 🛠 Modified Files

- `sources/commands/hk-gh-pr.md` (+18, -2): PR 확인 블록 + 규칙 추가
- `.claude/commands/hk-gh-pr.md` (+18, -2): 동일 반영
- `sources/commands/hk-handoff.md` (+14, -4): Push 확인 블록 교체
- `.claude/commands/hk-handoff.md` (+14, -4): 동일 반영
- `sources/commands/hk-bb-pr.md` (+19, -2): 확인 블록 추가
- `.claude/commands/hk-bb-pr.md` (+19, -2): 동일 반영
- `sources/commands/hk-spec-critique.md` (+1): 긍정/거부 규칙 추가
- `.claude/commands/hk-spec-critique.md` (+1): 동일 반영

**Total**: 8 files changed

## ✅ Definition of Done

- [x] `hk-gh-pr.md` PR 확인 블록 + `--no-confirm` 완료
- [x] `hk-handoff.md` Push 확인 블록 표준화 완료
- [x] `hk-bb-pr.md` 동일 형식 적용 완료
- [x] `hk-spec-critique.md` 긍정/거부 규칙 적용 완료
- [x] walkthrough.md / pr_description.md archive 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-07.md`
- Walkthrough: `specs/spec-07-004-pr-confirm-ux/walkthrough.md`
