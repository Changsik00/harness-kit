# Implementation Plan: spec-07-001

## 📋 Branch Strategy

- 신규 브랜치: `spec-07-001-scope-classification-rules`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 결정 체크리스트 Q1~Q3 질문 문구 및 순서 동의
> - [ ] "5분 이내" FF 기준이 적절한지 확인 (시간 기준 대신 다른 기준 선호 시 변경)

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **SDD-x 위치** | §2에 Mode C로 승격 | Alignment 단계에서 자연스럽게 고려되도록 |
| **결정 체크리스트** | 3개 질문 플로우차트 | 단순할수록 에이전트 판단 일관성 높음 |
| **Edge cases** | 실제 프로젝트 사례 기반 | 추상적 예시보다 재현 가능한 판단 기준 |
| **agent.md** | `[Classification]` 항목 추가 | 분류 근거를 응답에 강제 노출 |

## 📂 Proposed Changes

### [constitution.md — §2 Work Modes]

#### [MODIFY] `sources/governance/constitution.md` + `agent/constitution.md`

현재 §2.1(SDD), §2.2(FF) 뒤에 다음 추가:

```
§2.3 Mode C — SDD-x (Solo Spec)
  - Phase 없이 진행 가능한 독립 spec (→ §4.1 Solo Spec 조건)

§2.4 Work Mode Decision Tree (2단계)
  Step 1 — PR 필요?
    NO  → FF
    YES → Step 2

  Step 2 — Phase 필요?
    YES → SDD-P  (spec-{phaseN}-{seq})
    NO  → SDD-x  (spec-x-{slug})

  + edge case 예시 5개
```

### [agent.md — §3 Alignment Phase]

#### [MODIFY] `sources/governance/agent.md` + `agent/agent.md`

Output Format에 `[Classification]` 항목 추가:

```
- **[Classification]**: 선택한 모드와 판단 근거
  (constitution §2.4 체크리스트 어느 질문에서 결정되었는지 명시)
```

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
# governance 문서이므로 별도 자동화 테스트 없음
# syntax 확인: markdown lint (없으면 수동 확인)
echo "수동 검증으로 대체"
```

### 수동 검증 시나리오
1. edge case 예시 5개를 체크리스트에 적용 → 각각 올바른 모드로 분류되는지 확인
2. Alignment Phase 응답에 `[Classification]` 항목이 포함되는지 확인

## 🔁 Rollback Plan

- `git revert`로 대응. 거버넌스 문서 변경이므로 코드 영향 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
