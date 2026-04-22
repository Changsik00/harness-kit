# spec-13-03: 테스트 결과 자동 기록 (test-auto-record)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-13-03` |
| **Phase** | `phase-13` |
| **Branch** | `spec-13-03-test-auto-record` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-22 |
| **소유자** | changsik |

## 📋 배경 및 문제 정의

### 현재 상황
테스트 통과 후 에이전트가 `sdd test passed`를 수동으로 호출해야 `.claude/state/current.json`의 `lastTestPass`가 갱신된다. 이 단계를 빠뜨리면 state가 stale 상태로 남는다.

### 문제점
- 에이전트가 테스트 실행 후 `sdd test passed` 호출을 잊으면 상태가 갱신되지 않음
- "ship 전 테스트 통과 여부" 등 거버넌스 체크가 정확하지 않게 됨
- 불필요한 수동 단계가 워크플로우 마찰을 증가시킴

### 해결 방안 (요약)
`sdd run-test <cmd>` wrapper subcommand를 추가한다. 테스트 명령을 감싸서 실행하고, exit code 0이면 자동으로 `sdd test passed`를 호출한다. 단순하고 신뢰성 높은 exit code 기반 감지로 false positive를 방지한다.

## 🎯 요구사항

### Functional Requirements
1. `sdd run-test <cmd...>` 실행 시:
   - `<cmd...>` 를 그대로 실행 (stdout/stderr passthrough)
   - exit code 0이면 `sdd test passed` 자동 호출 + "✅ 테스트 통과 기록됨" 출력
   - exit code 0이 아니면 `sdd test passed` 호출 없이 종료 (exit code 그대로 전달)
2. `sdd help`에 `run-test` 항목 추가
3. 인자 없이 실행 시 사용법 안내 출력 + exit 0

### Non-Functional Requirements
1. `<cmd...>` 의 stdout/stderr 를 그대로 터미널에 전달 (버퍼링 없음)
2. `sdd run-test` 자체의 exit code = `<cmd...>` 의 exit code
3. `sdd test passed` 호출 실패 시 경고만 출력, sdd run-test 는 성공으로 처리

## 🚫 Out of Scope

- PostToolUse hook 방식 (도구 출력 파싱, 패턴 매칭) — 구현 복잡도 및 false positive 위험으로 제외
- 테스트 프레임워크별 출력 파싱 (jest, pytest, go test 등)
- 테스트 실패 원인 분석

## ✅ Definition of Done

- [ ] 모든 단위 테스트 PASS (`tests/test-test-auto-record.sh`)
- [ ] `sdd run-test` 명령 인식 및 exit code 전달 확인
- [ ] `sdd help`에 `run-test` 포함 확인
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 ship commit
- [ ] `spec-13-03-test-auto-record` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
