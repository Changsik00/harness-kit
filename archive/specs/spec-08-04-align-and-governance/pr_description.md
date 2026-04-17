# docs(spec-08-04): strengthen hk-align, add governance rules, and update README

## 📋 Summary

### 배경 및 목적

phase-08의 마지막 spec. hk-align에 NOW/NEXT 표시를 추가하고, agent.md에 작업 유형별 행동 규칙과 완료 체크리스트를 명문화한다. README를 phase-08 변경사항(작업 유형 모델, phase base branch, archive completion gate 등)으로 최신화한다.

### 주요 변경 사항
- [x] hk-align Step 4 상태 보고에 NOW/NEXT 행 추가
- [x] agent.md §3.1 Work Type Behavior Table (Phase/Spec/spec-x/FF/Icebox 각 행동)
- [x] agent.md §6.3 Completion Checklists (FF/spec-x/phase 완료 후 필수 행동)
- [x] "Hand-off" → "Ship" 용어 통일 (agent.md, task template)
- [x] README 전면 최신화 (작업 유형 모델, sdd 명령, 슬래시 커맨드, 워크플로, FAQ)

### Phase 컨텍스트
- **Phase**: `phase-08` (마지막 spec)
- **본 SPEC 의 역할**: phase-08 전체 변경사항을 거버넌스와 사용자 문서에 통합하여 마무리

## 🎯 Key Review Points

1. **Work Type Behavior Table**: constitution §3의 유형 정의를 agent.md에서 구체적 행동으로 연결. 에이전트가 "어떤 유형인지"뿐 아니라 "어떻게 행동해야 하는지"를 즉시 참조 가능.
2. **"Ship" 용어 통일**: 슬래시 커맨드가 `/hk-ship`인데 문서에서 "Hand-off"를 사용하던 불일치 해소.
3. **README 작업 유형 모델 섹션**: Phase base branch, NOW/NEXT/Icebox 등 phase-08의 핵심 개념을 사용자에게 설명.

## 🧪 Verification

### 수동 검증
1. hk-align.md ��맷 확인 → NOW/NEXT 행 포함
2. README sdd 명령 표 vs `sdd help` → 일치
3. README 슬래시 커맨드 표 vs `.claude/commands/` 파일 목록 → 7개 일치

## 📦 Files Changed

### 🛠 Modified Files
- `sources/commands/hk-align.md`: Step 4 NOW/NEXT 추가
- `sources/governance/agent.md` + `agent/agent.md`: §3.1 표 + §6.3 체크리스트
- `agent/templates/task.md` + `sources/templates/task.md`: Ship 용어 통일
- `README.md`: 전면 최신화

**Total**: 7 files changed

## ✅ Definition of Done

- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-08.md`
- Spec: `specs/spec-08-04-align-and-governance/spec.md`
