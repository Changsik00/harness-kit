# Implementation Plan: spec-08-05

## 📋 Branch Strategy

- 신규 브랜치: `spec-08-05-phase-ship`
- 시작 지점: `phase-08-work-model` (spec-08-04 merge 완료 기준)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] Phase Ship은 에이전트 자동 생성 금지 — 반드시 사용자 go/no-go 후 PR 생성
> - [ ] constitution.md, agent.md 변경은 영문으로 작성
> - [ ] `/hk-phase-ship` 완성 후 바로 phase-08 자체에 적용하여 도그푸딩 검증

> [!WARNING]
> - [ ] phase.md에 성공 기준/통합 테스트가 없는 phase에서도 `/hk-phase-ship` 이 동작해야 함 (warn + skip)

## 🎯 핵심 전략 (Core Strategy)

본 spec은 **슬래시 커맨드 + 템플릿 + 거버넌스 규칙** 변경입니다. 코드 변경은 없으며, 단위 테스트 불필요합니다.

### 주요 ��정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **hk-phase-ship.md** | 5단계 절차 (검증→테스트→보고→PR→done) | Spec ship과 구조 유사하되 검증 강화 |
| **phase-ship.md 템플릿** | Scope + Criteria + Test + Risk 구조 | 업계 Release Readiness Review 패턴 차용 |
| **거버넌스** | Phase PR = 사용자 go/no-go 필수 | Spec PR과 본질적으로 다른 리뷰 대상 |

## 📂 Proposed Changes

### [NEW] `sources/commands/hk-phase-ship.md`

Phase 완료 시 에이전트 절차:

```
Step 1: Pre-check
  - 모든 Spec Merged 확인 (phase.md spec 표 파싱)
  - 미완 Spec 있으면 중단

Step 2: Success Criteria Verification
  - phase.md 성공 기준 읽기
  - 항목별 PASS/FAIL 판단 + 증거 수집

Step 3: Integration Test Execution
  - phase.md 통합 테스트 시나리오 읽기
  - 시나리오별 실행 + 결과 기록

Step 4: Go/No-Go Report
  - 검증 결과를 사용자에게 보고
  - 명시적 승인 대기 (자동 진행 금지)

Step 5: Phase PR Creation (승인 후)
  - phase-ship.md 템플릿 기반 PR 본문 작성
  - gh pr create --base main --head {phase-branch}
  - sdd phase done 실행
```

### [NEW] `sources/templates/phase-ship.md`

Phase PR 전용 본문 템플릿 (기존 spec PR 템플릿과 별도).

### [MODIFY] `sources/governance/constitution.md` (영문)

§3.1 Phase 또는 §7 Execution Delegation에 Phase Ship 규칙 추가:
- Phase PR MUST NOT be created without explicit User go/no-go approval.
- Phase PR body MUST follow the `phase-ship.md` template.

### [MODIFY] `sources/governance/agent.md` (영문)

§3.1 Work Type Behavior Table — Phase 행 Completion Action을 `/hk-phase-ship` 참조로 갱신.
§6.3 Completion Checklists — Phase done 행에 `/hk-phase-ship` 참조 추가.

### [SYNC] `agent/constitution.md` + `agent/agent.md`

sources/ 와 동일 내용 동기화.

## 🧪 검증 계획 (Verification Plan)

### 도그푸딩 검증

본 spec 완료 후, `/hk-phase-ship` 을 **phase-08 자체에 적용**하여 검증합니다:
1. phase-08.md 성공 기준 6개 검증
2. 통합 테스트 시나리오 4종 실행
3. 사용자 go/no-go 협의
4. Phase PR 생성

## 🔁 Rollback Plan

- 모든 변경이 문서(슬래시 커맨드, ��플릿, 거버넌스)이므로 git revert로 원복

## 📦 Deliverables 체크

- [x] spec.md 작성
- [x] plan.md 작성 (이 파일)
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
