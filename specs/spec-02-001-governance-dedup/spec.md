# spec-02-001: 거버넌스 문서 중복 제거 및 실효성 정리

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-02-001` |
| **Phase** | `phase-02` |
| **Branch** | `spec-02-001-governance-dedup` |
| **상태** | Planning |
| **타입** | Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

거버넌스는 두 문서로 구성:
- `constitution.md` (~130줄) — "무엇이 허용/금지되는가" (법률)
- `agent.md` (~221줄) — "어떻게 행동하는가" (절차)

두 문서 모두 CLAUDE.md의 `@import`로 매 세션 자동 로드되어 ~5,050 토큰을 고정 소모한다.

### 문제점

두 문서 사이에 **10개 항목의 중복 기술**이 존재:

| # | 주제 | constitution | agent.md | 중복 유형 |
|---|---|---|---|---|
| 1 | 커밋 제목 형식 | §9.2 (타입 목록+예시) | §6.3 (거의 동일 복사) | 완전 중복 |
| 2 | 브랜치 이름 규칙 | §5.4 (형식+예시) | §5, §6.3 (재기술) | 완전 중복 |
| 3 | Pre-Push 테스트 | §9.2 | §6.3 | 완전 중복 |
| 4 | One Task = One Commit | §7 (3줄 규칙) | §6.1 step 5 (재언급) | 참조 중복 |
| 5 | Plan Accept 금지 | §4.3 (Zero Tolerance) | §0.4, §4, §6 (3회 반복) | 과잉 반복 |
| 6 | 디렉토리 레이아웃 | §5.3 (경로 목록) | §4.1 (전체 트리) | 확장 중복 |
| 7 | 템플릿 강제 | §4.4 (규칙만) | §4.2 (규칙+표) | 확장 중복 |
| 8 | 한국어 요구사항 | §4.4 | §4, §5 | 참조 중복 |
| 9 | PR 생성 = 사용자 | §9.2 | §6.3 | 완전 중복 |
| 10 | main 브랜치 보호 | §9.1 | §6.1, §7 | 참조 중복 |

이 중복은:
- **~1,200 토큰 낭비** (전체의 ~24%)
- 규칙 변경 시 **양쪽 동기화 실패 위험** (Single Source of Truth 위반)
- 어느 쪽이 권위 있는 정의인지 **혼란**

또한 중복 외에도 **실효성 없는 규칙**과 **현실 불일치** 항목이 발견됨:

| # | 위치 | 내용 | 문제 유형 |
|---|---|---|---|
| A | agent.md §6.5 Priority 1 | IDE/LSP 위임 규칙 | Dead letter — Claude Code는 LSP 접근 불가 |
| B | agent.md §6.5 Priority 3 | `rg`, `fd`, `ast-grep` 도구 목록 + `sed/awk/grep` 금지 | Redundant — Claude Code 시스템이 자체 도구(Grep, Glob, Edit) 강제 |
| C | constitution §9.2 | "PR creation is delegated to the User" | 현실 불일치 — `/gh-pr`, `/bb-pr` 슬래시 커맨드가 이미 존재 |
| D | agent.md §6.3 | "PR creation is the User's responsibility" | C와 동일 (중복+불일치) |
| E | agent.md §2 | `bin/sdd status` 경로 | 오류 — 실제 경로는 `scripts/harness/bin/sdd status` |
| F | agent.md §4.3 | 섹션 번호 중복 (sdd 자동 갱신 + Hard Stop) | 번호 오류 |
| G | agent.md §6.5 전체 | Tool Resolution 3단계 체계 | A+B 삭제 시 Priority 2만 남음 → 섹션 축소 |

### 해결 방안 (요약)

1. **역할 분리 원칙**을 엄격히 적용하여 중복을 제거한다:
   - **constitution.md** = 규칙 정의 (WHAT). 모든 규칙의 단일 진실 원천.
   - **agent.md** = 절차 기술 (HOW). 규칙 자체를 재기술하지 않고 constitution 섹션을 참조.
2. **Dead letter 삭제**: 실효성 없는 LSP 규칙과 redundant 도구 목록 제거.
3. **현실 반영**: PR 생성 규칙을 `/gh-pr` 등 슬래시 커맨드 존재에 맞게 수정.
4. **오류 수정**: 경로, 섹션 번호 등 기술적 오류 수정.

## 🎯 요구사항

### Functional Requirements
1. constitution.md와 agent.md 사이 중복 기술을 0건으로 줄인다.
2. 각 문서의 역할 경계를 명확히 한다:
   - constitution: 규칙, 형식, 금지사항의 **정의**
   - agent.md: 규칙을 **실행하는 절차** (constitution 참조로 중복 제거)
3. agent.md에서 제거한 중복 부분은 `(→ constitution §X.Y 참조)` 형태로 참조만 남긴다.
4. Dead letter 삭제: §6.5 Priority 1 (LSP), Priority 3 (CLI 도구 목록) 제거.
5. §6.5를 단순화: Priority 2 (정적 분석) 내용만 남기고 섹션 축소.
6. constitution §9.2 PR 생성 규칙을 현실에 맞게 수정 (`/gh-pr`, `/bb-pr` 반영).
7. agent.md §2 sdd 경로 오류 수정, §4.3 섹션 번호 중복 수정.
8. `sources/governance/`와 `agent/` 양쪽 모두 동기화한다.

### Non-Functional Requirements
1. 리팩토링 후 두 문서 합산 토큰이 현재 대비 ~1,500 토큰 이상 감소.
2. 기존 동작(hook, sdd, slash command)에 영향 없음.
3. CLAUDE.md의 핵심 규칙 요약은 이 spec에서 변경하지 않음 (spec-02-002 범위).

## 🚫 Out of Scope

- CLAUDE.md 구조 변경 (spec-02-002)
- hook 동작 모드 변경 (spec-02-003)
- align.md 변경 (독립 문서이므로 이 spec 범위 외)
- 새 규칙 추가 (기존 규칙의 삭제/수정/현실 반영만 수행)

## ✅ Definition of Done

- [ ] constitution.md와 agent.md 사이 중복 기술 0건
- [ ] agent.md에서 제거된 모든 중복이 constitution 참조로 대체됨
- [ ] Dead letter (LSP, CLI 도구 목록) 삭제 완료
- [ ] PR 생성 규칙 현실 반영 완료
- [ ] agent.md 경로 오류 및 섹션 번호 오류 수정 완료
- [ ] `sources/governance/`와 `agent/` 동기화 완료
- [ ] 기존 테스트 (있는 경우) PASS
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-02-001-governance-dedup` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
