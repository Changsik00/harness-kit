# fix(spec-1-001): 권한 프롬프트 마찰 해소

## 📋 Summary

### 배경 및 목적
도그푸딩 세션에서 에이전트가 복합 명령(`||`, `&&`, 따옴표 포함)을 전송하여 Claude Code의 안전 검사에 걸리고, settings.json에 이미 허용된 명령인데도 불필요한 권한 프롬프트가 반복되는 문제 해결.

### 주요 변경 사항
- [x] agent.md에 "Bash Single-Command Principle" 규칙 추가 — 복합 명령 생성 자체를 방지
- [x] `sdd status`에 자체 폴백 로직 내장 — 에이전트가 체이닝할 필요 제거
- [x] settings.json.fragment 중복 allow 규칙 4건 제거 (./scripts/ vs scripts/)
- [x] `/align` 커맨드에서 복합 폴백 블록을 단일 `sdd status` 호출로 대체

### Phase 컨텍스트
- **Phase**: `phase-1` (설치/운영 마찰 해소)
- **본 SPEC 의 역할**: 도그푸딩 시 가장 먼저 체감되는 UX 마찰(불필요한 권한 프롬프트)을 제거하여 워크플로 신뢰도 향상

## 🎯 Key Review Points

1. **agent.md §6.4 Single-Command Principle**: 에이전트의 Bash 호출에 `||`, `&&`, `;` 체이닝을 금지하는 새 규칙. 파이프(`|`)는 허용. 에이전트 효율에 미치는 영향 검토 필요.
2. **sdd status 폴백**: state 파일 미존재 시 git log + backlog + specs 디렉토리를 자체적으로 출력. JSON 모드에서도 `"fallback": true` 플래그 포함.

## 🧪 Verification

### 수동 검증 시나리오
1. **폴백 테스트**: state 파일 삭제 후 `sdd status` → git log, backlog, specs 정상 출력 ✅
2. **중복 규칙 검증**: `grep -c "scripts/harness"` → permissions 4개 (중복 없음) ✅
3. **JSON 폴백**: state 파일 없이 `--json` → fallback:true 포함 출력 ✅

## 📦 Files Changed

### 🛠 Modified Files
- `sources/governance/agent.md` (+9): §6.4 Single-Command Principle 추가
- `agent/agent.md` (+9): 도그푸딩 반영
- `sources/bin/sdd` (+25, -8): cmd_status() 폴백 로직
- `scripts/harness/bin/sdd` (+25, -8): 도그푸딩 반영
- `sources/claude-fragments/settings.json.fragment` (+0, -4): 중복 규칙 제거
- `.claude/settings.json` (+0, -4): 도그푸딩 반영
- `sources/commands/align.md` (+4, -10): 단일 호출로 변경
- `.claude/commands/align.md` (+4, -10): 도그푸딩 반영
- `sources/governance/align.md` (+3, -5): 폴백 예시 단순화
- `agent/align.md` (+3, -5): 도그푸딩 반영

**Total**: 10 files changed

## ✅ Definition of Done

- [x] 수동 검증 통과 (폴백 + 중복 제거 + JSON)
- [x] `walkthrough.md` archive commit 완료
- [x] `pr_description.md` archive commit 완료
- [x] 사용자 검토 요청 알림 완료

## 🔗 관련 자료

- Phase: `backlog/phase-1.md`
- Walkthrough: `specs/spec-1-001-permission-friction/walkthrough.md`
- 회고 문서: `docs/retrospective-2026-04-10-dogfooding-v1.md`
