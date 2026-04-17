# phase-04: 옵셔널 Sub-agent 리뷰 시스템

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-04-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-04` |
| **상태** | Planning |
| **시작일** | — |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

도그푸딩 회고에서 **단일 에이전트의 확인 편향**이 가장 심각한 문제로 식별됨. 자기가 작성한 Spec을 자기가 검증하고, 자기가 작성한 코드를 자기가 리뷰하는 구조는 구조적으로 비판적 사고를 약화시킨다.

다만 sub-agent 호출은 추가 토큰 비용을 발생시키므로, **옵셔널**로 제공하여 사용자가 필요할 때만 호출하는 구조가 적합하다.

### 목표 (Goal)

- 독립 시점의 비판적 리뷰를 **사용자가 원할 때** 호출할 수 있는 슬래시 커맨드 제공
- 자동 호출이 아닌 **수동 트리거** 방식으로 토큰 비용 통제
- 리뷰 결과를 spec 디렉토리에 아카이브하여 감사 추적 가능

### 성공 기준 (Success Criteria) — 정량 우선

1. `/spec-review` 호출 시 독립 sub-agent가 spec.md + plan.md를 비판적으로 리뷰하고 결과 반환
2. `/code-review` 호출 시 독립 sub-agent가 현재 브랜치의 diff를 리뷰하고 결과 반환
3. 두 커맨드 모두 호출하지 않으면 토큰 소모 0

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-04-01 | spec-review-cmd | P1 | Backlog | `specs/spec-04-01-spec-review-cmd/` |
| spec-04-02 | code-review-cmd | P2 | Backlog | `specs/spec-04-02-code-review-cmd/` |
| `spec-04-02` | spec-review-cmd | P? | Active | `specs/spec-04-02-spec-review-cmd/` |
<!-- sdd:specs:end -->

### spec-04-01 — /spec-review 슬래시 커맨드

- **요점**: 독립 sub-agent가 현재 spec.md + plan.md를 비판적으로 리뷰하는 옵셔널 커맨드
- **방향성**: (1) `.claude/commands/spec-review.md` 생성. (2) Agent tool을 사용하여 별도 컨텍스트에서 리뷰 수행 지시. (3) 리뷰 관점: 요구사항 빈틈, 모호한 DoD, 누락된 엣지 케이스, 과도한 범위. (4) 결과를 `specs/spec-{N}-{seq}-{slug}/review.md`에 저장. (5) 사용자가 `/spec-review` 를 호출하지 않으면 토큰 소모 없음
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §4
  - prove_it 프로젝트의 독립 검증 에이전트 패턴
- **연관 모듈**: `sources/commands/`

### spec-04-02 — /code-review 슬래시 커맨드

- **요점**: 독립 sub-agent가 현재 브랜치의 코드 변경을 리뷰하는 옵셔널 커맨드
- **방향성**: (1) `.claude/commands/code-review.md` 생성. (2) `git diff main...HEAD`를 sub-agent에 전달. (3) 리뷰 관점: 보안 취약점, 성능 이슈, 테스트 커버리지, 코딩 컨벤션. (4) `/handoff` 전 호출을 권장하되 강제하지 않음
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §4
- **연관 모듈**: `sources/commands/`

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: Spec 리뷰 호출
- **Given**: spec.md와 plan.md가 작성된 상태
- **When**: 사용자가 `/spec-review` 호출
- **Then**: 독립 에이전트가 리뷰 결과를 반환하고 review.md에 저장
- **연관 SPEC**: spec-04-01

### 시나리오 2: 미호출 시 토큰 영향 없음
- **Given**: 전체 SDD 워크플로 진행
- **When**: `/spec-review`, `/code-review` 미호출
- **Then**: 추가 토큰 소모 0
- **연관 SPEC**: spec-04-01, spec-04-02

### 통합 테스트 실행
```bash
./tests/test-phase-04.sh
```

## 🔗 의존성

- **선행 phase**: phase-02 (토큰 최적화 완료 후 추가 토큰 예산 확보)
- **외부 시스템**: 없음
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| Sub-agent 토큰 비용이 예상보다 큼 | 사용자가 기능 회피 | 리뷰 범위를 제한하는 `--focus` 옵션 제공 |
| Sub-agent 품질이 메인 에이전트 대비 낮음 | 리뷰가 피상적 | 리뷰 프롬프트에 구체적 체크리스트 포함 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
