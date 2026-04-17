# refactor(spec-07-001): add work mode decision tree to constitution §2

## 📋 Summary

### 배경 및 목적

SDD/FF 분류 기준이 모호해 에이전트 판단이 매번 달랐습니다. SDD-x(Solo Spec)는 §4.1에만 존재해 Alignment 단계에서 자연스럽게 고려되지 않았고, 분류 근거가 응답에 드러나지 않아 사용자가 검증할 수 없었습니다.

### 주요 변경 사항

- [x] `constitution.md §2` — SDD를 SDD-P/SDD-x/FF 3모드로 재정의
- [x] `constitution.md §2.4` — 2단계 결정 트리 추가: PR 유무 → Phase 유무
- [x] `constitution.md §2.4` — Edge case 표 5개 추가
- [x] `agent.md §3` — Alignment Phase에 `[Classification]` 항목 추가 (분류 근거 명시 의무화)

### Phase 컨텍스트

- **Phase**: `phase-07` — SDD 프로세스 일관성 및 품질 강화
- **본 SPEC의 역할**: 모든 작업 분류 판단의 기준 확립 — 이후 spec들의 모드 선택 근거 제공

## 🎯 Key Review Points

1. **2단계 결정 트리 (§2.4)**: `PR 필요?` → `Phase 필요?` 의 단순한 2개 질문으로 3가지 모드를 완전히 구분. 기존 "non-trivial" 같은 주관적 표현 제거
2. **`[Classification]` 항목**: Alignment 응답에서 모드 선택 근거를 강제 노출 — 사용자가 판단을 검증 가능

## 🧪 Verification

### 수동 검증
- Edge case 5개를 결정 트리에 직접 적용 → 모두 올바른 모드로 분류 확인

## 📦 Files Changed

### 🛠 Modified Files
- `sources/governance/constitution.md` (+28, -8): §2 Work Modes 재정의
- `agent/constitution.md` (+28, -8): 동일 반영 (도그푸딩)
- `sources/governance/agent.md` (+5, -1): §3 Classification 항목 추가
- `agent/agent.md` (+5, -1): 동일 반영

**Total**: 4 files changed

## ✅ Definition of Done

- [x] constitution §2 결정 트리 추가
- [x] agent.md Classification 항목 추가
- [x] walkthrough.md archive commit 완료
- [x] pr_description.md archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-07.md`
- Walkthrough: `specs/spec-07-001-scope-classification-rules/walkthrough.md`
