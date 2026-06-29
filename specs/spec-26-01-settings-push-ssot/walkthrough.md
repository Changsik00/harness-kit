# Walkthrough: spec-26-01

> settings push 권한 SSOT — mode-toggle 의 git-push ask 잔재 제거 (W3).

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| push 게이팅 위치 | 방향1: fragment `ask` 에 push 추가(governed 게이트) / 방향2: 토글 제거(push 항상 자동) | **방향2** | 조사 중 mode-toggle governed 분기가 git push 를 `ask` 로 올려 **constitution §5.7("Plan Accept 후 push 자동, NO user response")과 충돌**함을 발견. 방향1 은 §5.7 위반 지속. 방향2 는 drift 원천 제거 + §5.7 정합, force-push 는 deny+check-irreversible 이 이미 차단 |
| W3 작업 단위 | phase-FF / spec 승격 | **spec-26-01** | §5.7 규약·sdd 동작 변경이라 설계 근거를 spec.md 로 남길 가치(§11.3). auto 정지규칙 ①(상충 방향 모호성)로 멈춰 사용자 결정 후 진행 |
| T3 검사 방식 | 문자열 grep / 실체(함수정의+jq조작) grep | **실체 grep** | 단순 `_settings_mode_patch` grep 은 설명 주석에도 걸려 오탐 → 함수 정의 `()` + `permissions.ask...git push` jq 조작만 검사 |

<!-- ADR 승급 검토: push-always-automatic(type: convention). 단 §5.7 이 이미 규약화 → phase-26 결정 기록으로 충분, ADR 보류 -->

## 💬 사용자 협의

- **주제**: W3 의 두 상충 수정 방향 (auto 정지규칙 ① stop)
  - **합의**: 방향2(토글 제거 + §5.7 정합) 채택. W3 을 spec 으로 승격해 제대로 처리 (2026-06-29, "추천대로 하자").

## 🧪 검증 결과

### 자동화 테스트
- **명령**: `bash tests/test-settings-ssot.sh` · `tests/test-turbo-mode.sh` · `tests/test-e2e-auto-mode.sh` · `tests/run.sh`
- **결과**: ✅ Passed
```text
test-settings-ssot  PASS 3 / FAIL 0   (T1 fragment ask 무 push / T2 deny force / T3 sdd 비조작)
test-turbo-mode     PASS 5 / FAIL 0   (모드 전환 회귀 — 토글 제거 무영향)
test-e2e-auto-mode  PASS 8 / FAIL 0   (① auto→ask 무 push baseline 불변식)
```

### 수동 검증
1. **Action**: `jq '.permissions.allow|index("Bash(git push:*)")' .claude/settings.json`
   - **Result**: `absent` (stray 제거 확인). `ask` git push 0개, JSON 유효.

## 🔍 발견 사항

- **§5.7 vs mode-toggle 모순**: Icebox W3 은 단순 "SSOT sync 테스트"로 적혀 있었으나, 조사 결과 mode-toggle 의 governed 분기가 §5.7(push 자동)을 *위반*하는 더 깊은 문제였음. 단순 동등성 테스트가 아니라 토글 로직 제거가 정답.
- **fragment 은 이미 정답**: fragment baseline 은 ask 에 push 없음 + git:* allow + force deny 로 §5.7 과 이미 정합. drift 는 전적으로 토글이 만들었음.
- **dogfood 설치본 sync 불변식**: sources/bin/sdd 만 고치자 `test-hook-modes`·`test-test-auto-record`·`test-pr-merge-detect` 3건이 "sources↔.harness-kit 불일치"로 FAIL. 도그푸딩 SSOT 를 테스트가 강제하고 있음(예상된 안전망 작동). `cp sources/bin/sdd .harness-kit/bin/sdd` + check-irreversible 동기화로 해소(commit `337362d`). → auto pre-push gate 가 실제로 회귀를 잡은 사례.

## 🚧 이월 항목 (Optional)

- 없음.
