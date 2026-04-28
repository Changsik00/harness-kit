# spec-15-04: historical regression tests — 5개 stateful upgrade 시나리오

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-15-04` |
| **Phase** | `phase-15` (base: `phase-15-upgrade-safety`) |
| **Branch** | `spec-15-04-historical-regression-tests` |
| **상태** | Planning |
| **타입** | Tests |
| **Integration Test Required** | yes (본 spec 의 산출물이 phase-15.md §통합 테스트 시나리오의 구현체) |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

phase-15.md 는 5개 통합 테스트 시나리오를 정의 (in-flight phase / 사전 정의 phase / customized fragment / dirty queue / 신규 산출물 도입). 그러나 현재 어디에도 *실행 가능한 테스트* 가 없음. spec-15-02 가 `tests/lib/fixture.sh` 헬퍼를 만들었지만 *사용처는 헬퍼 자체의 단위 테스트* 뿐. 실제 시나리오 검증은 미구현.

또한 phase-15 의 성공 기준 #2: "위 4개 기존 버그(state 손실 / gitignore dup / 템플릿 누락 / phase activate)가 stateful 형태로 회귀 테스트 보유". 현재 각 버그는 자기만의 회귀 테스트가 있지만 *사용 중인 사용자 환경* 에서 update 한 시나리오로는 검증 안 됨.

### 문제점

1. **시나리오 ↔ 버그 1:1 검증 부재** — 4건 과거 버그가 stateful 시나리오 안에서 재발 시 즉시 탐지되어야 하는데, 현재는 fresh fixture 기준 단위 테스트만 있음. 도그푸딩 (자기 자신에 update) 으로만 잡혔던 버그가 자동화되지 않음.
2. **fixture lib 첫 사용처 부재** — spec-15-02 의 `tests/lib/fixture.sh` 가 *사용 안 되는* 헬퍼. 실 사용처 없이 dead code 위험.
3. **phase-15 성공 기준 미충족** — #2 항목이 본 spec 으로만 충족 가능.

### 해결 방안 (요약)

`tests/test-update-stateful.sh` 신규 — 5개 시나리오 × 검증 항목들. 각 시나리오는 `tests/lib/fixture.sh` 의 mixin 조합으로 "사용 중인 사용자" 환경 합성 + `bash update.sh` 실행 + 사후 상태 검증.

각 시나리오는 한 과거 버그 또는 잠재 패턴을 잠금:

| 시나리오 | 버그 잠금 | 검증 형태 |
|---|---|---|
| 1. in-flight phase | #82 (state 손실) | 6 필드 before/after 동일 (`jq -c '{6 fields}'`) |
| 2. 사전 정의 phase | #84 (phase activate) | phase.md md5 동일 + `sdd phase activate` 정상 |
| 3. 커스터마이즈 fragment | (Pattern B) | `TEST_USER_FRAGMENT` 마커 보존 |
| 4. dirty queue | (Pattern B) | `TEST_USER_ICEBOX_NOTE` 보존 + sdd 마커 손상 없음 |
| 5. 신규 산출물 / 멀티 install | #83 (phase-ship 누락), gitignore dup | 모든 8 템플릿 존재 + .gitignore hk 라인 정확 1회 |

## 🎯 요구사항

### Functional Requirements

1. **F1.** `tests/test-update-stateful.sh` 신규 작성, `tests/lib/fixture.sh` source.
2. **F2.** 5개 시나리오 모두 구현. 각 시나리오는 ≥ 2 checks. 총 ≥ 10 checks.
3. **F3 (시나리오 1).** `with_in_flight_phase` → update → state.json 의 6 필드 (`phase, spec, branch, baseBranch, planAccepted, lastTestPass`) before/after 일치. `kitVersion` 만 갱신.
4. **F4 (시나리오 2).** `with_pre_defined_phases phase-09 phase-10 phase-11` → update → 3개 phase.md 본문 md5 동일. `sdd phase activate phase-09` 정상 동작.
5. **F5 (시나리오 3).** `with_customized_fragment` → update → 마커 `TEST_USER_FRAGMENT` 가 보존되거나 (혹은 명시적 conflict 표시).
6. **F6 (시나리오 4).** `with_dirty_queue_icebox` → update → `TEST_USER_ICEBOX_NOTE` 보존 + sdd 마커 영역 (active/specx/done) 손상 없음.
7. **F7 (시나리오 5).** install → 8 템플릿 존재 (queue, phase, phase-ship, spec, plan, task, walkthrough, pr_description). update 2 회 실행 후 `.gitignore` 의 hk 관련 라인 4개 모두 정확히 1 회.

### Non-Functional Requirements

1. **NF1.** bash 3.2+ 호환.
2. **NF2.** 각 fixture 는 mktemp + trap cleanup. 실패 시에도 임시 디렉토리 정리.
3. **NF3.** 시나리오 간 독립 — 한 시나리오 fail 이 다른 시나리오 실행 차단 안 함 (`set -uo pipefail` 만, `set -e` 안 씀).
4. **NF4.** 회귀 — `tests/test-version-bump.sh` 가 자동 호출하는 전체 스위트 PASS.

## 🚫 Out of Scope

- `tests/test-update.sh` 의 기존 in-flight phase 검증 리팩토링 — 본 spec 은 *추가* 만. 마이그레이션은 후속.
- update.sh 의 *수정* — 본 spec 은 검증만. 시나리오 fail 발견 시 별 spec-x 또는 spec-15-05+ 로.
- phase 회고용 통합 테스트 메타-스크립트 (`/hk-phase-ship` 의 검증) — 본 spec 은 단위 테스트 형태. 메타-스크립트는 phase Done 시점 별도.

## ✅ Definition of Done

- [ ] `tests/test-update-stateful.sh` 신규 — 5 시나리오 × ≥ 2 checks = 10+ checks
- [ ] 모든 시나리오 PASS
- [ ] 회귀 스위트 PASS
- [ ] phase-15.md 성공 기준 #2 (4개 버그 stateful 회귀) 충족 표시
- [ ] `walkthrough.md` / `pr_description.md` ship + push + PR (base: `phase-15-upgrade-safety`)
