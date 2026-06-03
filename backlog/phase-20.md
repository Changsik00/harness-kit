# phase-20: 디렉터 모드 (Director Mode) — context-preserving orchestration

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-20-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-20` |
| **상태** | Planning |
| **시작일** | 2026-06-03 |
| **목표 종료일** | 미정 |
| **소유자** | dennis |
| **Base Branch** | phase-20-director-mode |

## 🎯 배경 및 목표

### 현재 상황

ADR-005 가 "메인 에이전트 = context orchestrator" 전략(orchestrator–worker + offloading)을 이미 박았다. 하지만 그건 *암묵 정책*이다 — 에이전트가 알아서 위임하길 기대할 뿐, **사용자가 켜는 명시적 모드**도, SDD 워크플로 안에서의 *구체적 분업 계약*도, 다중 에이전트 *중재* 메커니즘도 없다.

동시에 운영 통증이 누적됐다: **phase/SDD ceremony 는 토큰 비용이 크고, 피로도가 높고, 느리다** (ADR-002 / ADR-004 의 동기와 같은 결). 그런데 ceremony 의 상당 부분(룰대로 진행하는 기계적 작성·실행)은 *판단이 아니라 노동*이다 — 디렉터(Opus)가 할 필요가 없다.

핵심 재정의(ADR-005 의 운영화):

> **오퍼스의 큰 context 윈도우 = 의도(intent)의 단일 보관소.** 디렉터는 작업 전체 흐름을 자기 context 에 들고, 워커(Sonnet/Haiku)는 *버려지는 context* 에서 일한 뒤 **증류된 결과만** 반납한다. 워커가 태운 토큰은 디렉터 윈도우에 안 들어온다. 비싼 Opus 의존도↓(비용 분산)는 *부수 효과*이고, **주목적은 긴 작업에서 의도의 흐름 유지(context 보존)** 다.

판단 기준이 "$ per task" 가 아니라 **"단위 작업당 디렉터 context 에 쌓이는 토큰"** 이 된다 — 어렵든 쉽든 디렉터 context 를 오염시키는 일이면 오프로드한다.

### 목표 (Goal)

사용자가 `/hk-director` 로 켜는 명시적 **디렉터 모드**를 구현한다. 이 모드에서 디렉터(Opus)는:
1. 사용자 의도를 *분명히 합의*한 뒤 팀을 편성해 위임하고,
2. SDD ceremony(작성·실행)를 워커(Sonnet)에 내려 *문서에 직접 쓰게* 하며 증류 보고만 받고,
3. 도메인 에이전트 간 설계 대화(front↔back API 협상)에 *중재자*로 참여해 아키텍처·over-engineering 을 교정하고,
4. review/critique 를 *단일 Opus 서브에이전트가 아니라* 페르소나 부여한 워커 패널(예: correctness/security/perf/test-coverage 렌즈)로 오케스트레이션하고 그 보고를 *종합·중재*(false positive 거르기, 우선순위)한다.

모델 티어는 역할(director/worker/scout) 기반으로 config 화하여 모델 이름 churn 에 견디게 한다.

### 성공 기준 (Success Criteria) — 정량 우선

1. **context 보존**: 디렉터 모드로 처리한 대표 작업에서, 워커가 소비한 토큰의 대부분(목표 ≥ 70%)이 디렉터 메인 context 에 유입되지 않음 (워커는 증류 결과만 반납 — ADR-005 동작의 측정 가능한 재현).
2. **분업 동작**: SDD 작업 1건을 planning=Opus / ceremony 작성·Strict Loop=Sonnet 워커로 끝까지 수행하고, 디렉터는 게이트·검수만 직접 수행 (도그푸딩 1회 이상).
3. **모드 가시성**: `/hk-director on/off` 토글 + persistent 플래그가 `sdd status` 와 doctor 에 노출됨.
4. **de-hardcode**: 거버넌스 문서에 모델 *이름*(`claude-haiku-4-5` 등) 하드코딩 0 — 역할→모델 매핑은 `harness.config.json` 에서.
5. **다운스트림 유용성**: 본 프로토콜이 메타 저장소 전용이 아니라 NestJS(nextmarket-api) 같은 다운스트림에서도 그대로 작동 (도그푸딩 원칙).

## 🧩 작업 단위 (SPEC + phase-FF)

> 실질적/불확실 → SPEC, 작고 가역적 1–2 commit → phase-FF.
> 아래는 **draft** — 매 spec 시작 시 §11.3 재검증으로 조정 (특히 spec-20-05 는 실험 결과에 따라 축소/제거 가능).

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`
> sdd가 ship 시 자동으로 `Merged`로 갱신합니다.

### spec-20-01 — director-switch (모드 토글 + 상태)

- **요점**: `/hk-director on|off` 슬래시 커맨드 + persistent 플래그(`installed.json` `directorMode`, `uxMode` 선례) + `sdd status`/doctor 노출. 모드 진입 시 디렉터 프로토콜(spec-20-02)을 context 에 주입.
- **방향성**: hk-ask-mode(토글 선례) + uxMode(플래그 선례) 패턴 재사용. `sdd config director-mode [on|off|toggle]`. 모드는 *커널이 아니라 지시 주입* — 기대치 명시(hk-align 이 거버넌스를 "강제"하는 것과 같은 강도).
- **참조**: `sources/commands/hk-ask-mode.md`, `.harness-kit/installed.json` (uxMode), ADR-005
- **연관 모듈**: `sources/commands/`, `sources/bin/sdd`

