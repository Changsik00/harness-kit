# Implementation Plan: spec-8-004

## 📋 Branch Strategy

- 신규 브랜치: `spec-8-004-align-and-governance`
- 시작 지점: `phase-8-work-model` (spec-8-003 merge 완료 기준)

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] hk-align Step 4에 NOW/NEXT 추가 — `sdd status` 가 이미 출력하므로 별도 파싱 없이 포맷만 명시
> - [ ] agent.md는 영어 문서 — 행동 규칙 표와 체크리스트도 영어로 작성
> - [ ] README 최신화 범위: sdd 명령, 슬래시 커맨드, 워크플로, 작업 유형 모델

## 🎯 핵심 전략 (Core Strategy)

본 spec은 코드 변경 없이 **문서 전용** 변경입니다. 따라서 단위 테스트가 필요하지 않습니다.

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **hk-align** | Step 4 상태 포맷에 NOW/NEXT 행 추가 | sdd status가 이미 NEXT 계산 — 중복 구현 불필요 |
| **agent.md** | §3에 표 추가, §6.3에 체크리스트 추가 | 기존 구조에 자연스럽게 삽입 |
| **README** | 전면 최신화 | phase-8 변경사항 + 오래된 커맨드명 정리 |

## 📂 Proposed Changes

### [MODIFY] `sources/commands/hk-align.md`

Step 4 상태 요약 보고 포맷에 NOW/NEXT 행 추가:
```
📊 현재 상태
- Active Phase: <PHASE-N-slug 또는 "없음">
- Active Spec:  <SPEC-N-NNN-slug 또는 "없음">  ← NOW
- NEXT:         <다음 spec 또는 "없음">          ← NEW
- Branch:       <current branch>
- Plan Accept:  <yes / no>
- Last Test:    <timestamp 또는 "없음"> (PASS / FAIL)
- Pending Tasks: <count>
```

### [MODIFY] `sources/governance/agent.md` + `agent/agent.md`

§3 Alignment Phase에 작업 유형별 행동 규칙 표 추가:

| Work Type | Entry Action | Execution | Completion Action |
|---|---|---|---|
| Phase (SDD-P) | `sdd phase new` → spec planning | Strict Loop per spec | `sdd phase done` after all specs merged |
| Spec | `sdd spec new` → plan/task authoring | Strict Loop → archive → push → PR | PR merge → auto Merged in phase.md |
| spec-x (SDD-x) | `sdd spec new` (no phase) | Same as Spec | `sdd specx done` → queue.md update |
| FF | User approval only | Direct commit on feature branch | No state.json change |
| Icebox | Add to queue.md Icebox section | NON-EXECUTABLE | Promote to Phase or spec-x |

§6.3에 완료 체크리스트 추가:

### [MODIFY] `README.md`

- sdd 명령 표: `phase new --base`, `phase done`, `specx done`, `queue` 추가
- 슬래시 커맨드 표: 현재 실제 커맨드명으로 정리
- "작업 유형 모델" 섹션 신규 추가
- 워크플로 요약: NOW/NEXT/phase base branch 반영

## 🧪 검증 계획 (Verification Plan)

### 수동 검증
1. hk-align.md 변경 후 `/hk-align` 실행 시 NOW/NEXT 출력 확인
2. README.md의 sdd 명령과 실제 `sdd help` 출력 대조

## 🔁 Rollback Plan

- 모든 변경이 문서이므로 git revert 한 번으로 원복

## 📦 Deliverables 체크

- [x] spec.md 작성
- [x] plan.md 작성 (이 파일)
- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
