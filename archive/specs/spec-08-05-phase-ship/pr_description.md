# feat(spec-08-05): add phase ship procedure and template

## 📋 Summary

### 배경 및 목적

Phase PR(phase branch → main)을 에이전트가 Spec PR 나열만으로 자동 생성하려 한 문제 발견. Phase PR은 "코드가 맞는가?"가 아닌 "이 기능이 배포 가능한가?"를 판단하는 품질 게이트여야 함. 업계 Release Readiness Review 패턴을 참고하여 표준 절차를 정의.

### 주요 변경 사항
- [x] `/hk-phase-ship` 슬래시 커맨드: 5단계 절차 (Pre-check → 성공기준 검증 → 통합테스트 → go/no-go → PR 생성)
- [x] `phase-ship.md` 템플릿: Overview/Scope/Criteria/Tests/Decisions/Issues/Follow-up 구조
- [x] constitution.md §3.1: Phase Ship Rule — 사용자 go/no-go 없이 Phase PR 생성 금지
- [x] agent.md §3.1 + §6.3: Work Type Table 및 Completion Checklists 갱신

### Phase 컨텍스트
- **Phase**: `phase-08`
- **본 SPEC 의 역할**: Phase Ship 절차 표준화. 이 spec merge 후 `/hk-phase-ship`을 phase-08 자체에 적용하여 도그푸딩 검증.

## 🎯 Key Review Points

1. **5단계 절차**: Spec Ship(`/hk-ship`)이 archive → push → PR인 것과 달리, Phase Ship은 검증 → 보고 → 승인 → PR 순서. 에이전트가 자동 진행할 수 없는 구조.
2. **Go/No-Go 강제**: constitution에 명문화하여 에이전트가 우회할 수 없도록 함.
3. **템플릿 품질**: 업계 Release Readiness Review (Google RRR, Stripe Launch Checklist) 패턴 차용.

## 📦 Files Changed

### 🆕 New Files
- `sources/commands/hk-phase-ship.md`: Phase Ship 슬래시 커맨드
- `sources/templates/phase-ship.md`: Phase PR 본문 템플릿
- `agent/templates/phase-ship.md`: 위 동기화

### 🛠 Modified Files
- `sources/governance/constitution.md` + `agent/constitution.md`: Phase Ship Rule
- `sources/governance/agent.md` + `agent/agent.md`: §3.1 + §6.3 갱신

**Total**: 7 files changed

## ✅ Definition of Done

- [x] `/hk-phase-ship` 슬래시 커맨드 작성 완료
- [x] `phase-ship.md` 템플릿 작성 완료
- [x] constitution + agent 규칙 추가 (영문)
- [x] walkthrough.md + pr_description.md archive 완료
- [x] 사용자 검토 요청 알림 완료
