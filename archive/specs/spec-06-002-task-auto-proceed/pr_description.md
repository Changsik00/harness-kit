# refactor(spec-06-002): Task 자동 진행 규칙 변경

## 📋 Summary

### 배경 및 목적
Strict Loop에서 매 task 완료 시마다 사용자 "ok" 입력을 기다리는 것은 이슈 없는 경우 불필요한 지연. "이슈 없으면 자동 진행, 이슈 시 멈추고 보고"로 변경하여 작업 효율을 높인다.

### 주요 변경 사항
- [x] `sources/governance/agent.md` §6.1 — Auto-proceed or Stop 규칙으로 변경
- [x] `sources/governance/align.md` — Strict Loop 설명 갱신
- [x] `agent/agent.md`, `agent/align.md` — 도그푸딩 반영

### Phase 컨텍스트
- **Phase**: `phase-06` (SDD UX 개선 및 커맨드 정리)

## 🎯 Key Review Points

1. **Hand-off 안전장치**: push/PR 전에는 반드시 사용자 확인이 유지되는지
2. **이슈 판단 기준**: 테스트 실패, 예상치 못한 에러, 범위 벗어남

## 📦 Files Changed

### 🛠 Modified Files (4)
- `sources/governance/agent.md`: §6.1 7번 단계 변경
- `sources/governance/align.md`: Strict Loop 설명 변경
- `agent/agent.md`: 도그푸딩 반영
- `agent/align.md`: 도그푸딩 반영

**Total**: 4 files changed
