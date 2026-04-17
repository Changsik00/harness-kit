# Implementation Plan: spec-02-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-02-02-two-tier-loading`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] @import 제거 후 `/align` 미호출 세션에서 에이전트가 거버넌스를 무시할 위험이 있는지. 핵심 규칙 요약 8줄이 충분한 가드레일인지 확인.

> [!WARNING]
> - [ ] `install.sh`가 기존 프로젝트에 이미 설치된 CLAUDE.md를 업데이트할 때 @import가 잔존할 수 있음. HARNESS-KIT 블록 교체 로직 확인 필요.

## 🎯 핵심 전략 (Core Strategy)

### 2단계 로딩 구조

```
세션 시작 (자동)          /align 호출 시 (수동)
┌─────────────────┐      ┌──────────────────────────┐
│ CLAUDE.md       │      │ align.md                 │
│  - 프로젝트 가이드│      │  @agent/constitution.md  │
│  - 핵심 규칙 8줄  │      │  @agent/agent.md         │
│  (~500 words)    │      │  @agent/align.md         │
└─────────────────┘      │  + sdd status            │
                          │  (~2,713 words 추가)      │
                          └──────────────────────────┘
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **CLAUDE.md.fragment** | @import 3줄 제거, 핵심 요약 유지 | FF/단순 세션에서 토큰 절감 |
| **align 커맨드** | 변경 없음 | 이미 @import로 전체 로드 중 |
| **install.sh** | 변경 없음 | HARNESS-KIT 블록 교체 로직이 이미 fragment 기반 |

## 📂 Proposed Changes

### 키트 소스

#### [MODIFY] `sources/claude-fragments/CLAUDE.md.fragment`
- `@agent/constitution.md`, `@agent/agent.md`, `@agent/align.md` 3줄 제거
- 핵심 규칙 요약 및 `/align` 안내 유지

### 도그푸딩 결과물

#### [MODIFY] `CLAUDE.md`
- HARNESS-KIT 블록 내 동일 @import 3줄 제거

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)
```bash
bash tests/test-two-tier-loading.sh
```

### 수동 검증 시나리오
1. CLAUDE.md.fragment에 `@agent/` 패턴이 없는지 확인
2. CLAUDE.md 본체에도 `@agent/` 패턴이 없는지 확인
3. `.claude/commands/align.md`에 `@agent/` 패턴이 여전히 있는지 확인
4. CLAUDE.md.fragment word count ≤ 150 words

## 🔁 Rollback Plan

- git revert로 단일 커밋 롤백
- @import 3줄 복원만으로 원상복구 가능

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
