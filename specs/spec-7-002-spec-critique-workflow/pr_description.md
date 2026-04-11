# feat(spec-7-002): add hk-spec-critique slash command for spec quality review

## 📋 Summary

### 배경 및 목적

Spec 작성이 단일 모델 단일 시각으로만 진행되어 요구사항 품질이 검증되지 않았습니다. Plan Accept 전에 독립적인 Opus 서브에이전트가 spec.md를 비판하는 `/hk-spec-critique` 커맨드를 추가합니다.

### 주요 변경 사항

- [x] `sources/commands/hk-spec-critique.md` 신설 — 유사 기법 조사 + 요구사항 비판 + 대안 2~3개 제안
- [x] `agent.md §4.5` 추가 — Plan Accept 전 선택적 critique 단계 공식화
- [x] `spec.md` 템플릿에 `## 🔍 Critique 결과` 섹션 추가 (선택 작성)

### Phase 컨텍스트

- **Phase**: `phase-7` — SDD 프로세스 일관성 및 품질 강화
- **본 SPEC의 역할**: 설계 품질 향상 — `hk-code-review`(구현 후)와 대칭되는 설계 전 비판 단계

## 🎯 Key Review Points

1. **`hk-spec-critique` 커맨드 구조**: Opus 서브에이전트에게 3가지 관점(유사 기법/요구사항 비판/대안 제안) 지시. `hk-code-review`와 동일한 서브에이전트 패턴 사용
2. **선택성 보장**: §4.5는 Optional로 명시 — 호출하지 않아도 Plan Accept 진행 가능. 워크플로우 마찰 없음

## 🧪 Verification

```bash
ls sources/commands/hk-spec-critique.md
```

**결과**: 파일 존재 확인 ✅

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/hk-spec-critique.md`: Opus 서브에이전트 spec 비판 커맨드

### 🛠 Modified Files
- `sources/governance/agent.md` (+14): §4.5 Critique Step 추가
- `agent/agent.md` (+14): 동일 반영
- `sources/templates/spec.md` (+5): Critique 결과 섹션 추가
- `agent/templates/spec.md` (+5): 동일 반영

**Total**: 5 files changed

## ✅ Definition of Done

- [x] `hk-spec-critique.md` 커맨드 작성 완료
- [x] `agent.md §4.5` 추가 완료
- [x] spec 템플릿 Critique 섹션 추가 완료
- [x] walkthrough.md / pr_description.md archive 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-7.md`
- Walkthrough: `specs/spec-7-002-spec-critique-workflow/walkthrough.md`
- 참고: `sources/commands/hk-code-review.md` (구현 후 리뷰 — 대칭 커맨드)
