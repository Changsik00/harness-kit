# spec-7-001: SDD-Phase / SDD-x / FF 분류 기준 강화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-7-001` |
| **Phase** | `phase-7` |
| **Branch** | `spec-7-001-scope-classification-rules` |
| **상태** | Planning |
| **타입** | Refactor (Governance) |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`constitution.md §2`는 SDD와 FF 두 모드만 정의하고 있으며, 각각의 진입 기준이 추상적이다.

- §2.1 SDD: "New features, architectural changes, non-trivial refactoring, and any change producing a Pull Request"
- §2.2 FF: "Documentation, minor configuration, and small reversible experiments"
- SDD-x(Solo Spec)는 §4.1에 예외 조항으로만 존재하고 §2(Work Modes)에는 없음

`agent.md §3 Alignment Phase`는 SDD vs FF 비교를 요구하지만 SDD-x 옵션이 없고, 분류 근거를 명시하는 의무 항목이 없다.

### 문제점

1. "non-trivial refactoring"의 경계가 모호 — 에이전트마다 판단이 달라짐
2. SDD-x가 §2에 없어 Alignment 단계에서 자연스럽게 고려되지 않음
3. 분류 결정의 근거가 응답에 드러나지 않아 사용자가 검증할 수 없음
4. 경계 사례(edge case) 예시가 없어 유사 케이스에서 반복적으로 불일치 발생

### 해결 방안 (요약)

`constitution.md §2`에 SDD-x를 정식 모드로 추가하고, 3가지 모드를 구분하는 결정 체크리스트와 edge case 예시를 명문화한다. `agent.md §3`에는 분류 근거를 반드시 출력하는 항목을 추가한다.

## 🎯 요구사항

### Functional Requirements

1. `constitution.md §2`에 Mode C (SDD-x) 추가 — §4.1 Solo Spec 조항을 Work Modes 레벨로 승격
2. `constitution.md §2`에 2단계 Work Mode 결정 트리 추가:
   - Step 1: PR이 필요한가? → NO = FF / YES = SDD 계열
   - Step 2: Phase가 필요한가? → YES = SDD-P / NO = SDD-x
3. Edge case 예시 5개 이상 포함 (경계 사례 기준 제시)
4. `agent.md §3`에 `[Classification]` 항목 추가 — 분류 결과와 근거를 Alignment 응답에 반드시 포함
5. `sources/governance/`와 `agent/` 양쪽 동시 반영 (도그푸딩)

### Non-Functional Requirements

1. 결정 체크리스트는 3개 질문 이내로 단순하게 유지
2. Edge case 예시는 실제 이 프로젝트에서 발생한 케이스 기반

## 🚫 Out of Scope

- SDD-x와 Phase SDD의 템플릿 차이 (별도 spec)
- FF 실행 시 에이전트 동작 프로토콜 상세화 (별도 spec)

## ✅ Definition of Done

- [ ] `constitution.md` (sources + agent 양쪽) §2에 SDD-x 모드 + 결정 체크리스트 + edge cases 추가
- [ ] `agent.md` (sources + agent 양쪽) §3에 `[Classification]` 항목 추가
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-7-001-scope-classification-rules` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
