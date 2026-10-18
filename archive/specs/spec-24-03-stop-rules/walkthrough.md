# Walkthrough: spec-24-03

> auto 모드의 사전 안전판(정지규칙 ②③)과 사람 검토 근거(결정 로그)의 *기계적 엔진* 구현.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 24-03 범위 | full(②③+로그) / 분할 | **full** | 사용자 결정(2026-06-21) — "결국 모두 검토하니 PR 크기는 분할 사유 아님" |
| ②감지 위치 | git pre-commit / PreToolUse Bash 매처 | **PreToolUse Bash 매처** | 실행 *전* 차단해야 비가역 행동을 막음(커밋 후엔 늦음). `check-diff-size.sh` 패턴 답습 |
| ②감지 폭 | broad / narrow | **narrow** | "② 좁으면 사고·넓으면 자율성 저하"(phase 위험완화) — FP 최소화 우선, `reset --hard`·`--force-with-lease` 제외. 경계는 테스트로 고정 |
| ②초기 강도 | 차단 / 경고 | **경고 모드** | 훅 단계론 — 1주 운영(FP 관찰) 후 차단 승격 |
| ③hard-stop 시 revert | revert / 보류 | **보류(커밋 보존)** | N회 실패 = 사람 개입 신호 — 실패 상태를 사람이 보게 커밋 보존. 1~N-1회는 기존대로 auto-revert |
| 결정 로그 저장소 | 별도 파일 / walkthrough | **walkthrough(auto 섹션)** | "결정·근거를 walkthrough 에 누적"(ADR-009 규약 2) — 기존 산출물 활용 |

## 💬 사용자 협의

- **주제**: 24-03 범위 (정지규칙 엔진 + 결정 로그)
  - **합의**: full scope. PR 크기는 분할 사유가 아님(어차피 전부 검토).
- **주제**: ① 방향 모호 + agent 행동 규칙
  - **합의**: 본 spec 은 *기계적 엔진* 만 — ①·agent.md 서술은 24-04(논블로킹 결정)로 분리.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-stop-rules.sh` + `bash tests/test-decision-log.sh` + 전체
- **결과**: ✅ Passed (stop-rules 13/13, decision-log 4/4, 전체 70/70)
```text
test-stop-rules:   PASS=13  (② 감지 10 + ③ 카운터 3)
test-decision-log: PASS=4   (add/멱등/list/graceful)
회귀: test-turbo-hooks 8/8, test-mode-auto 6/6, test-install-settings-hook 7/7
전체: 70/70 (FAIL 0)
```

### 수동 검증
1. **Action**: `CLAUDE_TOOL_INPUT_command="git push --force" bash check-irreversible.sh`
   - **Result**: stderr 비가역 경고 + exit 0 (경고 모드). `git reset --hard` 는 무경고(경계 제외).
2. **Action**: auto 모드 3회 연속 검증 실패
   - **Result**: 1·2회 auto-revert(n/3), 3회째 hard-stop + 커밋 보존.

## 🔍 발견 사항

- **deny 리스트와 부분 중복(의도적).** `settings.json` permissions.deny 가 이미 `git push --force`·`rm -rf /`·`git clean -fd` 등을 Claude 권한 레벨에서 *정적·all-or-nothing* 으로 차단한다. `check-irreversible.sh` 는 그 위에 **mode-aware(auto warn→block 승격) + 변형 감지 + 결정 로그 연동** 을 더하는 stop-rule 엔진이라 별개 가치. 둘 다 Claude Code 도구 경유만 잡는 한계는 공유 — 진정한 도구 무관 차단은 24-02 의 커밋시점 가드가 담당.
- **③는 auto 전용.** turbo(attended)는 사람이 실시간 대응하므로 기존 즉시 auto-revert 유지. 카운터·hard-stop 은 `mode=auto` 에서만 동작(turbo 회귀 0 확인).

## 🚧 이월 항목

- ②경고 → 차단(exit 2) 승격: 1주 FP 관찰 후 (phase-FF).
- ②감지 목록 확장(borderline: `--force-with-lease`·`docker push`·`git rebase --onto` 등): 운영 데이터 후 별건.
- 결정 로그의 phase-ship 일괄 노출 + ①방향모호/agent.md auto 서술 → spec-24-04/05.
