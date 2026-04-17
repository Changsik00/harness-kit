# Implementation Plan: spec-04-01

## 📋 Branch Strategy

- 신규 브랜치: `spec-04-01-spec-review-cmd`
- 시작 지점: `main`
- 첫 task가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] 리뷰 프롬프트의 관점/체크리스트 항목이 적절한지
> - [ ] `review.md` 저장 위치가 spec 디렉토리 내부인 것에 동의하는지

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

슬래시 커맨드 파일 하나(`sources/commands/spec-review.md`)만 추가하면 된다. 이 파일은 `install.sh` 실행 시 `.claude/commands/spec-review.md`로 복사된다. Claude Code의 Agent tool을 활용하여 독립 컨텍스트에서 리뷰를 수행하도록 프롬프트를 설계한다.

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **리뷰 실행** | 슬래시 커맨드 프롬프트로 Agent tool 활용 지시 | 별도 스크립트 없이 Claude Code 네이티브 기능만 사용, 유지보수 최소화 |
| **결과 저장** | spec 디렉토리 내 `review.md` | spec 산출물과 함께 아카이브되어 감사 추적 가능 |
| **리뷰 관점** | 고정 체크리스트 5개 항목 | 일관된 품질, 프롬프트 비용 예측 가능 |

## 📂 Proposed Changes

### 슬래시 커맨드

#### [NEW] `sources/commands/spec-review.md`

- `/spec-review` 슬래시 커맨드 정의
- 현재 활성 spec의 `spec.md`와 `plan.md`를 읽고 비판적 리뷰를 수행하도록 지시
- 리뷰 관점: (1) 요구사항 빈틈 (2) 모호한 DoD (3) 누락된 엣지 케이스 (4) 과도한 범위 (5) 아키텍처 리스크
- 결과를 `review.md`에 저장

### 도그푸딩 반영

#### [MODIFY] `.claude/commands/spec-review.md`

- `install.sh` 실행 또는 수동 복사로 도그푸딩 프로젝트에도 반영

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

슬래시 커맨드 파일은 프롬프트 텍스트이므로 전통적 단위 테스트 대상이 아님. 대신 다음을 검증:

```bash
# 파일 존재 및 frontmatter 형식 검증
test -f sources/commands/spec-review.md
head -3 sources/commands/spec-review.md | grep -q "^---"
```

### 수동 검증 시나리오
1. `/spec-review` 호출 → 리뷰 결과가 한국어로 출력됨
2. 리뷰 결과가 해당 spec 디렉토리의 `review.md`에 저장됨
3. 커맨드를 호출하지 않았을 때 추가 토큰 소모 없음 (옵셔널 특성)

## 🔁 Rollback Plan

- `sources/commands/spec-review.md` 파일 삭제 후 재설치
- 슬래시 커맨드 하나만 추가하는 변경이므로 롤백 리스크 최소

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md archive
