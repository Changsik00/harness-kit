# phase-17: 정합성 fix (Coherence Fix)

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-{N}-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-17` |
| **상태** | Planning (대기) |
| **시작일** | 미정 |
| **목표 종료일** | 미정 |
| **소유자** | dennis |
| **Base Branch** | `phase-17-coherence-fix` (처음부터 — phase-16 mid-phase 전환 경험 학습) |

## 🎯 배경 및 목표

### 현재 상황

phase-16 (Reliability Layer 강화) 직후 *독립 Opus sub-agent 회고* 에서 두 종류의 self-credibility 손상이 식별됨:

- **Invariant 자기 위반**: spec-16-01 에서 작성한 RCA-001 (sdd ship 산출물 누락 패턴) 의 prevention 이 *phase-16 내내 4 회 위반*. `sdd ship`, `sdd spec new`, `sdd phase done` 의 marker 관련 동작이 phase 표 / queue 를 *append* 하거나 *제목 추출 누락* 하여 매번 수동 dedupe / 보정 필요. reliability layer phase 가 자기 RCA invariant 를 지키지 못함.
- **구조적 drift**: `.harness-kit/installed.json` 의 캐시 필드 (`lastVersionCheck`, `latestKnownVersion`) 가 tracked 파일 안에 있어 `check-kit-version.sh` hook 이 매 SessionStart 마다 워킹트리 dirty 를 만듦. phase-ship 의 *cleanliness 가정* 을 매번 위배.

또한 phase-16 회고에서 *얇은 보강 후보* 로 식별된 운영 자동화 부재:

- **Phase-level integration test 자동화 부재**: phase-16 시나리오 3 개의 PASS 검증을 매번 수동 grep 으로. phase-ship 자동화 진입점이 없음.
- **`doctor.sh` 의 신규 산출물 점검 누락**: spec-16-01/02 가 도입한 `docs/rca/`, `docs/decisions/`, `templates/rca.md`, `templates/adr.md` 가 doctor checklist 에 미포함 — install 미러 무결성 검사가 신규 자산을 모름.

본 phase 는 위 4 가지를 *코드 단 변경* 으로 해소한다. *workflow engine 추가 / 거버넌스 룰 추가* 같은 무거운 항목은 명시적 Out of Scope — *처음부터 얇은 보강* 철학 유지.

### 목표 (Goal)

본 phase 가 끝났을 때:

1. **sdd CLI 의 marker 관련 동작이 멱등** — 동일 spec 을 두 번 ship 해도 phase-N.md spec 표 행 수가 불변. 동일 phase 를 done 처리해도 queue.md done 항목이 정상 제목 형식.
2. **워킹트리 상시 깨끗** — SessionStart hook 이 `git status` 출력에 영향을 주지 않음. phase-ship cleanliness 가정 충족.
3. **Phase-level integration test 자동화** — `tests/test-phase16-integration.sh` 작성으로 phase-16 시나리오 3 개가 *한 명령* 으로 PASS 검증. 후속 phase 가 동일 패턴 채용 가능.
4. **`doctor.sh` 의 신규 경로 인지** — phase-16 산출물 (rca / decisions 디렉토리, rca.md / adr.md 템플릿) 이 doctor 점검 대상에 포함되어 install 미러 drift 가 즉시 노출.

### 성공 기준 (Success Criteria) — 정량 우선

1. **Marker idempotency 검증** — fixture spec-x 를 만들어 ship → ship 반복 시 `phase-N.md` 의 spec 표 행 수 변동 0. `sdd spec new` 도 동일 (slug 중복 시 거부 또는 in-place 갱신).
2. **`sdd phase done` 출력 형식** — `**phase-N** — 제목 — completed YYYY-MM-DD` 패턴 (phase-08 ~ 15 와 동일). title 누락 시 fail.
3. **SessionStart 후 `git status --porcelain` 빈 출력** — `check-kit-version.sh` hook 실행해도 워킹트리 영향 없음. tracked 캐시 필드 0.
4. **`tests/test-phase16-integration.sh` 작성 + 3 시나리오 자동 PASS** — Knowledge Type closure / Stale 탐지 / Reliability 슬로건 grep 모두 한 명령으로.
5. **`doctor.sh` checklist 확장** — `docs/rca/`, `docs/decisions/`, `templates/rca.md`, `templates/adr.md` 4 항목 점검 — fixture (template 누락) 시 doctor FAIL.

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-{N}-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-17-01` | sdd-marker-bugs-fix | P0 | Active | `specs/spec-17-01-sdd-marker-bugs-fix/` |
| spec-17-02 | installed-cache-separation | P1 | Backlog | (미생성) |
| spec-17-03 | phase-integration-test-and-doctor | P1 | Backlog | (미생성) |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-17-01 — sdd CLI marker 버그 3 종 fix

