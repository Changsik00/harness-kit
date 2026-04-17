# feat(spec-09-13): Plan Accept → PR 자동 진행 (auto-ship)

## 📋 Summary

### 배경 및 목적

Plan Accept 후 Ship 단계에서 push/PR 생성마다 사용자 확인을 받아 흐름이 끊겼다. Plan Accept로 이미 위임된 범위 내에서 기계적 단계(push, PR)까지 자동 진행하여 워크플로 연속성을 확보한다.

### 주요 변경 사항

- [x] 거버넌스: Plan Accept의 위임 범위에 push + PR 생성 포함 (agent.md, constitution.md)
- [x] hk-ship: push 확인 블록 → 정보 표시 + 자동 진행, PR 자동 생성
- [x] 안전장치 유지: 테스트/archive/push 실패 시에만 멈춤

### Phase 컨텍스트

- **Phase**: `phase-09`
- **본 SPEC의 역할**: SDD 워크플로의 마찰 제거 — Plan Accept부터 PR 생성까지 원스톱

## 🧪 Verification

### 수동 검증 시나리오

1. agent.md에서 "always requires explicit user confirmation" → 0건
2. constitution.md에서 "MUST obtain explicit User confirmation before executing" (PR 관련) → 0건
3. hk-ship.md에서 "push 할까요?" → 0건

## 📦 Files Changed

### 🛠 Modified Files

- `sources/governance/agent.md`: §6.1, §6.3 auto-ship 규칙
- `sources/governance/constitution.md`: §7.1, §10.2 위임 범위 확장
- `sources/commands/hk-ship.md`: push/PR 자동 진행
- `.harness-kit/agent/agent.md`: 도그푸딩 동기화
- `.harness-kit/agent/constitution.md`: 도그푸딩 동기화
- `.claude/commands/hk-ship.md`: 도그푸딩 동기화

**Total**: 6 files changed
