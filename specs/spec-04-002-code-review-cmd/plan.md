# Implementation Plan: spec-04-002

## 📋 Branch Strategy

- 신규 브랜치: `spec-04-002-code-review-cmd`
- 시작 지점: `main`
- PR Target: `main`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 리뷰 관점 3개(spec 대비 구현, 코드 품질, 테스트 커버리지)가 적절한지
> - [ ] `code-review.md` 저장 위치가 spec 디렉토리 내부인 것에 동의하는지

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

spec-04-001과 동일한 패턴. 슬래시 커맨드 파일 하나(`sources/commands/code-review.md`)만 추가. Agent tool로 독립 컨텍스트에서 코드 리뷰 수행.

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **diff 범위** | `git diff main...HEAD` | main 대비 현재 브랜치의 전체 변경을 한 번에 리뷰 |
| **리뷰 관점** | spec 대비 구현 + 코드 품질 + 테스트 커버리지 | 추상적 관점 대신 코드 수준의 실질적 검증 |
| **결과 저장** | spec 디렉토리 내 `code-review.md` | spec 산출물과 함께 아카이브 |

## 📂 Proposed Changes

### 슬래시 커맨드

#### [NEW] `sources/commands/code-review.md`

- `/code-review` 슬래시 커맨드 정의
- sub-agent에게 `git diff main...HEAD` + `spec.md` 를 전달하여 코드 리뷰 수행
- 리뷰 관점: spec 대비 구현, 코드 품질(KISS/DRY/feature envy), 테스트 커버리지
- 결과를 `code-review.md`에 저장

### 도그푸딩 반영

#### [MODIFY] `.claude/commands/code-review.md`

- 수동 복사로 도그푸딩 프로젝트에도 반영

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
test -f sources/commands/code-review.md
head -3 sources/commands/code-review.md | grep -q "^---"
```

### 수동 검증 시나리오
1. `/code-review` 호출 → 리뷰 결과가 한국어로 출력됨
2. 리뷰 결과가 해당 spec 디렉토리의 `code-review.md`에 저장됨

## 🔁 Rollback Plan

- `sources/commands/code-review.md` 파일 삭제 후 재설치

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