- **요점**: `sdd ship` / `sdd spec new` 의 phase-N.md spec 표 갱신을 *append* 가 아닌 *in-place update* 로 수정. `sdd phase done` 의 queue.md done entry 작성 시 phase-N.md H1 (`# phase-N: 제목`) 에서 제목 추출.
- **방향성**: 기존 `sdd:specs:start ~ end` marker 블록 안에서 *slug 매칭* 으로 update vs append 분기. 단위 fixture (테스트 spec-x 생성/ship 반복) 으로 멱등 검증. RCA-001 의 prevention 이 본 spec 의 *직접 구현*.
- **참조**:
  - `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` (본 spec 이 prevention 실현)
  - phase-16 회고 W5 (RCA-001 invariant 위반 4 회 재발) / W10 (productivity tax 정량화)
- **연관 모듈**: `sources/bin/sdd` (cmd_ship, cmd_spec_new, cmd_phase_done), `.harness-kit/bin/sdd`

### spec-17-02 — installed.json 캐시 필드 분리

- **요점**: `installed.json` 의 `lastVersionCheck` / `latestKnownVersion` 두 필드를 `.harness-kit/cache.json` 으로 이관. `cache.json` 은 `.gitignore` 처리. install.sh 가 기존 환경 마이그레이션 (필드가 installed.json 에 남아있어도 무시 / 새 cache.json 생성).
- **방향성**: 캐시는 *로컬 상태*, installed.json 은 *프로젝트 메타*. 책임 분리. `_drift_kit_version` 과 `check-kit-version.sh` 의 read/write 경로를 cache.json 으로 전환. 단위 검증: hook 후 `git status --porcelain` 빈 출력.
- **참조**:
  - phase-16 회고 C3 (워킹트리 항상 dirty)
- **연관 모듈**: `sources/hooks/check-kit-version.sh`, `sources/bin/sdd` (`_drift_kit_version`), `install.sh` (마이그레이션 로직), `.gitignore`

### spec-17-03 — phase-level integration test 자동화 + doctor 확장

- **요점**: `tests/test-phase16-integration.sh` 작성 — phase-16.md 시나리오 1/2/3 을 한 스크립트로. 추가로 `doctor.sh` 의 templates / 디렉토리 checklist 에 `docs/rca/`, `docs/decisions/`, `rca.md`, `adr.md` 4 항목 추가.
- **방향성**: phase-integration 테스트 스크립트는 *phase-NN-integration.sh* 명명 규약 신설 (후속 phase 도 동일 패턴). doctor 확장은 기존 checklist 함수에 항목 추가 — 최소 침습. `test-doctor.sh` (있다면) 도 신규 항목 검증.
- **참조**:
  - phase-16 회고 W2 (phase integration script 부재) / W6 (doctor 신규 경로 누락)
- **연관 모듈**: `tests/test-phase16-integration.sh` (신규), `sources/bin/doctor.sh` 또는 `doctor.sh`, `.harness-kit/bin/doctor.sh`

## 📌 결정 기록 (Review)

> Phase PR review 중 발생한 결정·합의·발견을 누적합니다. Spec walkthrough 의 결정 기록과 동일 패턴이며 Phase 레벨 living decision log 역할 (→ agent.md §6.3.2).

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Phase base branch 사용 시점 | 처음부터 / mid-phase 도입 / 미사용 | **처음부터** (`phase-17-coherence-fix`) | phase-16 의 mid-phase 전환 cost (rebuild + force-push + 회고 fix) 가 컸음. 본 phase 는 *정합성 fix* 라 통합 검증 지점 필수. 처음부터 base branch. |
| sdd marker 버그 3 종 묶음 vs 개별 spec | 묶음 / 개별 | **묶음 (spec-17-01)** | 셋 다 동일 marker 처리 패턴 (slug 매칭 + 갱신 분기). 개별 분리 시 review 3 회. 한 PR 로 review + 통합 fixture 1 회. |
| Out of Scope — phase-16 회고 W1/W3/W4/W7/W9 | 포함 / Icebox 잔류 | **Icebox 잔류** | W1/W3/W4/W7 은 *작은 문구/가이드/정책 수정* 으로 phase 단위 묶음 가치 낮음. W9 는 *측정 누적* 이 선행 필요 (3 개월+). 본 phase 의 *코드 정합성* 테마와 다름. spec-x 또는 별 phase. |
| 접근성 개선 (phase-18 후보) 와 분리 | 통합 진행 / 분리 | **분리** | 접근성 = *외부 노출*, 정합성 = *내부 일관성*. 같은 phase 에 묶으면 scope 폭주. 정합성을 먼저 완수해야 외부 노출 시 self-credibility 확보. |

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 의 Done 조건 중 하나. 자세한 구현은 각 spec 의 task.md / `tests/`.

