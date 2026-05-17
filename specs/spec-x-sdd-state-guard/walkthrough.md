# Walkthrough: spec-x-sdd-state-guard

> 본 문서는 *작업 기록*. 결정 과정, 사용자 협의, 검증 결과를 미래의 자신과 리뷰어에게 남깁니다.

## 📌 결정 기록

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| helper 위치 | (A) `state.sh` (B) `sdd` inline | A | state 검사 책임을 state.sh 에 응집. 호출자는 한 줄로 invoke. |
| `--force` 처리 위치 | (A) helper 가 옵션 파싱 (B) 호출자가 사전 파싱 후 가드 호출 skip | B | helper 가 호출자별 옵션 규약을 알 필요 없음. 호출자가 *자기 옵션* 만 파싱. |
| 메시지 분기 | (A) 통합 메시지 (B) spec-x / SDD-P 별도 분기 | B | 해결 명령이 다름 (`sdd specx done` vs `sdd ship`) — 잘못된 명령 안내는 footgun 가중. |
| `phase_new --force` 의미 | (A) 기존 "사전 정의 phase 우회" 만 (B) "사전 정의 phase + 활성 spec" 둘 다 우회 | B | 두 가드를 별도 플래그로 분리하면 사용자 인지 부담만 증가. 도그푸딩 단계라 호환성 이슈 없음. |
| 가드 적용 범위 | (A) destructive 진입점 전부 (B) `phase_activate` / `phase_new` / `spec_new` 한정 | B | (A) 는 `specx_new` 등 *새 spec 생성* 명령도 포함되는데, 의미가 다름. 본 spec 은 footgun 3건 한정. 나머지는 별도 검토. |

### ADR 승격 가이드

- [x] ADR 승격 대상 있음 → 작성될 예정: **`state-namespace-split`** (type: decision) — 본 spec 의 *단기 가드* 와 별도. state 공간 평면화의 근본 해결은 ADR + 별도 spec 로. 본 spec 머지 후 Icebox 또는 후속 spec-x 로 진행.

## 💬 사용자 협의

- **주제**: state.json 단일 평면 footgun 발견 경위
  - **사용자 의견**: "state 라는 같은 공간에 여러 절차적 이슈에 의해서 값에 대한 상황별 대처가 매끄럽지 않을때가 있는거 같아"
  - **합의**: 8건 구조적 이슈 진단 → 즉시 fix 가능한 3건 (`phase_activate` / `phase_new` / `spec_new` 가드 부재) 을 spec-x 로 분리. 나머지는 Icebox / ADR 후보.

- **주제**: 본 spec 직전 footgun 발현 경위
  - **사용자 의견**: 다른 세션에서 `sdd phase activate phase-01` 호출이 활성 spec-x 의 state 를 silent reset → hook 차단 우려 보고.
  - **합의**: 그 세션은 옵션 B (활성화 분리) 로 별도 진행. 본 spec 은 *구조적 fix* 만 담당.

## 🧪 검증 결과

### 1. 자동화 테스트

#### 신설 테스트 — `tests/test-sdd-state-guard.sh`
- **명령**: `bash tests/test-sdd-state-guard.sh`
- **결과**: ✅ Passed (13/13)
- **Check 항목**:
  - Check 1·2: `phase_activate` 가드 + `--force` 우회
  - Check 3·4: `phase_new` 가드 + `--force` 우회
  - Check 5·6: `spec_new` 가드 + `--force` 우회 + `sdd ship` 안내 검증
  - Check 7: 활성 spec 없는 상태 회귀 (`phase new`, `phase activate` 정상 동작)

#### 회귀 테스트
| 테스트 | 결과 |
|---|---|
| `test-sdd-phase-activate.sh` | ✅ 13/13 |
| `test-sdd-spec-new-seq.sh` | ✅ 5/5 |
| `test-sdd-phase-done-accuracy.sh` | ✅ 4/4 |
| `test-sdd-spec-completeness.sh` | ✅ 4/4 |
| `test-sdd-ship-completion.sh` | ✅ 9/9 |

### 2. 수동 검증

1. **Action**: `sdd specx new sdd-state-guard` (Pre-flight) → `state.spec = spec-x-sdd-state-guard`
   - **Result**: 본 spec-x 자체가 도그푸딩 사례. 가드 미적용 상태에서 Plan Accept → Strict Loop 진행.
2. **Action**: helper + 3 진입점 가드 적용 후 회귀 테스트
   - **Result**: 전체 5 카테고리 회귀 모두 통과. state-guard 신설 13/13.

## 🔍 발견 사항

- **암묵적 invariant 의 비용**: `phase` 가 null 일 때만 `spec` 이 spec-x 라는 *암묵 규칙* 이 명령마다 호출자가 챙기는 책임. helper 가 명시화하니 코드 한 줄 (호출 라인) + 메시지로 invariant 가 가시화됨. ADR 후보 1개 발견.
- **`phase_new --force` 의미 확장의 함의**: 도그푸딩 단계라 호환성 부담 없이 의미를 확장할 수 있었음. 외부 사용자 도입 후엔 같은 결정을 못 했을 것 — *도그푸딩의 자유* 가 일종의 비공식 이점.
- **회귀 fixture 의 정확성**: `test-sdd-phase-activate.sh` 의 fixture 는 활성 spec 없는 상태에서 시작 → 가드 추가가 *그 시나리오 외 회귀 없음*을 자동으로 보장. fixture 정책이 우연히 잘 맞아떨어진 케이스.
- **shellcheck 미설치 경고**: 모든 commit 에서 `[staged-lint] shellcheck 미설치` 경고. 본 spec 범위 밖이지만 환경 정비 후보.

## 🚧 이월 항목

- **state-namespace-split ADR + 마이그레이션 spec** — 근본 해결. 본 spec 은 가드만, 공간 분할은 별도 ADR + spec.
- **다른 destructive 진입점 검토** — `specx_new`, `phase_done` 등도 활성 spec 보호 필요 여부 별도 검토.
- **lastTestPass 글로벌 가시성** — spec 식별자 미포함. 다른 spec 의 테스트 통과가 현 spec hook 을 통과시킬 가능성. 별도 spec.
- **FF 모드 마커 부재** — FF 작업이 활성 spec 컨텍스트에 끼어들면 그 spec 의 commit 으로 오인될 수 있음. 거버넌스 보강 필요.
- **shellcheck 환경 정비** — 모든 staged-lint hook 경고. 별도 chore.

## 📅 메타

| 항목 | 값 |
|---|---|
| **작성자** | Agent + dennis |
| **작성 기간** | 2026-05-17 |
| **최종 commit** | `7704ccf` (가드 3종 완료) — ship commit 으로 갱신 예정 |
