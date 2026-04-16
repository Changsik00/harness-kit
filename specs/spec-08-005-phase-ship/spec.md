# spec-08-005: Phase Ship 절차 표준화

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-08-005` |
| **Phase** | `phase-08` |
| **Branch** | `spec-08-005-phase-ship` |
| **Base** | `phase-08-work-model` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-11 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

Spec-level ship(`/hk-ship`)은 archive → push → PR 생성까지 잘 정의되어 있다. 그러나 Phase-level ship(phase base branch → main 최종 PR)은 절차가 없다. phase-08에서 실제로 에이전트가 spec PR 4개의 제목을 나열한 것만으로 최종 PR을 생성하려 했고, 사용자가 이를 차단했다.

### 문제점

- **Spec PR ≠ Phase PR**: Spec PR은 "코드가 맞는가?" / Phase PR은 "이 기능이 배포 가능한가?" — 본질적으로 다른 리뷰
- **검증 부재**: phase.md에 성공 기준과 통합 테스트 시나리오가 정의되어 있으나, 이를 실제로 실행하고 증거를 수집하는 강제 절차가 없음
- **사용자 협의 부재**: 에이전트가 자동으로 Phase PR을 생성 — "main에 들어가도 되는가?" 판단을 사용자와 협의하지 않음
- **PR 본문 품질**: spec 나열 수준 — 목표 달성도, 리스크, 남은 작업 등 의사결정에 필요한 정보 부재

### 해결 방안 (요약)

`/hk-phase-ship` 슬래시 커맨드를 만들어 Phase 완료 시 에이전트가 따라야 할 표준 절차를 정의한다. `phase-ship.md` 템플릿으로 Phase PR 본문의 품질을 보장한다. constitution/agent.md에 Phase Ship 규칙을 추가한다.

## 📊 개념도

```
모든 Spec Merged (phase base branch에)
         ↓
/hk-phase-ship 호출
         ↓
┌── Phase Ship 절차 ──────────────────────────┐
│  1. 성공 기준 검증                             │
│     phase.md 성공 기준 하나씩 → PASS/FAIL     │
│                                              │
│  2. 통합 테스트 실행                           │
│     phase.md 시나리오 하나씩 → 증거 수집       │
│                                              │
│  3. 검증 결과 보고 + go/no-go 협의            │
│     사용자에게 보고 → 명시적 승인 대기          │
│                                              │
│  4. Phase PR 생성 (사용자 승인 후)             │
│     phase-ship.md 템플릿 기반 PR 본문 생성     │
│     phase base branch → main PR              │
│                                              │
│  5. sdd phase done                           │
│     state 초기화 + queue.md done 이동          │
└─────────────────────────────────────────────┘
```

## 🎯 요구사항

### Functional Requirements

1. **`/hk-phase-ship` 슬래시 커맨드**
   - Phase의 모든 Spec이 Merged 상태인지 확인 (아니면 중단)
   - phase.md 성공 기준(Success Criteria) 섹션을 읽고 항목별 PASS/FAIL 검증
   - phase.md 통합 테스트 시나리오를 읽고 실행 + 증거 수집
   - 검증 결과를 사용자에게 보고하고 go/no-go 승인 대기
   - 승인 후 Phase PR 생성 (phase-ship.md 템플릿 기반)
   - PR 생성 후 `sdd phase done` 실행

2. **`sources/templates/phase-ship.md` — Phase PR 본문 템플릿**
   - Overview: Phase 목표 1~3문장
   - Scope: 계획 vs 실제 (완료 / 이연 / 추가된 항목)
   - Spec Summary: 각 spec PR 번호 + 한 줄 요약
   - Success Criteria Checklist: phase.md 기준별 PASS/FAIL + 증거
   - Integration Test Results: 시나리오별 결과 요약
   - Architecture Decisions: phase 중 내린 주요 결정
   - Known Issues / Technical Debt: 알려진 문제와 후속 작업
   - Follow-up Work: Icebox 이관 항목

3. **거버넌스 규칙 추가 (영문)**
   - `constitution.md` — Phase Ship은 에이전트 자동 생성 금지, 반드시 사용자 go/no-go 후
   - `agent.md` §3.1 — Phase 행 Completion Action 갱신: `/hk-phase-ship` 참조

### Non-Functional Requirements

1. `/hk-phase-ship` 은 Phase base branch 모드가 아닌 경우에도 동작해야 함 (target = main)
2. 성공 기준/통합 테스트가 phase.md에 없으면 경고 + skip (차단하지 않음)
3. constitution.md, agent.md 변경은 영문으로 작성

## 🚫 Out of Scope

- 통합 테스트 자동화 프레임워크 (수동 검증 + 증거 기록으로 충분)
- Phase 간 의존성 관리
- 자동 rollback 절차

## ✅ Definition of Done

- [ ] `/hk-phase-ship` 슬래시 커맨드 작성 완료
- [ ] `sources/templates/phase-ship.md` 템플릿 작성 완료
- [ ] `constitution.md` + `agent.md` Phase Ship 규칙 추가 (영문)
- [ ] `walkthrough.md` 와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-08-005-phase-ship` 브랜치 push 완료 (→ `phase-08-work-model`)
- [ ] 사용자 검토 요청 알림 완료
