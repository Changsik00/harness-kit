# spec-x-planning-economy: Planning Economy & Inter-Spec Re-Validation

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-x-planning-economy` |
| **Mode** | SDD-x (solo, phase 없음) |
| **Branch** | `spec-x-planning-economy` (from `main`) |
| **상태** | Planning |
| **타입** | Governance + Refactor |
| **Integration Test Required** | no |
| **작성일** | 2026-05-17 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

SDD ceremony 는 토큰 비용 *고정비* — spec.md + plan.md + task.md + Plan Accept + walkthrough.md + pr_description.md + PR + review = 토큰 6-8천 ± 사용자 시간. 작업 단위가 1-2 commit (오탈자 / 매니페스트 sync / 안내 1 줄) 면 ceremony 가 *작업 자체보다 큼* — ROI 음수.

또한 phase.md 의 spec 표는 *작성 시점* 의 *예상* 인데, 다음 spec 시작 시 *직전 spec 의 실제 변경* 으로 가정이 깨졌는지 검증 안 함. 결과: 옛 plan 으로 진행, 누락 발견 → 별 spec sweep (예: spec-17-05 의 Critical 6 건).

### 문제점

1. **Inter-spec validation 부재**: `sdd spec new` 가 phase.md 표만 보고 다음 slug 자동 활성화. 직전 spec 의 walkthrough / diff / 이월 항목 점검 단계 없음.
2. **Scope economy 임계 없음**: 작업이 *FF 가 나은가, spec-x 가 나은가, spec 이 나은가, bundle 가능한가* 판단 휴리스틱 governance 부재. 사용자가 매번 직접 결정.
3. **Phase 컨텍스트 우선 원칙 부재**: phase 진행 중 작은 잔여 작업이 발견되면 spec-x 로 demote 하는 게 아니라 *phase 내 bundle 또는 phase FF* 가 응집도 + ceremony 절감 둘 다 우수. 가이드 없음.
4. **Phase plan = contract 오해**: phase.md spec 표를 "must do all" 로 해석. *draft* 임을 명시 안 함.

### 증거 (phase-17 회고)

- spec-17-03 가 cache 분리하면서 `install.sh:515-516` / `sources/commands/hk-update.md:108` 누수 *미발견* (Critical C1/C2). 직전 spec 의 *변경 영향 범위* 점검 했으면 자기 발견 가능.
- spec-17-04 / spec-17-05 가 "잡탕 cleanup" bundle 패턴으로 옳은 방향이지만 *습관* 으로 SDD 선택, *비용 의식* 부재.
- `/hk-phase-review` 가 phase-ship 직전 Critical 6 건 발견 — *늦은 발견*. 더 일찍 (각 spec 시작 시) 점검 했으면 1 회 sweep 으로 종결 가능.

### 해결 방안 (요약)

3 묶음 한 spec-x:

1. **`agent.md §planning-economy` 신설** — 재조정 4 옵션 표 + 핵심 원칙 (phase 우선 / bundle 우선 / draft 해석) + scope economy 임계 (FF / spec-x / spec / bundle 4 단계).
2. **`sources/bin/sdd` 의 `cmd_spec_new` pre-flight 강화** — phase 컨텍스트에서 spec 시작 직전 *직전 spec walkthrough 요약* + *남은 spec 표 요약* + *재조정 추천 1 줄* 출력. user 확인 후 spec 생성 진행.
3. **`ADR-002` 작성** — *Planning Economy* 의 invariant + convention 측면 long-lived 결정 박음.

## 🎯 요구사항

### Functional Requirements

1. **`sources/governance/agent.md` 에 §planning-economy 섹션 신설**:
   - **재조정 4 옵션 표** (phase 컨텍스트):
     - 방향성 깨짐 + 불필요 → spec 제거 (phase.md drop)
     - 방향성 유효 + scope 작음 + 잔여 작은 spec 있음 → **bundle** (잡탕 cleanup 패턴)
     - 방향성 유효 + scope 매우 작음 (1-2 commit) + bundle 대상 없음 → **phase FF** (spec 산출물 없이 phase branch 직접 commit)
     - 방향성 유효 + scope 적정 → 계획대로 spec 진행
   - **Scope economy 임계** (4 단계 - phase 없음 / phase 안 분리):
     - 1-2 task + 단일 파일 + 가역적 → **FF** (PR 없음, main 직접 — 사용자 명시 승인 필요)
     - 3-5 task + 단일 영역 → **spec-x** (phase 가 없을 때) / **bundle 또는 phase FF** (phase 안)
     - 6+ task / cross-file invariant / 통합 테스트 → **spec** (phase 또는 spec-x)
   - **핵심 원칙**:
     - SDD ceremony 는 고정비 — 작업 < ceremony 면 ROI 음수
     - Phase plan 은 *draft*, 매 spec 시작 시 재검증
     - Phase 컨텍스트에서는 bundle / phase FF 가 spec-x demote 보다 응집도 우수
     - FF 결정은 사용자 명시 승인 필요 (constitution §2.3)

2. **`sources/bin/sdd` `cmd_spec_new` pre-flight 강화**:
   - phase 활성 + 직전 merged spec 존재 시:
     - 직전 spec 의 `walkthrough.md` 의 *이월 항목* / *발견 사항* 섹션 요약 출력
     - 직전 spec 의 `git diff --stat` 요약 (변경 파일 / 라인 수)
     - phase.md 의 *남은* spec 표 출력 (다음 1 개 + 나머지 잔여 카운트)
     - "이 spec 의 가정이 여전히 유효합니까? (방향성/scope/bundle 가능성 점검)" 1 줄 메시지
   - 본 출력 후 spec 생성은 *기존대로* 진행 (gate 아님 — *주의 환기*).
   - phase 없음 또는 첫 spec 인 경우 위 출력 생략 (영향 없음).

3. **`docs/decisions/ADR-002-planning-economy.md` 작성**:
   - type: `invariant` (재검증 의무 + draft 해석) + `convention` (bundle / phase FF 우선) 묶음 — 첫 항목으로 *invariant* 선택
   - Context: 위 "현재 상황" 인용 + phase-17 증거
   - Decision: 위 §planning-economy 의 핵심 원칙 3 항 박음
   - Consequences / Alternatives / Status / Related (spec-x-planning-economy, ADR-001, RCA-001) 채움

### Non-Functional Requirements

1. **install 미러 sync** — `agent.md` 변경 → `.harness-kit/agent/agent.md` sync. `sdd` 변경 → `.harness-kit/bin/sdd` sync.
2. **회귀 0** — 기존 4 테스트 (marker-idempotent / drift-stale-adr / phase16-integration / phase17-integration) 모두 PASS 유지.
3. **bash 3.2+ 호환** — sdd 변경.
4. **거버넌스 영어 원칙** — `agent.md` 본문 영어 (메모리 `feedback_governance_english`). ADR-002 본문은 한국어 (docs/decisions 의 ADR-001 이 한국어 — 일관)
5. **non-breaking** — pre-flight 출력은 *주의 환기* — 기존 `sdd spec new` 동작 변경 안 함.

## 🚫 Out of Scope

- **`hk-spec-critique` 의 *작성 중* (mid-spec) 활용 확장** — 현재 post-hoc only. 별 spec 후보.
- **phase.md 템플릿 수정** — "draft" 표시 1 줄 추가는 본 spec 안 다룸. 다음 phase 의 template-update spec.
- **자동 bundle / 자동 FF demote 실행** — 본 spec 은 *추천* + *원칙* 만. 실행은 user 결정.
- **Token cost 자동 추정 / 표시** — 정확한 계산 어려움. 명시 임계 (1-2 task / 3-5 task / 6+ task) 로 간접 표현.
- **/hk-plan-economy 같은 신규 슬래시 커맨드** — `sdd spec new` 안에 박는 게 자연. 별 커맨드 회피.

## ✅ Definition of Done

- [ ] `sources/governance/agent.md` 에 §planning-economy 섹션 신설 + install 미러 sync
- [ ] `sources/bin/sdd` `cmd_spec_new` pre-flight 강화 (직전 spec 요약 + 잔여 spec 표 + 1 줄 재검증 메시지) + install 미러 sync
- [ ] `docs/decisions/ADR-002-planning-economy.md` 작성
- [ ] 회귀: marker-idempotent / drift-stale-adr / phase16-integration / phase17-integration 4 종 PASS
- [ ] 수동 검증: phase 활성 상태에서 `sdd spec new` 호출 시 pre-flight 출력 정상 동작 (fixture 또는 실 시연)
- [ ] `walkthrough.md` 와 `pr_description.md` ship commit
- [ ] PR 생성 (target: `main` — spec-x)

## 📑 ADR 후보

- [x] **ADR 가치 있는 결정 있음** → ADR-002-planning-economy (type: `invariant` 첫 항목 + `convention` 측면 묶음). 본 spec 의 task 에 ADR-002 작성 포함.
- [ ] 없음
