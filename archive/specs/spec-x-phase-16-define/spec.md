# spec-x-phase-16-define: phase-16 (Reliability Layer) 백로그 등록

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-phase-16-define` |
| **Phase** | (없음 — Solo Spec; phase-16 자체는 *대기* 상태로만 등록) |
| **Branch** | `spec-x-phase-16-define` |
| **상태** | Planning |
| **타입** | Docs (Phase 정의) |
| **Integration Test Required** | no |
| **작성일** | 2026-05-15 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

- 외부 진단(velog: 80-problem-in-agentic-coding) 과 추가 제안서(5축 + 5 차별화 + 포지셔닝) 를 검토한 결과, 본 키트의 갭이 4 개 영역(RCA / Knowledge Type 슬롯 / ADR 활성화 / Stale 탐지) + 1 포지셔닝 영역으로 정리되었다.
- 키트의 *thin orchestration* 철학과 충돌하지 않는 *얇은 보강* 으로 도입 가능하다는 합의가 있었다.
- 현 시점에는 *즉시 실행* 하지 않고 *백로그* 에 phase 단위로 박아 둔다 — 다른 작업과 우선순위 경쟁 시 비교 가능한 형태로.

### 문제점

- 위 4+1 영역을 *각각 spec-x* 로 처리하면 (a) 의존성(특히 Type 슬롯 → ADR 트리거 → Stale 탐지) 이 시각화되지 않고, (b) 통합 테스트가 spec 경계에 갇혀 전체적 *일관성* 검증이 어렵다.
- 백로그 자유 메모(`queue.md` 의 Icebox / 대기 Phase 섹션) 에 한 줄로만 두면 *실행 단위* 가 결정되지 않아 나중에 시작할 때 다시 분해해야 한다.

### 해결 방안 (요약)

- `backlog/phase-16-reliability-layer.md` 를 정식 phase 정의 형식으로 작성하되 **activate 하지 않는다**. queue.md 의 "📋 대기 Phase" 섹션에 한 줄 등록만 한다. spec-x 형태로 PR 받아 phase 정의 자체를 리뷰 가능하게 만든다.

## 🎯 요구사항

### Functional Requirements

1. `backlog/phase-16-reliability-layer.md` 신규 작성. `.harness-kit/agent/templates/phase.md` 를 따른다.
   - 메타: ID `phase-16`, 상태 **Planning (대기)**, slug `reliability-layer`, Base Branch 없음
   - 배경 / 목표 / 성공 기준 (정량 우선) 포함
   - SPEC 표: 아래 4개 spec 후보를 *Backlog* 상태로 나열
2. SPEC 분해는 다음 4 개로 한다:
   - **spec-16-01**: RCA 시스템 도입 + Knowledge Type 슬롯
   - **spec-16-02**: ADR 활성화 트리거
   - **spec-16-03**: Stale ADR / 결정 탐지 (drift 확장)
   - **spec-16-04**: Reliability layer 포지셔닝
3. `backlog/queue.md` "📋 대기 Phase" 섹션에 한 줄 추가: phase-16 링크 + 1줄 요약.
4. phase-16.md 자체에는 *통합 테스트 시나리오 골격* (3개 시나리오 헤더) 까지 적되, 실행 명령 등 세부는 비워둔다 — 본 spec-x 범위 밖.

### Non-Functional Requirements

1. phase-16 은 본 PR 머지 후에도 **active 가 아니다**. `sdd status` 의 active phase 는 그대로 "없음".
2. 한국어 톤 유지. constitution / 거버넌스 문서(영문) 와 일관성.
3. SPEC 표는 `<!-- sdd:specs:start -->` ~ `<!-- sdd:specs:end -->` 마커 사이에 둔다 (sdd 자동 갱신 영역). 마커 밖의 각 spec 상세는 *요점 / 방향성 / 참조 / 연관 모듈* 4 필드로 채운다.
4. ADR 신규 생성은 본 spec-x 에서 하지 않는다 — phase-16 의 spec-16-02 에서 다룸.

## 🚫 Out of Scope

- 실제 spec-16-* 실행 (templates/rca.md 작성, /hk-rca 슬래시 커맨드 추가, sdd status drift 확장, README 슬로건 변경 등) — 본 PR 머지 후 별도 시점.
- phase-16 activate (`sdd phase activate phase-16`).
- 다른 대기 항목 / Icebox 정리.
- Phase base branch 모드 결정 (현 단계: 비추천이라 default 없음).

## ✅ Definition of Done

- [ ] `backlog/phase-16-reliability-layer.md` 신규 — 4개 spec 후보 정의 완료
- [ ] `backlog/queue.md` "📋 대기 Phase" 섹션 한 줄 등록
- [ ] phase-16 은 *active* 가 아님 (sdd status 확인)
- [ ] walkthrough.md / pr_description.md 작성 및 ship commit
- [ ] PR 머지 후 `sdd specx done phase-16-define` 로 queue 갱신
