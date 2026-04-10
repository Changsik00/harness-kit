# spec-6-002: Task 자동 진행

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-6-002` |
| **Phase** | `phase-6` |
| **Branch** | `spec-6-002-task-auto-proceed` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

agent.md §6.1 Strict Loop Rule의 7번 단계가 "Stop & Report: 사용자 신호를 기다린다"로 되어 있어, 매 task 완료 시마다 사용자가 "ok" 또는 "next"를 입력해야 다음 task로 진행된다.

### 문제점

- 이슈 없는 단순 task에서도 매번 대기 → 불필요한 지연
- 사용자가 반복적으로 "ok"를 치는 것은 실질적 검토가 아닌 형식적 승인

### 해결 방안 (요약)

Strict Loop의 "Stop & Report + 대기" 규칙을 "이슈 없으면 자동 진행, 이슈 시 멈추고 보고"로 변경한다. Hand-off task 전에는 반드시 멈춘다.

## 🎯 요구사항

### Functional Requirements
1. `sources/governance/agent.md` §6.1의 7번 단계를 변경: 이슈 없으면 자동으로 다음 task 진행
2. 이슈 발생 시(테스트 실패, 예상치 못한 에러, 범위 벗어남) 즉시 멈추고 사용자에게 보고
3. Hand-off task(push/PR) 전에는 반드시 멈추고 사용자 확인
4. 매 task 완료 시 task.md 체크박스 실시간 갱신은 유지
5. `agent/agent.md` (도그푸딩)에도 동일 반영
6. `sources/governance/align.md`의 Strict Loop 설명도 갱신

### Non-Functional Requirements
1. 변경은 거버넌스 문서만 대상 (코드 변경 없음)

## 🚫 Out of Scope

- Hook 기반 자동 진행 강제 (프롬프트 규칙 변경만)
- task.md 템플릿 구조 변경

## ✅ Definition of Done

- [ ] `sources/governance/agent.md` §6.1 규칙 변경
- [ ] `sources/governance/align.md` Strict Loop 설명 갱신
- [ ] `agent/agent.md` 도그푸딩 반영
- [ ] `agent/align.md` 도그푸딩 반영
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-6-002-task-auto-proceed` 브랜치 push 완료
