# Walkthrough: spec-25-01

> auto 논블로킹의 기계적 백스톱 — `AskUserQuestion` 을 PreToolUse hook 으로 차단. 24-04 의 "hook 불가" 전제 정정.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| 24-04 전제("AskUserQuestion 은 hook 으로 못 막음") 처리 | 산문 유지 / hook 으로 정정 | **hook 으로 정정** | claude-code-guide + 라이브 spike 로 반증 — AskUserQuestion 은 PreToolUse matcher 대상, exit 2 차단됨 |
| 차단 방식 | exit 2 + stderr / 구조화 JSON `permissionDecision:deny` | **exit 2 + stderr** | 기존 7개 hook `hook_violation` 관례 동일, bash 3.2 단순. 구조화 deny 는 -p headless 엣지용 — attended auto 기본인 본 키트엔 불필요 |
| 기본 hook 모드 | warn 시작(단계론) / block | **block** | warn(exit 0)은 질문 블로킹을 못 막아 무의미. 이 hook 은 차단이 곧 기능. auto 한정 발동이라 위험 격리 (CLAUDE.md #5 의 의도적 예외) |
| routine vs ① 구분 | hook 이 판정 / stderr 지침으로 분기 | **stderr 지침** | hook 은 agent 의도를 못 읽음 → AskUserQuestion 전면 비활성, ① 은 `decision add + 턴 종료` 단일 채널 (ADR-009 Addendum) |

> ADR 승격 판단: 설계 방향은 ADR-009 Addendum 이 이미 담음. 본 spec 고유 결정(exit 2 / block 예외)은 walkthrough 로 충분 — 별도 ADR 미생성.

## 💬 사용자 협의

- **주제**: auto 가 askMode 때문에 다시 멈추면 의미가 있나 + 거버넌스는 변할 수 있음
  - **합의**: 24-04 의 "hook 불가" 전제를 고수하지 말고 기계적 백스톱으로 정정. phase-25 최우선 spec 으로 착수.

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-askquestion-auto.sh` + `bash tests/run.sh`
- **결과**: ✅ Passed (askquestion-auto 6/6, 전체 73/73, FAIL 0)
```text
auto → 차단(exit 2 + hook:block) / stderr 'decision add' 지침
governed·turbo → 통과(exit 0, 무발동)
auto + HARNESS_HOOK_MODE_ASKQUESTION=warn → 경고+exit 0
mode 부재 → fail-safe 통과(exit 0)
```

### 수동 검증
1. **Spike (Task 1)**: 더미 hook(무조건 exit 2) 을 AskUserQuestion matcher 에 등록 → 실제 호출
   - **Result**: 차단됨 + stderr 가 에이전트에 에러로 피드백, 질문이 사용자에 미도달. **24-04 전제 반증**.
2. **라이브 (실제 hook, Ship 전)**: `sdd mode auto` → AskUserQuestion 호출
   - **Result**: `check-askquestion-auto.sh` 가 차단 + 전체 리다이렉트 지침 출력. `sdd mode governed` 복귀 후 작업트리 클린.

## 🔍 발견 사항

- **settings.json hook 은 hot-reload** (공식 문서 "Hot Reload" ✅ hooks) — 세션 재시작 없이 다음 도구 호출부터 적용. 덕분에 라이브 spike 가 가능했다.
- **24-04 전제는 절반만 맞았다**: hook 은 *호출 안 함* 을 선제 못 하지만, *호출되는 순간* 가로채 차단할 수 있다. "못 막음"은 후자를 간과한 것.
- **mode 토글이 settings.json `ask` 배열을 round-trip** 으로 건드리지만(auto 시 git push 제거 → governed 시 복원), 같은 값으로 돌아와 작업트리에 잔재 없음.
- hook 은 `state.mode` 만 읽으면 됨 — matcher 가 AskUserQuestion 만 필터하므로 tool_input 파싱 불필요(단순·견고).

## 🚧 이월 항목

- **auto e2e 측정** — 본 spec 은 hook 단위 + 라이브 1회까지. "한 사이클에서 routine 안 멈춤 + ① 멈춤" 전체 흐름은 spec-25-03.
- **`ExitPlanMode` 차단 여부** — auto 에서 plan mode 진입도 동일 패턴으로 막을지 검토 (현재 scope 외). 필요 시 phase-25 phase-FF 또는 후속.
