feat(spec-25-01): AskUserQuestion 리다이렉트 hook (auto 논블로킹 기계적 백스톱)

## 📋 Summary

### 배경 및 목적
phase-24 가 auto 모드를 구현했지만, 핵심 약속인 "결정 지점에서 안 멈춤"이 agent.md §8.4 **산문 한 줄**에만 의존했다. Claude Code 시스템 프롬프트는 결정 지점에서 `AskUserQuestion` 을 *권장*하므로, 에이전트가 습관적으로 한 번 물으면 unattended 세션이 그대로 멈춘다. spec-24-04 는 *"AskUserQuestion 은 hook 으로 못 막는다"* 고 결론냈으나, 이는 절반만 맞다 — PreToolUse hook 이 호출을 가로채 차단할 수 있다.

### 주요 변경 사항
- [x] `state.mode==auto` 에서 `AskUserQuestion` 호출을 PreToolUse hook 으로 차단(exit 2) + stderr 리다이렉트 지침
- [x] routine 결정 → 기본값+`sdd decision add` 후 진행 / 정지규칙 ① → `decision add "미해결" + 턴 종료` 로 분기 (멈춤의 두 종류 분리)
- [x] governed/turbo/mode 부재 → 무간섭(exit 0), fail-safe
- [x] 24-04 "hook 불가" 전제를 spike + 라이브로 실증 반증

### Phase 컨텍스트
- **Phase**: `phase-25` (auto 신뢰성)
- **본 SPEC 의 역할**: 사용자 우려 "askMode 때문에 멈추면 auto 가 의미 있나"의 직접 해법. auto 논블로킹을 산문에서 **기계적 백스톱**으로 격상.

## 🎯 Key Review Points

1. **block 기본의 예외성**: CLAUDE.md #5 "새 hook 은 경고 모드 시작" 원칙의 의도적 예외 — 경고(exit 0)는 질문 블로킹을 못 막아 무의미. auto 한정 발동이라 위험 격리.
2. **routine/① 단일 채널 설계**: hook 은 의도를 못 읽으므로 AskUserQuestion 전면 비활성, ① 은 `decision add + 턴 종료` 로 분리 (ADR-009 Addendum).
3. **도그푸딩 미러**: `sources/` ↔ `.harness-kit/` byte-identical + `.claude/settings.json` matcher.

## 🧪 Verification

### 자동 테스트
```bash
bash tests/test-askquestion-auto.sh
bash tests/run.sh
```
**결과 요약**:
- ✅ `test-askquestion-auto`: 6/6 (auto 차단 / governed·turbo 통과 / warn override / mode 부재 fail-safe)
- ✅ 전체 회귀: 73/73 (FAIL 0)

### 수동 검증 시나리오
1. **Spike**: 더미 exit-2 hook → AskUserQuestion 차단됨, stderr 피드백, 질문 미도달 (24-04 전제 반증)
2. **라이브**: `sdd mode auto` → 실제 hook 이 차단 + 리다이렉트 지침 출력 → `governed` 복귀, 작업트리 클린

## 📦 Files Changed

### 🆕 New Files
- `sources/hooks/check-askquestion-auto.sh`: auto 차단 hook
- `tests/test-askquestion-auto.sh`: 단위 테스트 6건

### 🛠 Modified Files
- `sources/claude-fragments/settings.json.fragment`: PreToolUse `AskUserQuestion` matcher
- `sources/governance/agent.md` §8.4: 기계적 백스톱 1줄 포인터
- `.harness-kit/hooks/check-askquestion-auto.sh` / `.harness-kit/agent/agent.md` / `.claude/settings.json`: 도그푸딩 설치본 미러

**Total**: 7 files changed

## ✅ Definition of Done

- [x] 모든 단위 테스트 통과 (6/6) + 전체 회귀 73/73
- [x] auto 차단 / governed·turbo 통과 / 리다이렉트 메시지 고정
- [x] sources ↔ 설치본 미러 byte-identical
- [x] `walkthrough.md` / `pr_description.md` ship commit
- [x] 브랜치 push

## 🔗 관련 자료

- Phase: `backlog/phase-25.md`
- ADR: `docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md` (Addendum)
- GitHub #181 (논블로킹·하네스 격차)
