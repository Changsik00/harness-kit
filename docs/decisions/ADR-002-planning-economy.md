---
id: ADR-002
type: invariant
date: 2026-05-17
status: accepted
sources:
  - archive/specs/spec-x-planning-economy/walkthrough.md
linked:
  - "[[wiki/decisions]]"
  - "[[wiki/patterns]]"
  - "[[ADR-001]]"
updated: 2026-05-27
---

# ADR-002: Planning Economy & Inter-Spec Re-Validation

> **Note — 경로 표기와 stale ADR 검사 대상**: 본 ADR 의 inline backtick 경로는 `sdd status` 의 stale ADR 검사 대상입니다.
> 검사 패턴은 *inline backtick + 슬래시 + 확장자* 만. code fence 안 경로, 슬래시 없는 토큰, URL 은 무시됩니다.
> 코드 경로가 이동/삭제되면 stale 라인이 떠 ADR 갱신 신호가 됩니다.

## 📚 Context

SDD ceremony (`spec.md` + `plan.md` + `task.md` + Plan Accept + `walkthrough.md` + `pr_description.md` + PR + review) 는 토큰 + 시간 *고정비* — 작업 규모와 무관하게 약 6,000-8,000 토큰 + 사용자 검토 시간 소비. 작업이 1-2 commit (오탈자 / 매니페스트 sync / 안내 1 줄) 이면 ceremony 가 작업보다 크고 ROI 음수.

또한 phase.md 의 spec 표 (예: backlog/phase-17.md) 는 *작성 시점* 의 *예상* 인데, 다음 spec 시작 시 *직전 spec 의 실제 변경* 으로 가정이 깨졌는지 검증 부재. 결과: 옛 plan 으로 진행, 누락 발견 → 뒤늦은 sweep spec.

직접 증거 (phase-17):
- spec-17-03 가 `.harness-kit/cache.json` 분리 시 `install.sh` 의 cache 필드 작성 잔재 + `sources/commands/hk-update.md` 의 cache destination 안내 모순을 *미발견* → spec-17-05 sweep 으로 뒤늦게 처리. 직전 spec 의 *변경 영향 범위* 점검 했으면 자기 발견 가능했음.
- spec-17-04 / spec-17-05 가 "잡탕 cleanup" bundle 패턴으로 옳은 방향이지만 *습관* 으로 SDD 선택, *비용 의식* 부재.
- `/hk-phase-review` 가 phase-ship 직전 Critical 6 건 발견 — *늦은 발견*. 더 일찍 (각 spec 시작 시) 점검 했으면 1 회 sweep 으로 종결 가능.

## 🎯 Decision

본 ADR 은 세 *invariant* 박음. 세부 운영은 `sources/governance/agent.md` §11 (Planning Economy & Inter-Spec Re-Validation) 참조.

1. **SDD ceremony 는 고정비 — 작업 < ceremony 면 mode demote 의무**:
   - 1-2 task + 단일 파일 + 가역적 → **FF** (사용자 명시 승인 필요)
   - 3-5 task + 단일 영역 → **spec-x** (phase 없음) 또는 **bundle / phase FF** (phase 안)
   - 6+ task / cross-file invariant / 통합 테스트 → **spec**
   - 에이전트는 모든 alignment 시점에 모드 추정 + 1 줄 근거 보고. 사용자 결정.

2. **Phase plan 은 *draft*, 매 spec 시작 시 직전 변경 + 잔여 spec 표 재검증 의무**:
   - phase 안 다음 spec 시작 전: 직전 merged spec 의 `walkthrough.md` (이월 / 발견) + `git diff --stat` 점검
   - 잔여 spec 각각의 *방향성 / scope 크기 / bundle 가능성 / FF 강등 가능성* 평가
   - phase.md 의 spec 표는 contract 아님 — 재조정 자유

3. **Phase 컨텍스트에서는 bundle / phase FF 가 spec-x demote 보다 우선** (convention 측면):
   - 응집도 (thematic chunk) + ceremony 절감 둘 다
   - spec-x demote 는 *phase 가 끝났는데 잔재* 일 때만
   - 재조정 4 옵션: drop / bundle / phase FF / 계획대로 진행

## 📊 Consequences

- **긍정**:
  - 1-2 commit 작업의 토큰 ROI 음수 회피 (FF 권장 명시)
  - 직전 spec 변경 incorporate → silent drift 차단 (spec-17-03 → spec-17-05 패턴 사전 차단)
  - Phase 응집도 보존 (spec-x demote 회피)
  - `sdd spec new` 의 pre-flight 출력으로 *주의 환기* 자동
- **부정**:
  - pre-spec validation 단계가 *추가* 인지 부하 (단 *출력만*, gate 아님)
  - Bundle / FF demote 결정이 *판단력* 요구 — 자동화 안 됨
  - 사용자 검토 step 1 회 더 추가
- **중립**:
  - 기존 spec 진행 흐름과 호환 — pre-flight 무시해도 진행 가능. 점진 도입
  - 4 임계 표는 *가이드* — 경계 사례 판단 여전히 필요

## 🔀 Alternatives

- **자동 bundle / 자동 FF demote 실행**: 비채택. 판단력 + 사용자 명시 승인 필요. 자동화는 잘못된 demote risk (예: 1-2 commit 으로 보이지만 invariant 박힘).
- **`/hk-plan-economy` 전용 슬래시 커맨드**: 비채택. `sdd spec new` 안에 박는 게 자연 — 별 진입점 추가는 학습 부담 + 호출 누락 가능.
- **post-hoc `/hk-phase-review` 만 강화**: 비채택. phase-ship 직전 발견은 *늦음* (spec-17-05 가 5 번째 spec sweep 으로 증명). pre-spec 시점이 더 일찍 — 발견 1 spec 단위 빠름.
- **token cost 자동 추정 / 표시**: 비채택. 정확한 추정 어려움 (모델 / 컨텍스트 / 변경 범위 의존). 명시 임계 (1-2 task / 3-5 task / 6+ task) 로 간접 표현 충분.
- **§planning-economy 를 `constitution.md` 에 박음**: 비채택. constitution 은 *invariant law*, agent.md 는 *operational protocol*. 본 항목은 둘의 혼합 — operational 측면이 강해 agent.md §11 적합. invariant 핵심만 ADR-002 로 별 박음.

## 📌 Status

Accepted (2026-05-17, spec-x-planning-economy 머지 시점). 첫 사용자: 본 ADR 머지 후 모든 `sdd spec new` 호출 (phase 컨텍스트). 비-phase (spec-x) 작업도 §11.2 임계 적용.

## 🔗 Related

- **본 ADR 의 산출물**: spec-x-planning-economy
- **선행 ADR**: ADR-001 (Knowledge Type Vocabulary) — 본 ADR-002 가 ADR 메커니즘 두 번째 사용 사례. ADR 자산 자기 강화 검증.
- **연관 RCA**: RCA-001 (sdd ship marker bugs) — 같은 *recurring pattern → prevention* 접근. 본 ADR 의 invariant 는 잠재 RCA-002 (silent inter-spec drift) 사전 차단 목적.
- **거버넌스 연계**: `sources/governance/agent.md` §11 — 본 ADR 의 운영 세부
- **증거**: phase-17 회고 (spec-17-03 의 `install.sh` 누수 미발견 → spec-17-05 sweep)
- **메모리**: `feedback-sdd-economy` — 사용자 피드백 출처