### spec-20-02 — director-protocol (행동 규약)

- **요점**: 디렉터 운영 루프를 agent.md 새 절로 명문화 — ① **의도 합의 핸드셰이크**(지시 → 되물어 확정 → 팀 편성) ② 위임·**증류 보고 루프** ③ 게이트·검수는 디렉터 보유 ④ over-dispatch 금지(threshold 존중, 단발은 인라인).
- **방향성**: ADR-005 의 5축을 *대화형 운영 절차*로 확장. §6.6/§6.7 과 연계, 중복 없이 참조. 핵심 불변식: "디렉터는 워커 transcript 가 아니라 distilled contract 만 흡수."
- **참조**: ADR-005, agent.md §6.6·§6.7, constitution §4(Alignment)
- **연관 모듈**: `sources/governance/agent.md`, `constitution.md`

### spec-20-03 — sdd-ceremony-split (planning=Opus / ceremony=Sonnet)

- **요점**: SDD 워크플로 안에서 분업 계약을 박는다 — 오퍼스: spec 의도·plan 핵심 결정·아키텍처·게이트. 소넷 워커: task.md 기계 분해·plan 스캐폴딩·**문서 직접 쓰기**·Strict Loop(TDD) 실행·walkthrough/pr 초안. 디렉터는 증류 + 스팟체크만.
- **방향성**: agent.md §6.1(Strict Loop)·§4.2(템플릿)에 "워커 위임 시 무엇을 누가" 명시. 함정 방지 불변식: *검토 위해 전문 재흡수 금지* → 워커는 증류 계약 반납. Plan Accept 게이트는 사람+디렉터 유지(소넷에 안 내림).
- **참조**: ADR-005, agent.md §6.1·§6.3, [[feedback-sdd-economy]]
- **연관 모듈**: `sources/governance/agent.md`

### spec-20-04 — role-based-model-config (3-tier de-hardcode)

- **요점**: director/worker/scout(=Haiku) 3역할을 정의하고 실제 모델은 `harness.config.json` 의 `models` 매핑으로 분리. 검색·grep sweep·로그 triage·기계 편집 = scout. 거버넌스에서 모델 이름 제거.
- **방향성**: §6.6 의 2-tier 표를 역할 기반으로 재작성 + config 슬롯 추가. `sdd config models` 조회/노출. 모델 세대 churn 에 견딤(constitution §13 rule-prune 결).
- **참조**: agent.md §6.6, `harness.config.json`, ADR-005
- **연관 모듈**: `sources/governance/agent.md`, `sources/bin/sdd`, `harness.config.json`

### spec-20-05 — mediated-design-dialogue (research/experiment)

- **요점**: front/back 도메인 에이전트가 API 계약을 주고받아 수렴하고, 디렉터가 그 소통에 끼어 아키텍처·over-engineering 을 *중재*하는 패턴. **종료 조건**(무한 핑퐁 방지)과 **증류**(디렉터는 협상 전문 흡수 X, 수렴 계약 + 자기 개입만)가 핵심 난점.
- **방향성**: Research Spec(§9) — 2안 비교 + POC + Go/No-Go. 먼저 *작동하는 최소 실험*으로 종료조건·중재 트리거를 검증한 뒤에만 거버넌스/명령으로 승격. 무리하면 patterns.md 한 줄로만 남기고 보류.
- **참조**: agent.md §9(Research Spec), §6.7(judge panel/adversarial verify 패턴)
- **연관 모듈**: `docs/wiki/patterns.md`, (실험) `scripts/research/`

### spec-20-06 — review-orchestration (페르소나 패널)

- **요점**: review/critique 를 단일 Opus 서브에이전트 → **디렉터가 오케스트레이션하는 페르소나 워커 패널**로 전환. 각 워커가 distinct 렌즈(correctness/security/perf/test-coverage/architecture)로 병렬 검토 → 디렉터가 종합·중재(중복 제거, false positive 거르기, 우선순위). hk-code-review / hk-spec-critique / hk-phase-review 에 적용.
- **방향성**: §6.7 "judge panel / perspective-diverse verify" 패턴. **깊이 vs 폭 트레이드오프**: 단일 Opus 의 *깊이*를 잃지 않도록, 각 페르소나는 *좁은 렌즈*(추론 부하↓)로 폭을 벌고 **깊은 추론은 디렉터 종합 단계**에 둔다. 페르소나 워커는 Sonnet(폭)+필요 시 Opus(깊은 렌즈) 혼합 — spec-20-04 config 로 결정. 단일 리뷰어 옵션도 fallback 유지(소규모 diff 는 패널 over-kill).
- **참조**: agent.md §6.6·§6.7(judge panel), `sources/commands/hk-code-review.md`·`hk-spec-critique.md`·`hk-phase-review.md`, ADR-005
- **연관 모듈**: `sources/commands/hk-code-review.md`, `sources/commands/hk-spec-critique.md`, `sources/commands/hk-phase-review.md`, `sources/governance/agent.md`

