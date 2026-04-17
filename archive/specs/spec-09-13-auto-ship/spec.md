# spec-09-13: Plan Accept → PR 자동 진행 (auto-ship)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-09-13` |
| **Phase** | `phase-09` |
| **Branch** | `spec-09-13-auto-ship` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-16 |
| **소유자** | ck |

## 📋 배경 및 문제 정의

### 현재 상황

Plan Accept 후 에이전트가 task를 자동 진행하지만, Ship 단계에서 두 번 멈춘다:
1. **Push 전 사용자 승인** — "push 할까요? [Y/n]"
2. **PR 생성 전 사용자 확인** — "PR 생성할까요?"

사용자는 매번 "Y", "ok", "pr 요청해줘" 등을 입력해야 하며, 이 과정에서 흐름이 끊긴다.

### 문제점

1. Plan Accept로 이미 "이 계획대로 실행하라"고 위임했는데, push/PR에서 다시 확인을 받는 것은 중복 게이트
2. 테스트가 통과하고 archive 검증도 통과한 상태에서 push/PR은 기계적 단계 — 판단이 필요한 지점이 아님
3. 반복적 확인 요청이 사용자 집중을 분산시킴

### 해결 방안 (요약)

Plan Accept의 위임 범위를 push + PR 생성까지 확장한다. 대신 **자동화 수준이 높아지는 만큼 검증 품질을 강화**한다: 테스트가 "의미 있게" 통과했는지를 보장하는 장치를 추가한다.

## 🎯 요구사항

### Functional Requirements

1. **agent.md §6.1**: Ship task의 "항상 사용자 확인 필요" 규칙을 변경 → "이상 없으면 자동 진행, 이상 시 멈추고 보고"
2. **constitution §10.2**: PR 생성의 "MUST obtain explicit User confirmation" → "Plan Accept가 Ship까지의 위임을 포함"
3. **hk-ship.md**: push 확인 블록 제거 (기본 동작이 `--no-confirm`)
4. **hk-ship.md**: PR 생성을 push 성공 시 자동 실행으로 변경
5. **agent.md §6.1**: 자동 진행 흐름을 명시 — "모든 task 완료 → archive → push → PR → PR URL 보고 → 사용자 머지 대기"

### Non-Functional Requirements

1. **안전장치 유지**: 테스트 실패, archive --check 실패, push 실패 시 여전히 멈추고 보고
2. **Phase Ship 제외**: `/hk-phase-ship`의 go/no-go는 변경하지 않음 (릴리스 게이트)
3. **기존 `--no-confirm` 플래그 호환**: hk-ship.md에서 해당 플래그 관련 분기 정리

## 🚫 Out of Scope

- `/hk-phase-ship`의 go/no-go 자동화 (릴리스 게이트는 항상 사용자 결정)
- 테스트 실패 시 자동 수정 (에이전트 임의 fix는 계속 금지)
- Strict Loop 내 task 자동 진행 변경 (이미 자동 진행 중)

## ✅ Definition of Done

- [ ] agent.md에서 Ship 자동 진행 규칙이 명문화됨
- [ ] constitution에서 Plan Accept의 위임 범위가 push+PR을 포함하도록 갱신됨
- [ ] hk-ship.md에서 push 확인 블록과 PR 확인이 자동 진행으로 변경됨
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-09-13-auto-ship` 브랜치 push 완료
