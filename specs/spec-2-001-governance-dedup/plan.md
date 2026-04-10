# Implementation Plan: spec-2-001

## 📋 Branch Strategy

- 신규 브랜치: `spec-2-001-governance-dedup`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] agent.md에서 규칙 본문을 삭제하고 constitution 참조로 대체하는 방향이 맞는지 확인
> - [ ] constitution.md의 역할이 "규칙 정의만"으로 한정되는 것에 동의하는지 확인

> [!WARNING]
> - [ ] 리팩토링 과정에서 규칙의 의미가 실수로 변경될 수 있음 — 각 변경에 대해 diff 검증 필요

## 🎯 핵심 전략 (Core Strategy)

### 역할 분리 원칙

| 문서 | 역할 | 포함하는 것 | 포함하지 않는 것 |
|:---:|:---|:---|:---|
| **constitution** | 법률 (WHAT) | 규칙 정의, 형식, 금지사항, ID 체계 | 절차, 단계별 행동 |
| **agent.md** | 절차 (HOW) | 행동 절차, 체크리스트, 도구 사용법 | 규칙 재기술 (참조만) |

### 중복 제거 전략 (항목별)

| # | 주제 | 조치 |
|---|---|---|
| 1 | 커밋 제목 형식 | agent.md §6.3에서 타입 목록+예시 삭제 → `(→ constitution §9.2)` 참조 |
| 2 | 브랜치 이름 규칙 | agent.md §5, §6.3에서 형식 재기술 삭제 → `(→ constitution §5.4)` 참조 |
| 3 | Pre-Push 테스트 | agent.md §6.3에서 삭제 → `(→ constitution §9.2)` 참조 |
| 4 | One Task = One Commit | agent.md §6.1에서 재언급 최소화 → `(→ constitution §7)` 참조 |
| 5 | Plan Accept 금지 | agent.md §0.4, §4, §6의 3회 반복 → §6 서두에 1회만 유지 + 참조 |
| 6 | 디렉토리 레이아웃 | constitution §5.3은 ID+경로 규칙만 유지, agent.md §4.1은 실용적 트리만 유지 (중복 경로 설명 제거) |
| 7 | 템플릿 강제 | constitution §4.4 규칙 유지, agent.md §4.2 표만 유지 (규칙 재기술 제거) |
| 8 | 한국어 요구사항 | constitution §4.4 정의 유지, agent.md에서는 §4 서두에 1회만 언급 |
| 9 | PR 생성 = 사용자 | constitution §9.2 수정: `/gh-pr` 등 슬래시 커맨드 허용 반영. agent.md §6.3 중복 삭제 |
| 10 | main 브랜치 보호 | agent.md §6.1, §7에서 재기술 최소화 → `(→ constitution §9.1)` 참조 |

### 실효성 정리 전략 (항목별)

| # | 주제 | 조치 |
|---|---|---|
| A | §6.5 Priority 1 (LSP) | 삭제 — Claude Code에서 LSP 접근 불가, 실행된 적 없음 |
| B | §6.5 Priority 3 (CLI 도구) | 삭제 — Claude Code 자체 도구(Grep, Glob, Edit)가 시스템 수준에서 강제됨 |
| C | §6.5 전체 축소 | Priority 2 내용을 "정적 분석 도구 우선 사용" 1~2줄로 축소, 독립 섹션 제거 |
| D | §6.6 Stack Awareness | 유지하되 "멈추라" 표현 완화 → "사용자에게 확인" |
| E | §2 sdd 경로 | `bin/sdd status` → `scripts/harness/bin/sdd status` 수정 |
| F | §4.3 번호 중복 | 두 번째 §4.3 (Hard Stop) → §4.4로 변경 |

## 📂 Proposed Changes

### 거버넌스 소스 (원본)

#### [MODIFY] `sources/governance/agent.md`
- §0: Plan Accept 중복 언급 → constitution §4.3 참조로 축소
- §2: sdd 경로 `bin/sdd status` → `scripts/harness/bin/sdd status` 수정
- §4: 한국어 요구사항 재기술 → constitution §4.4 참조
- §4.3 번호 중복 → 두 번째를 §4.4로 변경
- §5: 브랜치 형식 재기술 → constitution §5.4 참조
- §6.1: One Task = One Commit 재언급 → constitution §7 참조
- §6.1: main 브랜치 확인 → constitution §9.1 참조
- §6.3: 커밋 형식, Pre-Push, PR 생성 중복 → constitution §9.2 참조로 대체
- §6.5: Priority 1 (LSP) 삭제, Priority 3 (CLI 도구) 삭제, Priority 2를 인라인 축소
- §6.6: "멈추라" → "사용자에게 확인" 완화
- §7: main 직접 커밋 재언급 → constitution §9.1 참조

#### [MODIFY] `sources/governance/constitution.md`
- §9.2: PR 생성 규칙 수정 — "사용자만 생성" → "에이전트가 `/gh-pr` 등으로 생성 가능, 단 사용자 확인 후"

### 도그푸딩 결과물 (동기화)

#### [MODIFY] `agent/agent.md`
- `sources/governance/agent.md`와 동일한 변경 적용 (도그푸딩 동기화)

#### [MODIFY] `agent/constitution.md`
- `sources/governance/constitution.md`와 동기화 (§9.2 PR 규칙 변경 반영)

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
# 중복 검출 스크립트로 검증
# constitution과 agent.md 사이 동일 문장 검출 → 0건이어야 함
bash tests/test-governance-dedup.sh
```

### 수동 검증 시나리오
1. `sources/governance/agent.md`와 `agent/agent.md` diff → 동일해야 함
2. `sources/governance/constitution.md`와 `agent/constitution.md` diff → 동일해야 함
3. agent.md에서 constitution 참조 (`→ constitution §`)가 중복 제거된 10개 항목을 커버하는지 확인
4. 토큰 카운트 비교: 리팩토링 전후 합산 토큰 차이 ~1,200 감소 확인

## 🔁 Rollback Plan

- git revert로 단일 커밋 단위 롤백 가능
- 문서 전용 변경이므로 런타임 영향 없음

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