### 시나리오 1: Marker 멱등성

- **Given**: 임시 fixture phase + spec-x 작성 (`phase-99-fixture.md`, spec-x-marker-test)
- **When**: spec-x ship 후 다시 ship / spec new 후 다시 spec new
- **Then**: `phase-99-fixture.md` 의 spec 표 행 수가 *최초 1 회 ship 후* 와 동일 (중복 0)
- **연관 SPEC**: spec-17-01

### 시나리오 2: Cache separation

- **Given**: spec-17-02 머지 후 / `installed.json` 에 `lastVersionCheck` / `latestKnownVersion` 필드 부재 / `.harness-kit/cache.json` 존재 (gitignore 됨)
- **When**: SessionStart hook (`check-kit-version.sh`) 실행 후 `git status --porcelain`
- **Then**: 빈 출력 (워킹트리 변경 0)
- **연관 SPEC**: spec-17-02

### 시나리오 3: Phase integration self-test

- **Given**: spec-17-03 머지 후 / `tests/test-phase16-integration.sh` 존재
- **When**: `bash tests/test-phase16-integration.sh`
- **Then**: 3 시나리오 (Knowledge Type closure / Stale 탐지 / Reliability 슬로건) 모두 PASS
- **연관 SPEC**: spec-17-03

### 통합 테스트 실행

```bash
# 본 phase 의 통합 테스트는 phase 시작 시 채움 — fixture 환경 구성 포함
bash tests/test-phase17-integration.sh
```

## 🔗 의존성

- **선행 phase**: phase-16 (Reliability Layer 강화) — 본 phase 가 phase-16 산출물의 *정합성 fix*
- **외부 시스템**: 없음 (로컬 git + bash)
- **연관 ADR**:
  - `docs/decisions/ADR-001-knowledge-types.md` (phase-16 의 closure decision — 본 phase 가 그것의 자기 일관성 강화)
- **연관 RCA**:
  - `docs/rca/RCA-001-sdd-ship-spec-add-missing.md` (spec-17-01 이 prevention 의 직접 구현)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| phase-17 자체가 *self-correction* 이라 코드 변경 회귀 위험 ↑ — 잘못 고치면 sdd CLI 가 더 불안정 | reliability layer 의 self-credibility 추가 손상 | 시나리오 1 (marker 멱등성) 을 fixture 기반 자동 테스트로 박음. spec-17-01 머지 전 fixture 통과 강제. |
| `installed.json` 캐시 분리 시 기존 사용자 환경 (마이그레이션) | 다른 프로젝트의 `installed.json` 이 캐시 필드를 가진 채로 update 받을 때 충돌 | install.sh / update.sh 에 마이그레이션 로직 — 캐시 필드 있으면 cache.json 으로 이전, installed.json 에서 제거. 기존 동작 silent backward compat. |
| `test-phase16-integration.sh` 가 fixture 환경 가정 (예: ADR-999) 충돌 — 다른 테스트와 같은 fixture 이름 사용 시 race | 통합 테스트 flakiness | fixture 이름에 spec-17-03 prefix 사용 + `trap cleanup EXIT` 로 격리 보장. |
| doctor.sh 확장이 기존 사용자 환경에서 false negative 폭증 (`docs/rca/` 가 없으면 무조건 FAIL) | 사용자가 phase-16 산출물을 install 안 받았으면 doctor 가 잘못된 FAIL | 점검 항목을 *optional* 로 — 디렉토리 부재 시 silent skip, 디렉토리 존재 시 템플릿 동일성 검사. spec-16-01 / 02 머지 받은 환경에서만 적극 검증. |

## 🏁 Phase Done 조건

- [ ] spec-17-01 / 02 / 03 모두 merge (phase branch → main)
- [ ] 통합 테스트 시나리오 3 개 PASS
- [ ] 성공 기준 5 개 정량 측정 결과 기록 (본 문서 "검증 결과" 섹션)
- [ ] phase-16 회고 W5 / W10 / C3 / W2 / W6 모두 *closed* 처리 — 본 phase 머지 commit log 에 ref
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
