# spec-15-01: upgrade-danger-audit (Research Spec)

> 본 문서는 Research 타입 Spec (constitution §9). 코드 수정 0, 산출물은 본 문서 자체.
> **Plan Accept 시점** 에는 §1~§3 (배경, 질문, DoD) 만 채워져 있고,
> §4~§7 (분석, 비교, 권고, 후속 spec 명세) 는 실행 단계에서 채워집니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Spec ID** | `spec-15-01` |
| **Phase** | `phase-15` |
| **Branch** | `spec-15-01-upgrade-danger-audit` |
| **타입** | Research |
| **상태** | Planning |
| **Integration Test Required** | no |
| **작성일** | 2026-04-28 |
| **소유자** | dennis |

---

## §1. 배경 (Background)

phase-15.md §배경 참조. 요약: 최근 4건 update-related 버그(state 손실 / install 누락 / phase activate / gitignore dup)가 동일 패턴으로 발생 중이며, 현재 테스트가 "빈 fixture" 만 다루기에 stateful upgrade 시나리오가 사실상 무방비.

본 audit 은 그 위험 영역의 *지도* 를 그리는 것을 목표로 한다. 코드 수정 0, 산출물은 본 `spec.md` 의 §4~§7 + (필요 시) phase-15.md 갱신.

## §2. 연구 질문 (Research Questions)

본 audit 이 답해야 할 질문 — Plan Accept 시점의 검토 포인트.

### Q1. 과거 4건 버그의 공통 패턴은 무엇인가?

- 어떤 layer 에서 깨지는가 (state.json / 파일시스템 / queue marker / 사용자 작성물)?
- 공통 trigger 는 무엇인가 (덮어쓰기 / 부분 백업 / 신규 파일 / 멱등성 위반)?
- 동일 layer 에서 아직 발견되지 않은 잠재 버그가 있는가?

### Q2. install.sh / update.sh 의 덮어쓰기 정책은 무엇인가?

각 파일/디렉토리에 대해 다음 4분류 중 어디에 속하는지 표 작성:
- **OVERWRITE** — 항상 새 키트로 덮어쓰기 (예: `agent/constitution.md`)
- **MERGE** — 기존과 새 것을 머지 (예: `state.json` 의 일부 필드)
- **SKIP-IF-EXISTS** — 이미 있으면 손대지 않음 (예: 사용자 작성 phase.md)
- **APPEND-IDEMPOTENT** — 마커 영역 멱등 추가 (예: `.gitignore` 의 hk 영역)

명시되지 않은 (= "어쩌다 보니 그렇게 동작하는") 파일이 있는가?

### Q3. Stateful upgrade fixture 시스템을 어떤 형태로 만들 것인가?

≥ 2개 옵션 비교:
- **A) 함수 합성** — bash 함수로 `with_in_flight_phase()`, `with_pre_defined_phases()` 등 mixin
- **B) Declarative manifest** — JSON/YAML 로 시나리오 명세 → 파서가 fixture 생성
- **C) 다른 안** — research 중 도출

각 옵션의 trade-off (구현 복잡도 / 가독성 / 시나리오 추가 비용 / bash 3.2 호환성).

### Q4. 본 phase 의 "Go" 조건과 후속 spec 분할은?

- spec-15-02 / 15-03 / 15-04+ 의 명세를 어디까지 구체화할 수 있는가?
- 새로 발견된 잠재 버그를 본 phase 에 흡수할지, 후속 phase / Icebox 로 미룰지의 우선순위 기준 (P0/P1/P2)?
- "Go" = 본 phase 진행 가능 / "No-Go" = 추가 research 또는 phase 재정의 필요.

## §3. Definition of Done (Research)

constitution §9.1 기준:

- [ ] Trade-off Analysis ≥ 2 안 (Q3 의 옵션 A vs B 등)
- [ ] Prototype (해당 시) — 본 audit 은 코드 수정 0 이므로 적용 안 됨, 단 §6 권고에 "초안 의사코드" 포함 가능
- [ ] Go/No-Go 권고 명시
- [ ] §4 ~ §7 모두 채워짐:
  - §4 과거 버그 분석 (Q1)
  - §5 install/update 정책 단면 (Q2)
  - §6 fixture 설계 옵션 비교 + 권고 (Q3)
  - §7 후속 spec 명세 + 우선순위 (Q4)
- [ ] phase-15.md 의 spec 표 / 위험 섹션 갱신
- [ ] walkthrough.md / pr_description.md 작성 + ship + PR 생성

---

## §4. 과거 버그 분석

