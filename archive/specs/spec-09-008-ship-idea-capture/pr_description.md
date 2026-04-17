# feat(spec-09-008): 거버넌스 흐름 보호 (idea-guard)

## 📋 Summary

### 배경 및 목적

작업 중 새 아이디어 발생 시 문서화 없이 방향 전환하거나, 세션 간 미완 항목이 유실되는 문제를 거버넌스 규약으로 방지.

### 주요 변경 사항
- [x] constitution §5.5 **Idea Capture Gate**: 새 아이디어 → Icebox 기록 → "계속/전환" 선택지 제시, 문서화 없는 전환 금지
- [x] constitution §5.6 **Opinion Divergence Protocol**: 의견 충돌 시 명시 → 조율 → 기록
- [x] agent §2 **Context Continuity Check**: 세션 시작 시 미완 spec/icebox 항목 확인 + 알림

### Phase 컨텍스트
- **Phase**: `phase-09`
- **본 SPEC의 역할**: SDD 프로세스의 흐름 보호 — 아이디어 유실 방지 + 암묵적 방향 전환 차단

## 🎯 Key Review Points

1. **Idea Capture Gate 워딩**: "VIOLATION" 수준이 적절한지 (현재: 일반 VIOLATION, CRITICAL 아님)
2. **Context Continuity Check 범위**: "최근 세션의 Icebox 항목"을 감지하는 기준 — 현재 규약 수준이라 구체적 시간 기준 없음

## 🧪 Verification

### 수동 검증
1. `diff sources/governance/constitution.md .harness-kit/agent/constitution.md` → 차이 없음
2. `diff sources/governance/agent.md .harness-kit/agent/agent.md` → 차이 없음

## 📦 Files Changed

### 🛠 Modified Files
- `sources/governance/constitution.md` (+21): §5.5, §5.6 추가
- `sources/governance/agent.md` (+9, -2): §2 확장, §3 참조 추가
- `.harness-kit/agent/constitution.md` (+21): 동기화
- `.harness-kit/agent/agent.md` (+9, -2): 동기화

**Total**: 4 files changed

## ✅ Definition of Done

- [x] constitution.md §5.5, §5.6 추가
- [x] agent.md Bootstrap Protocol 확장
- [x] 도그푸딩 동기화 (diff 확인)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료

## 🔗 관련 자료

- Phase: `backlog/phase-09.md`
- Walkthrough: `specs/spec-09-008-ship-idea-capture/walkthrough.md`
