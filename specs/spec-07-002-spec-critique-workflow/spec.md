# spec-07-002: Spec/Plan 자기비판 워크플로우

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-07-002` |
| **Phase** | `phase-07` |
| **Branch** | `spec-07-002-spec-critique-workflow` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

Spec/Plan 작성은 Opus 단일 모델이 단일 시각으로 수행한다. 작성 후 Plan Accept 전에 외부 관점의 검토 단계가 없다.

### 문제점

1. **단일 시각 편향**: 요구사항을 작성한 모델이 스스로 검토하면 같은 사각지대를 반복함
2. **알려진 기법 미참조**: 유사 문제를 해결한 기존 패턴/라이브러리/방법론을 모르고 재발명하는 경우 발생
3. **요구사항 품질 미검증**: 누락·모순·과잉 설계가 Plan Accept 후 구현 단계에서야 발견됨
4. **대안 부재**: 단일 해결책만 제시되고 트레이드오프 비교 없이 진행됨

### 해결 방안 (요약)

`/hk-spec-critique` 슬래시 커맨드를 신설한다. spec.md 작성 후 Plan Accept 전에 선택적으로 호출하면, Opus 서브에이전트가 독립 컨텍스트에서 요구사항을 비판하고 대안을 제시한다. 결과는 `critique.md`로 저장되어 Plan 개선에 활용한다.

## 🎯 요구사항

### Functional Requirements

1. `/hk-spec-critique` 커맨드: 현재 active spec의 `spec.md`를 읽어 Opus 서브에이전트로 비판 수행
2. 서브에이전트 수행 항목:
   - **유사 기법 조사**: 웹 검색으로 동일/유사 문제를 해결한 알려진 패턴·라이브러리·방법론 탐색
   - **요구사항 비판**: 누락된 요구사항, 모순, 과잉 설계(YAGNI 위반) 지적
   - **대안 제안**: 현재 접근법과 다른 방향 2~3개 제시 + 각 트레이드오프 + 권장안
3. 결과를 `specs/<spec-dir>/critique.md`로 저장
4. `agent.md §4.4`에 critique를 Plan Accept 전 선택 단계로 명시
5. `spec.md` 템플릿에 `## 🔍 Critique 결과` 섹션 추가 (선택 작성)

### Non-Functional Requirements

1. 선택적(optional) 단계 — 기본 워크플로우를 막지 않음
2. 서브에이전트는 Opus 모델 사용 (→ agent.md §6.6)
3. 서브에이전트는 WebSearch 도구 접근 필요

## 🚫 Out of Scope

- Plan/task.md 비판 (spec.md만 대상)
- 자동 실행 (항상 수동 호출)
- critique 결과의 자동 spec 반영

## ✅ Definition of Done

- [ ] `sources/commands/hk-spec-critique.md` 작성 완료
- [ ] `sources/governance/agent.md` + `agent/agent.md` §4.4 critique 단계 추가
- [ ] `sources/templates/spec.md` + `agent/templates/spec.md` Critique 섹션 추가
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-07-002-spec-critique-workflow` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