### §4.1 버그 카탈로그

각 spec 의 spec.md / 머지 commit diff 를 직접 정독한 결과.

| # | Spec / PR | Layer | Trigger | 1줄 fix 요지 |
|:---:|---|---|---|---|
| 1 | `spec-x-update-preserve-state` (#82, c771384) | `state.json` (.claude/state/) | install.sh 가 항상 새 state 템플릿으로 덮어쓰기 + update.sh 백업 화이트리스트가 4개 필드 (`phase, spec, planAccepted, lastTestPass`) 만 → `branch`, `baseBranch` 영구 소실 | jq 객체 백업으로 6개 필드 일괄 백업 + `jq * merge` 복원 |
| 2 | `spec-x-install-phase-ship-template` (#83, 4ea6fac) | 파일시스템 (`.harness-kit/agent/templates/`) | `sources/templates/` 에 `phase-ship.md` 추가했지만 `install.sh:262` 의 하드코딩 리스트 미갱신 → 신규 install 환경에서 템플릿 누락 → `/hk-phase-ship` 동작 불가 | install.sh 리스트에 한 단어 추가 |
| 3 | `spec-x-sdd-phase-activate` (#84, e40b770) | 사용자 작성물 (`backlog/phase-NN.md`) + sdd CLI 의사결정 | `sdd phase new` 가 max+1 알고리즘만 사용. 사용자가 `phase-03~07.md` 를 미리 작성해도 무시하고 `phase-08` 생성 → 사용자 작성 본문 사일런트 무시 | `sdd phase activate` 신설 + `phase new` 가드 |
| 4 | `spec-14-03-gitignore-idempotent` (#78, 2840c2b) | 파일시스템 (`.gitignore` — 사용자/키트 공유 영역) | install.sh 의 `.gitignore` 갱신이 `# harness-kit` 헤더 grep 한 번에만 의존. 헤더 누락 / 사용자 사전 라인 / 라인 일부 누락 시 라인 중복 또는 영구 누락 | 라인별 idempotent ensure 패턴 |

### §4.2 공통 패턴 (3개)

4건 모두 *동일한 형태의 실패* 라기보다는 **"같은 종류의 무방비"** 가 위치만 바꿔 나타난 것. 추출되는 패턴은 다음 셋:

#### Pattern A — Schema Drift (스키마 표류)

**형태**: 진실의 원천 (sources/ 또는 데이터 스키마) 이 자라는데, 그것을 *읽거나 처리하는 로직* 의 화이트리스트가 같이 자라지 않음 → 사일런트 누락.

- 버그 #1: `state.json` 스키마가 `branch`/`baseBranch` 로 자랐는데 update.sh 백업 화이트리스트는 4개에서 멈춤
- 버그 #2: `sources/templates/` 가 8개로 자랐는데 install.sh 복사 리스트는 7개에서 멈춤

**근본**: install/update 로직이 *명시적 화이트리스트* 로 작성되어 있어서 진실의 원천 변경 시 양쪽을 동기화해야 함. 단일-원천 sync 가 아닌 이중-기록 구조.

#### Pattern B — User Content Blindness (사용자 작성물 무시)

**형태**: 키트가 자기 영역과 사용자 영역의 경계를 *암묵적으로* 가정. 사용자가 키트가 관리한다고 여기는 영역에 작성물을 두면 키트가 그것을 인지 못 하고 덮어쓰거나 우회.

- 버그 #3: 사용자가 작성한 `phase-03.md` 가 `sdd phase new` 의 의사결정에 입력으로 들어가지 않음
- 버그 #4: 사용자가 미리 작성한 `.harness-kit/` 라인 또는 헤더 누락 상태가 install.sh 의 의사결정에 입력으로 들어가지 않음

**근본**: 사용자 영역과 키트 영역의 *명시적 경계 정책* 부재. 어떤 파일이 OVERWRITE / MERGE / SKIP-IF-EXISTS / APPEND-IDEMPOTENT 인지 코드 곳곳에 흩어져 있고 문서화되지 않음.

#### Pattern C — Insufficient Idempotency (조건부 멱등성)

**형태**: "재실행 시 동일 결과" 라는 멱등성 명세가 *해피 패스* 에서만 성립. 비정상 입력 (헤더 누락, partial backup 등) 에서는 누적/소실 발생.

- 버그 #1: state.json 의 6개 필드 중 4개만 멱등. 나머지 2개는 update 마다 소실 (음의 멱등성).
- 버그 #4: `.gitignore` 의 4 라인이 헤더 grep 1회로 묶여 처리. 헤더만 누락되면 4 라인 일괄 중복 추가.

**근본**: idempotent 의 단위가 너무 큼 (object 레벨 / 섹션 레벨). 라인/필드 단위로 내려가야 비정상 입력에서도 멱등.

### §4.3 동일 패턴의 잠재 위험 (추론)

각 패턴이 적용될 가능성이 있는 다른 위치 — §5 의 정책 단면 분석에서 검증할 후보.

#### Pattern A 잠재 위험

| 후보 | 의심 |
|---|---|
| `sources/commands/` (슬래시 커맨드) | install.sh 가 `commands/` 디렉토리를 어떻게 복사? 하드코딩 리스트인가, 디렉토리 sync 인가? 새 커맨드 추가 시 누락 가능성 |
| `sources/hooks/` | 동일. 새 hook 추가 시 install 누락 또는 settings.json 등록 누락 |
| `sources/governance/` | constitution / agent / align 외에 새 governance 파일 추가 시 |
| `sources/claude-fragments/` | 신규 fragment 추가 시 install.sh 가 자동 인식? |
| `tests/test-install-layout.sh` | 위 모든 항목이 테스트로 검증되는지 — 검증 자체의 화이트리스트도 표류 가능 |

#### Pattern B 잠재 위험

| 후보 | 의심 |
|---|---|
| `sdd spec new` | active phase 의 max seq+1 로 spec 생성. 사용자가 `spec-15-04-...md` 디렉토리를 미리 만들어 두면 어떻게 동작? `phase new` 와 동일 패턴 가능 |
| `CLAUDE.md` HARNESS-KIT 블록 | install 이 사용자 작성 영역 (블록 외부) 을 보존? 블록 안의 사용자 추가분은? |
| `settings.json` hook 영역 | 사용자가 추가한 hook 이 install 후에도 보존? |
| `queue.md` 마커 외부 (Icebox / 대기 Phase) | sdd 가 마커 외부를 손대지 않는다는 정책이 코드로 강제되는지 |
| `phase-NN.md` 의 사용자 작성 본문 | sdd 가 phase.md 본문을 어디까지 읽고 어디까지 갱신하는지 (이미 spec-x-sdd-phase-activate 에서 부분 확인) |

#### Pattern C 잠재 위험

| 후보 | 의심 |
|---|---|
| `CLAUDE.md` 의 `@.harness-kit/CLAUDE.fragment.md` import 라인 | 라인 단위 멱등인가, 블록 단위인가? 헤더 누락 시 시나리오 동일하게 발생? |
| `settings.json` 의 hook 등록 | jq merge 인가 string append 인가? 동일 hook 등록 시 중복 가능성 |
| `sdd_marker_append` | 한 줄 단위 멱등 — common.sh 에서 확인되었으나 multi-line block 추가는? |
| `state.json` 의 신규 필드 추가 흐름 | install.sh 템플릿 갱신 + update.sh 백업 리스트 갱신 + 스키마 검증의 *3중 sync* 필요 — 어디서 끊어질지 |

## §5. install.sh / update.sh 덮어쓰기 정책 단면 (실행 시 채움)

### 정책 분류표

| 경로 패턴 | 정책 | 근거 코드 라인 | 사용자 영역 여부 |
|---|---|---|---|
<!-- 실행 시 채움 -->

### 정책 미명시 항목

<!-- 실행 시 채움 -->

## §6. Stateful Fixture 설계 옵션 비교 (실행 시 채움)

### 옵션 A: 함수 합성

<!-- 실행 시 채움 -->

### 옵션 B: Declarative manifest

<!-- 실행 시 채움 -->

### 권고

<!-- 실행 시 채움 -->

## §7. 후속 Spec 명세 (실행 시 채움)

### Go/No-Go 결정

<!-- 실행 시 채움 -->

### spec-15-02 명세 초안

<!-- 실행 시 채움 -->

### spec-15-03 명세 초안

<!-- 실행 시 채움 -->

### spec-15-04+ (P0/P1/P2 분류)

<!-- 실행 시 채움 -->

---

## ✅ Definition of Done (체크리스트)

- [ ] §4 과거 버그 분석 작성
- [ ] §5 install/update 정책 단면 작성
- [ ] §6 fixture 옵션 ≥ 2개 비교 + 권고
- [ ] §7 후속 spec 명세 + Go/No-Go
- [ ] phase-15.md 갱신 (필요 시)
- [ ] walkthrough.md / pr_description.md 작성
- [ ] PR 생성
