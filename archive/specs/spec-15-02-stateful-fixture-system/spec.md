# spec-15-02: stateful upgrade fixture 시스템

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-15-02` |
| **Phase** | `phase-15` (base: `phase-15-upgrade-safety`) |
| **Branch** | `spec-15-02-stateful-fixture-system` |
| **상태** | Planning |
| **타입** | Implementation |
| **Integration Test Required** | no (본 spec 은 헬퍼 자체 단위 테스트만. 실제 회귀 시나리오는 spec-15-03) |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

## 📋 배경 및 문제 정의

### 현재 상황

`tests/test-sdd-base-branch.sh:20-52` 의 `make_fixture()` 가 본 프로젝트의 fixture 헬퍼 패턴 — `mktemp -d` + sdd 복사 + git init + 빈 state. 다른 테스트들 (`tests/test-update.sh`, `tests/test-sdd-phase-activate.sh` 등) 도 비슷한 보일러플레이트를 *각자* 갖고 있음.

이는 두 가지 문제:
1. **중복**: 같은 setup 코드가 N 개 테스트 파일에 흩어짐.
2. **stateful 시나리오 부재**: `make_fixture()` 는 *빈 사용자 환경* 을 만들기만 함. "사용 중인 사용자" — in-flight phase / 사전 정의 phase / customized fragment / dirty queue / user hook — 를 합성하는 빌딩 블록이 없음.

### 문제점

spec-15-01 audit 의 §6 (fixture 옵션 비교) + §7.2 (spec-15-02 명세 초안) 가 결론:
- **옵션 A (함수 합성)** 권고 — 5~10 시나리오 규모에 적합, 기존 패턴과 자연스럽게 통합, bash 3.2 호환.
- 5개 mixin 함수가 5개 통합 테스트 시나리오 (phase-15.md §통합 테스트) 와 1:1 매핑.
- spec-15-03 (회귀 테스트) 는 본 spec 의 헬퍼를 사용해 시나리오 작성.

### 해결 방안 (요약)

`tests/lib/fixture.sh` 신규 — `make_fixture()` (base) + 5 mixin (`with_*`) 함수. `tests/test-fixture-lib.sh` 신규 — mixin 자체의 단위 테스트 (각 mixin 호출 후 fixture state 가 의도대로 변형되는지).

기존 `tests/test-sdd-base-branch.sh` 의 inline `make_fixture()` 는 본 spec 에서 건드리지 않음 (회귀 위험 회피). 신규 lib 는 *추가* 만 하고, 기존 사용처 마이그레이션은 후속 작업 또는 spec-15-03 자연스럽게.

## 🎯 요구사항

### Functional Requirements

1. **F1.** `tests/lib/fixture.sh` 가 source 가능. shellcheck 통과.
2. **F2.** `make_fixture()` 호출 → 빈 사용자 환경 디렉토리 경로 출력. 내부에 install.sh 결과 + git init + 깨끗한 state.json 포함.
3. **F3.** **`with_in_flight_phase <dir> [phase] [spec]`** — state.json 6 필드 (`phase, spec, branch, baseBranch, planAccepted, lastTestPass`) 채움 + `backlog/<phase>.md` + `specs/<spec>/spec.md` 생성.
4. **F4.** **`with_pre_defined_phases <dir> <phase-id>...`** — 가변 인자로 N 개 phase-NN.md 작성 (sdd phase activate 검증용).
5. **F5.** **`with_customized_fragment <dir>`** — `.harness-kit/CLAUDE.fragment.md` 에 식별 가능한 사용자 추가분 append (멱등성 / 보존 검증용).
6. **F6.** **`with_dirty_queue_icebox <dir>`** — `backlog/queue.md` 의 Icebox 섹션에 사용자 메모 추가.
7. **F7.** **`with_user_hook <dir>`** — `.claude/settings.json` 의 hooks 영역에 사용자 hook 추가 (Pattern B 검증용).
8. **F8.** 각 mixin 은 *조합 가능* — 같은 dir 에 N 개 mixin 을 순차 호출해도 서로 간섭 없음. (예: in_flight + dirty_queue + user_hook 동시 적용)
9. **F9.** `tests/test-fixture-lib.sh` 신규 — 각 mixin 마다 호출 전/후 검증 ≥ 3개 항목. 전체 5 mixin × 3 = 15+ checks.

### Non-Functional Requirements

1. **NF1.** bash 3.2+ 호환. `declare -A`, `mapfile`, `**` 미사용.
2. **NF2.** 본 lib 자체에 부수효과 0 — `source tests/lib/fixture.sh` 만으로는 아무 디렉토리도 생성 안 됨.
3. **NF3.** 함수 prefix 없음 (가독성 우선). 단 internal 함수는 `_fx_` prefix.
4. **NF4.** 기존 테스트 회귀 0 — `tests/test-sdd-base-branch.sh` / `test-update.sh` / 다른 테스트 모두 PASS 유지.

## 🚫 Out of Scope

- 기존 inline `make_fixture()` 사용처를 새 lib 로 마이그레이션 — 본 spec 은 lib *추가* 만. 마이그레이션은 후속 또는 spec-15-03 의 부산물.
- 통합 테스트 시나리오 5개 (phase-15.md §통합 테스트) 의 실제 회귀 테스트 작성 — spec-15-03.
- `tests/test-update.sh` 리팩토링 — 별 spec 후보.
- declarative manifest (옵션 B) 구현 — audit §6.5 권고대로 50+ 시나리오 임계점에서 별 spec.

## ✅ Definition of Done

- [ ] `tests/lib/fixture.sh` 신규 — `make_fixture()` + 5 mixin
- [ ] `tests/test-fixture-lib.sh` 신규 — 15+ checks, 모두 PASS
- [ ] 기존 테스트 스위트 회귀 0 (`bash tests/test-version-bump.sh` 가 자동 호출)
- [ ] shellcheck 통과 (선택, 환경에 있을 때)
- [ ] `walkthrough.md` / `pr_description.md` 작성 + ship + push
- [ ] PR 생성 (base: `phase-15-upgrade-safety`)
