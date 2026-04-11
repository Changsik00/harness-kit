# phase-7: SDD 프로세스 일관성 및 품질 강화

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-7` |
| **상태** | Planning |
| **시작일** | 2026-04-11 |
| **목표 종료일** | — |
| **소유자** | Dennis |

## 🎯 배경 및 목표

### 현재 상황

harness-kit을 실제 사용하면서 SDD 워크플로우 곳곳에 일관성 부족 및 품질 공백이 드러났다.

1. **Plan Accept 요청 방식**: 에이전트가 매번 다른 표현("plan accept 해주세요" vs "/hk-plan-accept" vs 그냥 진행)을 사용해 사용자가 어떻게 응답해야 하는지 불명확하다.
2. **PR 확인 UX**: PR 생성 전 에이전트가 보여주는 정보(브랜치, 제목, 타깃 등)와 확인 프롬프트(yes/no 유무)가 매번 달라 신뢰감이 떨어진다.
3. **작업 분류 기준**: Phase/SDD-x/FF 진입 기준이 모호하여 에이전트 판단이 흔들리고 사용자도 어떤 모드를 선택해야 할지 기준이 없다.
4. **Spec 자기비판 부재**: Spec/Plan 작성 시 단일 모델(Opus)의 단일 시각만 존재한다. 요구사항 분석 시 알려진 기법과의 비교, 대안 제시, 외부 비판 관점이 없어 설계 품질이 검증되지 않는다.

### 목표 (Goal)

- 에이전트의 SDD 절차 내 반복 행동(Plan Accept 요청, PR 확인)을 표준화한다
- Phase/SDD-x/FF 분류 기준을 constitution에 명확히 정의하여 판단 오차를 줄인다
- Spec/Plan 단계에 자기비판 단계를 도입하여 설계 품질을 높인다

### 성공 기준 (Success Criteria)

1. Plan Accept 요청 표현이 constitution/agent.md에 단일 형식으로 정의되고 에이전트가 이를 따름
2. PR 확인 UX가 `hk-gh-pr.md` 커맨드 스펙에 고정 형식으로 정의됨
3. constitution에 Phase/SDD-x/FF 분류 체크리스트가 존재하여 판단 근거가 문서화됨
4. Spec 작성 후 자기비판(critique) 단계가 워크플로우에 통합되어 실제 동작 확인됨

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-7-001 | plan-accept-consistency | P2 | Backlog | `specs/spec-7-001-plan-accept-consistency/` |
| spec-7-002 | pr-confirm-ux | P2 | Backlog | `specs/spec-7-002-pr-confirm-ux/` |
| spec-7-003 | scope-classification-rules | P1 | Backlog | `specs/spec-7-003-scope-classification-rules/` |
| spec-7-004 | spec-critique-workflow | P1 | Backlog | `specs/spec-7-004-spec-critique-workflow/` |
<!-- sdd:specs:end -->

### spec-7-001 — Plan Accept 요청 일관성

- **요점**: 에이전트가 Plan Accept를 요청하는 표현과 사용자 응답 방식을 단일 규격으로 고정
- **방향성**:
  1. `agent.md` §4.4에 "Plan Accept 요청 표준 문구" 정의 (고정 문구 + 허용 사용자 응답 목록)
  2. `constitution.md` §4.2에 응답 인식 규칙 추가 (허용: "plan accept", "accept", "/hk-plan-accept")
  3. `hk-plan-accept.md` 커맨드 설명에 동일 규칙 명시
- **연관 모듈**: `sources/governance/agent.md`, `sources/governance/constitution.md`, `sources/commands/hk-plan-accept.md`

### spec-7-002 — PR 확인 UX 일관성

- **요점**: PR 생성 전 에이전트가 사용자에게 보여주는 정보와 확인 프롬프트를 고정 형식으로 정의
- **방향성**:
  1. `hk-gh-pr.md` 커맨드에 "PR 확인 블록" 고정 형식 정의 (브랜치, 제목, 타깃, 커밋 수 항상 표시)
  2. `agent.md`에 PR 생성 전 명시적 사용자 확인 프로토콜 추가 (yes/no 형식 고정)
  3. `hk-handoff.md`의 PR 생성 단계도 동일 형식 적용
- **연관 모듈**: `sources/commands/hk-gh-pr.md`, `sources/commands/hk-handoff.md`, `sources/governance/agent.md`

### spec-7-003 — SDD-Phase/SDD-x/FF 분류 기준 강화

- **요점**: Phase/SDD-x/FF 진입 결정 체크리스트를 constitution에 명시하여 에이전트 판단 근거를 문서화
- **방향성**:
  1. `constitution.md` §2에 분류 결정 트리(decision tree) 추가
     - Feature/아키텍처 결정 → Phase 필수
     - 자족적 + chore/fix/docs/소규모 refactor → SDD-x
     - 단순 문구 수정/설정 변경 (코드 없음, 5분 이내) → FF
  2. `agent.md` §3 Alignment Phase에 분류 판단 의무 항목 추가
  3. 경계 사례(edge case) 예시 3~5개 문서화
- **연관 모듈**: `sources/governance/constitution.md`, `sources/governance/agent.md`

### spec-7-004 — Spec/Plan 자기비판 워크플로우

- **요점**: Spec 작성 후 별도 서브에이전트(Opus)가 요구사항을 비판·보완하는 단계를 SDD 워크플로우에 추가
- **방향성**:
  1. `hk-spec-critique` 슬래시 커맨드 신설 — 현재 spec.md를 읽고 다음을 수행하는 Opus 서브에이전트 호출:
     - 알려진 유사 기법/패턴과 비교 (웹 검색 포함)
     - 요구사항의 누락·모순·과잉 지적
     - 대안 접근 2~3개 제안 및 권장안 제시
  2. `agent.md` §4.4에 critique 단계를 spec.md 작성 후 선택적(optional) 단계로 추가
  3. spec 템플릿에 `## 🔍 Critique 결과` 섹션 추가 (선택 작성)
