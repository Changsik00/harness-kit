# phase-02: 토큰 최적화 & 거버넌스 경량화

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-02-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-02` |
| **상태** | Planning |
| **시작일** | 2026-04-10 |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

도그푸딩 회고에서 확인된 가장 즉각적인 문제: 매 세션마다 거버넌스 문서(constitution.md + agent.md + align.md)를 전량 로드하여 **~5,050 토큰을 고정 소모**하고 있다. 또한 constitution과 agent.md 사이에 중복 기술이 있으며, 템플릿 7종을 매번 Read해야 하는 규칙(§4.4 CRITICAL VIOLATION)이 토큰 효율을 떨어뜨린다.

한편, hook 기반 강제 거버넌스가 일부 상황에서 워크플로를 과도하게 차단하여 오히려 생산성을 저해하는 사례가 보고됨. "강제"에서 "제안"으로 전환이 필요한 항목을 식별해야 한다.

### 목표 (Goal)

- 세션당 고정 토큰 소모를 **~5,050 → ~2,000** 이하로 절감
- 거버넌스 문서 중복을 제거하고 단일 진실 원천(Single Source of Truth) 확보
- 불필요한 강제 규칙을 제안 모드로 전환하여 워크플로 마찰 감소

### 성공 기준 (Success Criteria) — 정량 우선

1. CLAUDE.md @import로 자동 로드되는 토큰 합계 ≤ 2,000
2. constitution.md와 agent.md 사이 중복 기술 0건
3. check-plan-accept.sh가 차단 대신 경고를 출력하는 모드 기본값 전환

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-02-001 | governance-dedup | P0 | Backlog | `specs/spec-02-001-governance-dedup/` |
| spec-02-002 | two-tier-loading | P0 | Backlog | `specs/spec-02-002-two-tier-loading/` |
| spec-02-003 | enforce-to-suggest | P1 | Backlog | `specs/spec-02-003-enforce-to-suggest/` |
<!-- sdd:specs:end -->

### spec-02-001 — 거버넌스 문서 중복 제거

- **요점**: constitution.md와 agent.md의 중복 기술을 제거하고, 각 문서의 역할을 명확히 분리
- **방향성**: constitution = "무엇이 허용/금지되는가" (법률), agent.md = "어떻게 행동하는가" (절차). 현재 커밋 형식, 브랜치 규칙 등이 양쪽에 중복. constitution에서 규칙 정의, agent.md에서는 참조만. 예상 절감: ~1,200 토큰
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §3.3
  - `sources/governance/constitution.md` §9.2 vs `sources/governance/agent.md` §6.3
- **연관 모듈**: `sources/governance/`, `agent/`

### spec-02-002 — 2단계 로딩 전략

- **요점**: CLAUDE.md에는 핵심 규칙 요약(~10줄)만 인라인하고, `/align` 호출 시에만 전체 거버넌스를 Read로 로드하는 구조로 변경
- **방향성**: 현재 CLAUDE.md가 `@agent/constitution.md`, `@agent/agent.md`, `@agent/align.md`를 @import하여 매 세션 전량 로드. 대안: (1) 핵심 규칙 10줄을 CLAUDE.md에 직접 기술, (2) @import 제거, (3) `/align` 커맨드에서 전체 문서 Read. 일상적 작업(FF 모드 등)에서 ~3,000 토큰 절감
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §3.4 방안 B
  - `sources/claude-fragments/CLAUDE.md.append`
- **연관 모듈**: `sources/claude-fragments/`, `CLAUDE.md`, `sources/commands/align.md`

### spec-02-003 — 강제 → 제안 전환

- **요점**: hook의 기본 동작을 "차단(exit 2)"에서 "경고(exit 0 + stderr)"로 변경. 사용자가 원하면 `sdd hooks block`으로 강제 모드 전환 가능
- **방향성**: (1) check-plan-accept.sh — 현재 planAccepted=false일 때 Edit/Write를 차단. FF 모드나 문서 작업 시 과도한 차단 발생. 기본값을 warn으로. (2) check-test-passed.sh — push 전 테스트 통과 강제. 문서 전용 커밋에서도 차단되어 불편. 예외 경로 추가. (3) `sdd hooks` 서브커맨드로 모드 전환 UX 제공
- **참조**:
  - `docs/retrospective-2026-04-10-dogfooding-v1.md` §5.1c
  - `sources/hooks/check-plan-accept.sh`
  - `sources/hooks/check-test-passed.sh`
- **연관 모듈**: `sources/hooks/`, `sources/bin/sdd`

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: 경량 세션 토큰 검증
- **Given**: harness-kit이 설치된 프로젝트에서 새 세션 시작
- **When**: CLAUDE.md가 로드됨 (align 미호출 상태)
- **Then**: 거버넌스 관련 자동 로드 토큰이 2,000 이하
- **연관 SPEC**: spec-02-001, spec-02-002

### 시나리오 2: Hook 경고 모드 기본 동작
- **Given**: 기본 설치 상태 (hook mode 미지정)
- **When**: planAccepted=false 상태에서 Edit 시도
- **Then**: stderr에 경고 출력되지만 편집은 허용됨
- **연관 SPEC**: spec-02-003

### 통합 테스트 실행
```bash
./tests/test-phase-02.sh
```

## 🔗 의존성

- **선행 phase**: 없음 (독립 실행 가능)
- **외부 시스템**: 없음
- **연관 ADR**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| 2단계 로딩에서 에이전트가 규칙을 누락 | 거버넌스 위반 발생 | 핵심 규칙 요약의 완전성 검증 + /align 호출 강조 |
| 경고 모드 기본값으로 에이전트 방만 | main 직접 커밋 등 사고 | check-branch.sh는 차단 모드 유지 (안전 관련) |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 main 에 merge (위 표의 상태 = Merged)
- [ ] 통합 테스트 전 시나리오 PASS
- [ ] 성공 기준 정량 측정 결과 (본 문서 하단 "검증 결과" 섹션에 기록)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
