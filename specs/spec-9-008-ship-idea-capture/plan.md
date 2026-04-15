# Implementation Plan: spec-9-008

## 📋 Branch Strategy

- 신규 브랜치: `spec-9-008-ship-idea-capture`
- 시작 지점: `phase-9-install-conflict-defense`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] Idea Capture Gate의 "파킹" 개념 — 현재 작업을 중단하고 새 작업으로 전환 시 어떤 상태까지 저장할 것인가? (task.md 체크박스 상태? 별도 parking 마커?)
> - [ ] Opinion Divergence Protocol의 기록 위치 — backlog/queue.md Icebox vs phase.md 내 인라인 메모

## 🎯 핵심 전략 (Core Strategy)

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **변경 대상** | sources/ 원본 + .harness-kit/ 도그푸딩 사본 | 키트 원본이 SSOT, 도그푸딩은 동기화 |
| **섹션 배치** | constitution §5.5~5.6 + agent §2 확장 | 기존 번호 체계에 자연스럽게 삽입 |
| **구현 수준** | 에이전트 행동 규약만 (hook 없음) | Over-engineering 방지, 1차는 규약으로 |

## 📂 Proposed Changes

### constitution.md

#### [MODIFY] `sources/governance/constitution.md`

§5.4 뒤에 두 섹션 추가:

**§5.5 Idea Capture Gate**
- 작업 중 새 아이디어/요청 발생 시 즉시 실행 금지
- 먼저 `backlog/queue.md` Icebox에 한 줄 기록
- 사용자에게 두 선택지: (1) 현재 작업 완료 후 진행, (2) 현재 작업 파킹 + 새 작업 전환
- 문서화 없는 방향 전환 = VIOLATION

**§5.6 Opinion Divergence Protocol**
- 사용자 의견이 현재 계획/목표와 충돌할 때 에이전트가 충돌을 명시해야 함
- 충돌 명시 → 조율안 제안 → 사용자 선택 → 결정 기록

### agent.md

#### [MODIFY] `sources/governance/agent.md`

**§2 Bootstrap Protocol 확장** — 기존 5단계에 미완 항목 확인 추가:
- sdd status 후, queue.md Icebox + 미완 spec 확인
- 미완 항목 존재 시 사용자에게 알림

**§3 Alignment Phase 확장** — Idea Capture Gate 절차 참조 추가

### 도그푸딩 동기화

#### [MODIFY] `.harness-kit/agent/constitution.md`
#### [MODIFY] `.harness-kit/agent/agent.md`

sources/ 원본과 동일 내용으로 동기화 (복사)

## 🧪 검증 계획 (Verification Plan)

### 수동 검증 시나리오
1. constitution.md §5.5, §5.6 내용이 명확하고 기존 섹션과 일관성 있는지 확인
2. agent.md §2 확장이 기존 Bootstrap Protocol과 자연스럽게 통합되는지 확인
3. sources/ 원본과 .harness-kit/ 사본이 동일한지 diff 확인

## 🔁 Rollback Plan

- 거버넌스 문서 변경만이므로 `git revert` 한 커밋이면 충분

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