- **연관 모듈**: `sources/commands/` (신규), `sources/governance/agent.md`, `sources/templates/spec.md`

## 🧪 통합 테스트 시나리오

> 이 phase는 거버넌스 문서 및 커맨드 변경이 주이므로 자동화 통합 테스트 대신 수동 검증으로 대체.

### 시나리오 1: Plan Accept 일관성 확인
- **Given**: 에이전트가 spec/plan/task 작성 완료 후 대기 중
- **When**: 사용자가 "accept", "plan accept", "/hk-plan-accept" 중 하나를 입력
- **Then**: 에이전트가 모두 동일하게 실행 단계 진입
- **연관 SPEC**: spec-7-001

### 시나리오 2: PR 확인 블록 일관성 확인
- **Given**: 에이전트가 Push 완료 후 PR 생성 요청 단계
- **When**: `/hk-gh-pr` 또는 `/hk-handoff`에서 PR 생성 흐름 진입
- **Then**: 항상 동일한 형식(브랜치, 제목, 타깃, 커밋 수)의 확인 블록 표시 후 yes/no 대기
- **연관 SPEC**: spec-7-002

### 시나리오 3: 분류 판단 일관성
- **Given**: 사용자가 여러 요청을 한 번에 제시
- **When**: 에이전트가 Alignment Phase 수행
- **Then**: constitution §2 체크리스트 기준으로 각 항목의 분류 근거를 명시적으로 제시
- **연관 SPEC**: spec-7-003

### 통합 테스트 실행
```bash
# 수동 검증 — 자동화 테스트 없음
echo "수동 시나리오 검증으로 대체"
```

## 🔗 의존성

- **선행 phase**: phase-6 (완료)
- **외부 시스템**: 없음

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| spec-7-004 서브에이전트 비용 증가 | 매 spec마다 Opus 2회 호출 | 선택적(optional) 단계로 설계, 기본 off |
| constitution 분류 기준이 지나치게 엄격해질 경우 | 작은 작업도 Phase 강제 | edge case 예시로 유연성 확보 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC이 main에 merge
- [ ] 수동 시나리오 3종 PASS
- [ ] 사용자 최종 승인
