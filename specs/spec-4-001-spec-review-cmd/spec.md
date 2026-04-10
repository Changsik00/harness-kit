# spec-4-001: /spec-review 슬래시 커맨드

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-4-001` |
| **Phase** | `phase-4` |
| **Branch** | `spec-4-001-spec-review-cmd` |
| **상태** | Planning |
| **타입** | Feature |
| **Integration Test Required** | no |
| **작성일** | 2026-04-10 |
| **소유자** | Dennis |

## 📋 배경 및 문제 정의

### 현재 상황

현재 SDD 워크플로에서 에이전트가 spec.md와 plan.md를 작성하면, 같은 에이전트가 자신이 작성한 문서를 기반으로 실행한다. 독립적인 비판적 검토 단계가 없어 확인 편향(confirmation bias)이 구조적으로 발생한다.

### 문제점

- 에이전트가 자기 산출물을 자기가 검증하는 구조 → 요구사항 빈틈, 모호한 DoD, 누락된 엣지 케이스를 잡아내기 어려움
- 사용자가 직접 리뷰하지 않으면 품질 게이트가 사실상 없음
- sub-agent를 자동 호출하면 토큰 비용이 매번 발생하므로, 사용자가 필요할 때만 수동으로 트리거하는 방식이 적합

### 해결 방안 (요약)

`/spec-review` 슬래시 커맨드를 만들어, 독립 sub-agent가 현재 spec.md + plan.md를 비판적으로 리뷰하고 결과를 `review.md`에 저장하는 옵셔널 기능을 제공한다.

## 🎯 요구사항

### Functional Requirements
1. `/spec-review` 슬래시 커맨드 실행 시 독립 sub-agent가 현재 활성 spec의 `spec.md`와 `plan.md`를 읽고 비판적 리뷰를 수행한다
2. 리뷰 관점: 요구사항 빈틈, 모호한 DoD, 누락된 엣지 케이스, 과도한 범위, 아키텍처 리스크
3. 리뷰 결과를 해당 spec 디렉토리의 `review.md`에 저장한다
4. 커맨드를 호출하지 않으면 추가 토큰 소모가 없다 (옵셔널)

### Non-Functional Requirements
1. 리뷰는 한국어로 작성한다 (constitution §4.4)
2. 기존 슬래시 커맨드 구조(`sources/commands/`)와 동일한 패턴을 따른다
3. `install.sh` 실행 시 대상 프로젝트의 `.claude/commands/`로 자동 복사된다

## 🚫 Out of Scope

- `/code-review` 커맨드 (spec-4-002에서 별도 처리)
- 자동 호출 또는 hook 기반 강제 리뷰
- 리뷰 결과에 따른 자동 수정

## ✅ Definition of Done

- [ ] `sources/commands/spec-review.md` 슬래시 커맨드 파일 작성
- [ ] `install.sh` 실행 후 `.claude/commands/spec-review.md`로 복사 확인
- [ ] 수동 검증: `/spec-review` 호출 시 리뷰 결과가 `review.md`에 저장됨
- [ ] `walkthrough.md`와 `pr_description.md` 작성 및 archive commit
- [ ] `spec-4-001-spec-review-cmd` 브랜치 push 완료
- [ ] 사용자 검토 요청 알림 완료