### phase-FF 예정 항목 (spec 미생성)

> 착수 시 §11.3 재검증으로 크기 재확인, 커지면 SPEC 승격.

| 항목 | 요점 | 예상 commit |
|---|---|:---:|
| README 모델 분배 표 갱신 | §6.6 재작성 후 README "모델 분배" 행을 역할 기반으로 동기화 | 1 |

## 📌 결정 기록 (Review)

> Phase 진행/리뷰 중 결정·합의·발견 누적 (→ agent.md §6.3.2).

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| **D1** Base branch 모드? | base(`phase-20-director-mode` → main 1 PR) / 일반(spec별 main PR) | **base** | 6 spec 을 phase 끝 1 PR 로 번들 → 리뷰 피로↓. 2026-06-03 사용자 승인 |
| **D2** spec-20-05 범위 | 정식 spec / research-only / 보류 | **research-only 시작** | 가장 새롭고 위험 — 종이 설계보다 작동 실험으로 종료조건 검증 우선 |
| **D3** 모드 강제 강도 | 커널 차단 / 지시 주입 | **지시 주입** | Claude Code 에 런타임 모드 커널 없음 — hk-align 과 같은 규약 강도 |

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 는 거버넌스·프로토콜 중심이라 통합 테스트는 **도그푸딩 기반 정성 검증** + 단위 테스트(명령 존재/config 스키마/플래그 토글).

### 시나리오 1: 분업 + context 보존 (도그푸딩)
- **Given**: `/hk-director on` 상태, 작은 SDD 작업 1건
- **When**: planning=디렉터, ceremony 작성·Strict Loop=Sonnet 워커로 수행
- **Then**: 워커가 증류 결과만 반납하고 디렉터 context 에 워커 토큰 대부분 미유입. 게이트·검수는 디렉터 직접. 산출물 품질이 직접 작성과 동등
- **연관 SPEC**: spec-20-02, spec-20-03

### 시나리오 2: 모드 토글 가시성
- **Given**: 클린 설치
- **When**: `sdd config director-mode on` → `sdd status` / doctor 실행
- **Then**: 플래그가 status·doctor 에 노출, off 시 사라짐
- **연관 SPEC**: spec-20-01, spec-20-04

### 시나리오 3 (research): 중재된 설계 대화
- **Given**: front/back 도메인 에이전트 + 디렉터
- **When**: API 계약 협상에 디렉터가 over-eng/아키텍처 중재로 개입
- **Then**: 종료조건 내 수렴 + 디렉터는 수렴 계약·개입만 흡수(전문 X)
- **연관 SPEC**: spec-20-05

### 통합 테스트 실행
```bash
# 단위 테스트 (명령/config/플래그)
bash tests/test-director-mode.sh
# 시나리오 1·3 은 도그푸딩 정성 검증 (walkthrough 에 증거 첨부)
```

## 🔗 의존성

- **선행 phase**: 없음 (ADR-005 가 토대)
- **외부 시스템**: 없음 (Claude Code Agent/Task 도구로 디스패치)
- **연관 ADR**:
  - `docs/decisions/ADR-005-context-orchestration.md` (토대)
  - `docs/decisions/ADR-006-director-mode.md` (본 phase 산출 — 초안 작성됨)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| 소넷 위임으로 산출물 품질 저하 | spec/plan 부실 | 의도·아키텍처·게이트는 디렉터 사수, 워커는 기계 작성만. 디렉터 증류 검수 의무 |
| 검토 시 워커 전문 재흡수 → context 도로 오염 | 목적 반감 | 워커는 distilled contract(SHA/status/결정)만 반납. 디렉터는 스팟체크 |
| over-dispatch (단발도 디스패치) | 느려지고 비싸짐 | threshold 존중 — 모드는 *기본값을 위임 쪽으로* 올릴 뿐 (§6.7) |
| 모델 이름 하드코딩 → churn 재수정 | 거버넌스 부채 | 역할 기반 config(spec-20-04) |
| spec-20-05 중재 패턴 over-engineering | 비용↑ 산출 불확실 | research-only 시작, 종료조건 검증 전 거버넌스 승격 금지 |
| review 패널화로 단일 Opus 의 *깊이* 상실 | subtle 버그 누락 | 페르소나는 좁은 렌즈로 폭, 깊은 추론은 디렉터 종합 단계에 보존. 소규모 diff 는 단일 리뷰어 fallback |
| 메타-ceremony (모드 설계가 무거운 SDD 됨) | 자가당착 | 설계 문서 1패스 확정 후 린하게. base 모드로 리뷰 번들 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC merge (D1 결정에 따른 PR 경로)
- [ ] 통합 시나리오 1·2 PASS (3 은 research Go/No-Go)
- [ ] 성공 기준 정량 측정 결과 기록
- [ ] ADR-006 accepted
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, context 보존 측정값, 도그푸딩 증거 -->
