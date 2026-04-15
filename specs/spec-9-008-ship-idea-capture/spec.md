# spec-9-008: 거버넌스 흐름 보호 (idea-guard)

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-9-008` |
| **Phase** | `phase-9` |
| **Branch** | `spec-9-008-ship-idea-capture` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-15 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

SDD 프로세스에서 에이전트는 Phase → Spec → Plan → Task 순서로 작업한다. 그러나 작업 도중 사용자가 새 아이디어를 제시하거나, 현재 목표와 다른 방향의 의견을 내면 에이전트가 현재 흐름을 이탈하여 문서화 없이 방향 전환하는 경우가 발생한다.

### 문제점

1. **흐름 이탈**: 작업 중 새 아이디어가 나오면 현재 spec을 중단하고 바로 새 작업에 착수하는 경우
2. **미완 작업 누적**: 세션이 바뀌면 이전 세션의 미완 spec이나 파킹된 아이디어를 인지하지 못함
3. **암묵적 방향 전환**: 사용자 의견이 현재 목표와 다를 때 에이전트가 충돌을 명시하지 않고 조용히 따라가면서 기존 계획과 괴리 발생

### 해결 방안 (요약)

constitution.md와 agent.md에 세 가지 보호 메커니즘을 추가한다:
1. **Idea Capture Gate** — 새 아이디어 발생 시 backlog 기록 후 선택지 제시
2. **Context Continuity Check** — 세션 시작 시 미완 항목 확인
3. **Opinion Divergence Protocol** — 의견 충돌 시 명시적 조율

## 🎯 요구사항

### Functional Requirements

1. **Idea Capture Gate** (`constitution.md` §5.5 신설)
   - 작업 중 새 아이디어/요청이 발생하면 에이전트는 즉시 실행하지 않고 먼저 backlog에 기록
   - 기록 후 사용자에게 두 선택지 제시: "현재 작업 완료 후 진행" / "지금 전환 (현재 작업 파킹)"
   - 문서화 없는 방향 전환은 금지
   - PR 리뷰 중 새 아이디어 발생 시에도 동일 적용

2. **Context Continuity Check** (`agent.md` §2 Bootstrap Protocol 확장)
   - 세션 시작 시 (hk-align) 미완 spec, 파킹된 아이디어 존재 여부 확인
   - 미완 항목이 있으면 "이전 세션에서 미완된 항목이 있습니다" 알림 + 목록 출력
   - 새 작업 시작 전 사용자에게 미완 항목 처리 방향 확인

3. **Opinion Divergence Protocol** (`constitution.md` §5.6 신설)
   - 사용자 의견이 현재 진행 중인 목표/계획과 충돌할 때 에이전트가 충돌을 명시
   - 조율안 제안 후 사용자 선택 대기
   - 결과를 backlog 또는 phase.md에 기록 (결정 추적 가능)

### Non-Functional Requirements

1. 거버넌스 문서는 영어로 작성 (기존 원칙)
2. 기존 섹션 번호 체계와 자연스럽게 통합
3. 실제 hook 구현은 없음 — 에이전트 행동 규약만 추가

## 🚫 Out of Scope

- hook을 통한 자동 강제 (행동 규약 수준만)
- sdd CLI 변경
- hk-align 슬래시 커맨드 코드 변경 (agent.md 절차 변경으로 자연스럽게 반영)

## ✅ Definition of Done

- [ ] `sources/governance/constitution.md`에 §5.5, §5.6 추가
- [ ] `sources/governance/agent.md`에 Bootstrap Protocol 확장
- [ ] 도그푸딩 반영: `.harness-kit/agent/constitution.md`, `.harness-kit/agent/agent.md` 동기화
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-9-008-ship-idea-capture` 브랜치 push 완료
