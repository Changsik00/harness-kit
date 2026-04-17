# spec-07-03: Plan Accept 요청 일관성

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-07-03` |
| **Phase** | `phase-07` |
| **Branch** | `spec-07-03-plan-accept-consistency` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

SDD 워크플로우에서 spec/plan/task 작성이 완료되면 에이전트가 사용자에게 Plan Accept를 요청한다. 그러나 에이전트마다, 세션마다 요청 표현이 다르다:

- "plan accept 해주세요"
- "/hk-plan-accept 를 입력하세요"
- "Plan을 승인하시면 진행합니다"
- 아무 안내 없이 대기

사용자 응답도 마찬가지로 불일치:
- "ok", "Y", "plan accept", "accept", "/hk-plan-accept" 등 다양한 표현으로 응답
- 에이전트가 이를 Plan Accept로 인식하는지 불명확

### 문제점

- 사용자가 어떻게 응답해야 Plan Accept가 되는지 매번 혼란
- 에이전트가 응답을 Plan Accept로 인식하지 못하고 다시 물어보는 경우 발생
- spec-07-02에서 추가한 선택 프롬프트(`1. /hk-spec-critique / 2. Plan Accept`)와의 정합성도 필요

### 해결 방안 (요약)

에이전트가 Plan Accept를 요청하는 표준 문구와 허용 사용자 응답 목록을 `agent.md`와 `constitution.md`에 단일 규격으로 정의한다. `hk-plan-accept.md` 커맨드에도 동일 규칙을 명시한다.

## 🎯 요구사항

### Functional Requirements

1. `agent.md` §4.4에 Plan Accept 요청 표준 문구 정의 — 에이전트는 반드시 이 문구를 사용할 것
2. 선택 항목 순서: **1번 = Plan Accept**, 2번 = Critique — 기본 경로가 앞에 와야 함
3. 각 항목에 슬래시 커맨드를 괄호로 병기: `1. Plan Accept (/hk-plan-accept)` / `2. Critique (/hk-spec-critique)`
4. `constitution.md` §4.2에 허용 사용자 응답 목록 추가 (SSOT) — 에이전트가 Plan Accept로 인식해야 하는 표현을 한 곳에만 정의
5. `agent.md`와 `hk-plan-accept.md`는 허용 목록을 중복 기재하지 않고 `constitution §4.2` 참조로 대체
6. `constitution.md` §4.2에 목록 외 응답 행동 규칙 추가 — 허용 목록에 없는 응답 수신 시 에이전트는 선택을 다시 요청한다
7. 허용 응답은 대소문자 구분 없이 처리

### Non-Functional Requirements

1. 기존 워크플로우 마찰 없음 — 새 규격이 기존 사용자 습관(예: "ok", "Y")을 포괄해야 함
2. 문서 변경만으로 구현 — 코드/스크립트 변경 없음

## 🚫 Out of Scope

- Plan Accept 인식을 자동화하는 hook 또는 스크립트 구현
- Plan Accept 이외의 사용자 응답 표준화 (예: critique 선택, PR 확인 등)
- UI/TUI 기반 선택 인터페이스 구현

## ✅ Definition of Done

- [ ] `agent.md` §4.4에 표준 요청 문구 + 허용 응답 목록 정의 완료
- [ ] `constitution.md` §4.2에 허용 응답 인식 규칙 추가 완료
- [ ] `hk-plan-accept.md`에 동일 규칙 명시 완료
- [ ] `sources/` 원본과 `agent/` 설치본 모두 반영 완료
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-07-03-plan-accept-consistency` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
