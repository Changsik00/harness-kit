# phase-16: Reliability Layer 강화

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-{N}-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-16` |
| **상태** | Planning (대기) |
| **시작일** | 미정 |
| **목표 종료일** | 미정 |
| **소유자** | dennis |
| **Base Branch** | `phase-16-reliability-layer` (2026-05-16 mid-phase 전환 — 결정 기록 표 참조) |

## 🎯 배경 및 목표

### 현재 상황

외부 진단(velog: 80-problem-in-agentic-coding) 과 추가 제안서(5 축 + 5 차별화 + 포지셔닝) 를 검토한 결과, 본 키트가 *AI 가 만든 복잡도를 통제하는 reliability 계층* 으로 자리잡으려면 다음 영역에 *얇은 보강* 이 필요하다는 결론에 도달했다.

- **RCA (Root Cause Analysis) 시스템 부재** — 실패가 surface patch 로 끝나고 invariant 로 승격되지 않는다.
- **ADR 인프라는 있으나 *활성화 트리거* 없음** — 결정이 walkthrough 결정 표에 갇히고 장기 자산으로 누적되지 못한다.
- **산출물(ADR / RCA / walkthrough 결정 표) 의 *type* 정규화 부재** — grep 으로 *invariant 만* / *failure-pattern 만* 추출 불가.
- **Stale 결정/ADR 탐지 부재** — 결정이 *지운 모듈을 참조* 해도 키트가 감지 못한다.
- **포지셔닝 미명시** — 키트의 *진짜 정체* ("AI 코딩 프레임워크가 아니라 AI-assisted engineering 의 reliability 계층") 가 README / 슬로건 / version.json 어디에도 박혀 있지 않다.

본 phase 는 위 5 영역을 *thin orchestration* 철학과 양립하는 *얇은 보강* 으로 도입한다 — 새 workflow engine 도입 / capability matrix 강제 / cost dashboard 같은 무거운 항목은 명시적으로 *Out of Scope*.

### 목표 (Goal)

본 phase 가 끝났을 때:

1. RCA 가 *팀 자산* 으로 누적되는 경로가 열려 있다 (`/hk-rca` → `docs/rca/` → grep).
2. 산출물 type system 이 일관되어 reliability layer 가 *검색 가능한 지식 베이스* 가 된다.
3. ADR 가 *적극 작성* 되도록 트리거가 박혀 있다.
4. Stale 결정/ADR 이 `sdd status` 한 줄로 감지된다.
5. 키트의 포지셔닝이 외부에 *reliability layer* 로 명확히 노출된다.

### 성공 기준 (Success Criteria) — 정량 우선

1. `.harness-kit/agent/templates/rca.md` 도입 + `/hk-rca` 슬래시 커맨드 동작 — 최소 1 회 RCA 작성으로 검증 (`docs/rca/RCA-001-*.md` 생성).
2. 산출물 frontmatter 에 `type:` 슬롯 정규화 — `grep -rh "^type:" docs/rca docs/decisions` 결과가 정규 type 집합(decision / invariant / failure-pattern / convention / tradeoff) 중 하나로 닫힘.
3. `sdd status` drift 섹션에 *stale ADR/결정 탐지* 라인 추가 — fixture(지운 모듈 참조 ADR) 에서 정확히 감지.
4. README / `version.json` / `.harness-kit/agent/constitution.md` 에 "reliability layer" 키워드 노출 — `grep -l "reliability layer"` 가 3 곳 hit.

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-{N}-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-16-01` | rca-and-knowledge-types | P0 | Merged | `specs/spec-16-01-rca-and-knowledge-types/` |
| spec-16-02 | adr-activation-trigger | P1 | Backlog | (미생성) |
| spec-16-03 | stale-decision-detect | P2 | Backlog | (미생성) |
| spec-16-04 | reliability-positioning | P1 | Backlog | (미생성) |
| `spec-16-02` | adr-activation-trigger | P? | Active | `specs/spec-16-02-adr-activation-trigger/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-16-01 — RCA 시스템 도입 + Knowledge Type 슬롯

- **요점**: `templates/rca.md` + `/hk-rca` 슬래시 커맨드 + 산출물 frontmatter `type:` 슬롯 (decision / invariant / failure-pattern / convention / tradeoff) 정규화.
- **방향성**: RCA 5 섹션(symptom → reproduction → root cause → invariant → prevention) 형식 강제. type 슬롯은 RCA 가 *첫 사용자* — ADR / walkthrough 결정 표는 점진 적용. `docs/rca/RCA-{NNN}-{slug}.md` 경로.
- **참조**:
  - 외부 진단 #3 RCA / #2 Decision Ledger: https://velog.io/@typo/80-problem-in-agentic-coding
  - 추가 제안서 §3 Knowledge Type System / §D RCA Pipeline
- **연관 모듈**: `sources/templates/rca.md` (신규), `sources/commands/hk-rca.md` (신규), `.harness-kit/agent/templates/rca.md`, `.claude/commands/hk-rca.md`

### spec-16-02 — ADR 활성화 트리거

- **요점**: spec.md / plan.md 에 "이 결정 중 ADR 가치 있는 것" 체크 1 줄, walkthrough 결정 표 → ADR 추출 가이드, `/hk-spec-critique` 출력에 ADR 후보 추출 1 섹션.
- **방향성**: 강제하지 않음 — *권장 + 추출 가이드*. ADR frontmatter 는 spec-16-01 의 type 슬롯을 사용. ADR-001 (knowledge-types) 가 본 spec 의 첫 산출물 후보.
- **참조**:
  - 외부 진단 #2 Decision Ledger / 추가 제안서 §2 Verification Engine
  - `.harness-kit/agent/constitution.md` §6.3 ADR 정의
- **연관 모듈**: `sources/templates/spec.md` / `plan.md` / `walkthrough.md`, `sources/commands/hk-spec-critique.md`

### spec-16-03 — Stale ADR / 결정 탐지 (drift 확장)

- **요점**: `sdd status` drift 섹션에 *지운 모듈 참조하는 ADR* / *TTL 초과 결정* 한 줄 추가.
- **방향성**: 가벼운 grep 기반 검사 — *contradiction 자동 탐지* 같은 무거운 항목은 명시적 Out of Scope. spec-16-01 의 type 슬롯과 spec-16-02 의 활성화된 ADR 이 선행되어야 의미 있음.
- **참조**:
  - 외부 진단 #6 Spec Drift / 추가 제안서 §4 Entropy Management / §A Architectural Drift Detector
- **연관 모듈**: `sources/bin/sdd` (drift 함수), `.harness-kit/bin/sdd`

### spec-16-04 — Reliability layer 포지셔닝

- **요점**: README 슬로건 / `version.json` description / `.harness-kit/agent/constitution.md` 톤에 "reliability layer for AI-assisted engineering" 키워드 정렬.
- **방향성**: 영문 한 줄 슬로건 (`Not an AI coding framework. A reliability layer for AI-assisted engineering.`) 위치 결정 — README 상단 부제 후보 1 순위. 한글 본문은 톤 보강만, 거버넌스 문서는 영문 톤 유지하되 *명시적 정체성* 한 줄 추가.
- **참조**:
  - 추가 제안서 *최종 슬로건* 영역
- **연관 모듈**: `README.md`, `version.json`, `sources/governance/constitution.md`, `.harness-kit/agent/constitution.md`

## 📌 결정 기록 (Review)

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Knowledge Type 슬롯을 별도 spec 으로 둘지 | A. spec-16-01 에 흡수 / B. 별도 spec | **A** | RCA 가 type 슬롯의 *첫 사용자* — 같은 spec 에서 도입해 응집성 확보. 별도 spec 은 *형식만 정의하고 사용자 없음* 상태로 끝날 위험. |
| Phase base branch 사용 여부 (당초) | 사용 / 미사용 | **미사용** | 4 spec, spec 간 의존 약함(03 만 01·02 선행), main 직 PR 로 충분. base branch 오버헤드 > 가치. |
| Phase base branch 사용 여부 (재논의 2026-05-16) | 유지 / 도입 | **도입** (`phase-16-reliability-layer`) | 당초 결정의 약점 발견: ① integration test 모일 곳이 main 자체라 회귀 발견 시 오염 / ② spec-16-03 이 16-01·02 둘 다 선행 필요 — 의존이 약하지 않음 / ③ phase review 가 단일 diff 입력을 갖지 못함. PR #116, #117 머지 commit 을 phase branch 로 relocate, main 은 bc8dfab(릴리스 0.9.1) 로 rewind. spec-16-03 / 04 는 phase branch 로 PR. |
| Out of Scope 명시 범위 | 좁게 / 넓게(Workflow engine 함정 항목 모두) | **넓게** | 외부 진단에서 추천했던 Context Kernel / Capability matrix / Cost routing 까지 *의도적으로 거름* — 본 phase 의 핵심은 *얇은 보강*. |

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 의 Done 조건 중 하나. 실행 명령 / 세부 fixture 는 spec 들 실행 단계에서 채운다.

### 시나리오 1: Knowledge Type 일관성

- **Given**: spec-16-01 / 02 머지 후 / `docs/rca/` 와 `docs/decisions/` 에 type 슬롯이 박힌 산출물이 1 개씩 있음
- **When**: `grep -rh "^type:" docs/rca docs/decisions`
- **Then**: 모든 결과가 정규 type (decision / invariant / failure-pattern / convention / tradeoff) 중 하나
- **연관 SPEC**: spec-16-01, spec-16-02

### 시나리오 2: Stale 탐지 회로

- **Given**: spec-16-03 머지 후 / 지운 경로(`src/removed-module.ts`) 를 참조하는 가짜 ADR 1 개 존재
- **When**: `bash .harness-kit/bin/sdd status`
- **Then**: drift 섹션에 *stale ADR 1 개* 라인이 출력
- **연관 SPEC**: spec-16-03

### 시나리오 3: Reliability 슬로건 회귀

- **Given**: spec-16-04 머지 후
- **When**: `grep -l "reliability layer" README.md version.json .harness-kit/agent/constitution.md`
- **Then**: 3 개 경로 모두 hit
- **연관 SPEC**: spec-16-04

### 통합 테스트 실행

```bash
# 본 phase 의 통합 테스트는 phase 시작 시 채움 — 현 시점 미정
```

## 🔗 의존성

- **선행 phase**: 없음
- **외부 시스템**: 없음
- **연관 ADR**: spec-16-02 에서 *첫 ADR* 가 발생할 가능성 (예: `ADR-001-knowledge-types`)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| Out-of-scope 슬라이드 — phase 가 *workflow engine 함정* 으로 비대해질 위험 | 키트 사이즈 폭증, 본 phase 의 *얇은 보강* 의도 손상 | 본 문서의 "Out of Scope" 정신(Capability matrix / Cost routing / Spec-Code Consistency engine 등) 을 spec 별 spec.md 에 재명시. 신규 spec 추가는 본 phase done 조건의 *정량 기준* 을 만족하는 한정 |
| RCA 사용 빈도가 낮을 가능성 | spec-16-01 의 *first user* 가 안 생겨 type system 이 dead letter | 성공 기준 *최소 1 회 RCA 작성* 으로 *도입 검증* 만 요구 — 강제 누적은 운영 시점 결정 |
| 영문 슬로건의 한국어 톤 충돌 | README/거버넌스 톤 비일관 | spec-16-04 에서 슬로건 위치 / 한영 비율을 *결정 기록* 으로 남김 — 1 옵션이 아닌 디자인 토론으로 처리 |

## 🏁 Phase Done 조건

- [ ] spec-16-01 / 02 / 03 / 04 모두 merge
- [ ] 통합 테스트 시나리오 3 개 PASS
- [ ] 성공 기준 4 개 정량 측정 결과 기록 (본 문서 "검증 결과" 섹션)
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 -->
