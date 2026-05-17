# phase-17: 운영 성숙도 (Operational Maturity)

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-{N}-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-17` |
| **상태** | In Progress (1/4 spec Merged) |
| **시작일** | 2026-05-16 |
| **목표 종료일** | 미정 |
| **소유자** | dennis |
| **Base Branch** | `phase-17-coherence-fix` |
| **(이전 제목)** | `정합성 fix (Coherence Fix)` — 2026-05-17 사용자 피드백 으로 확장 재정의 |

## 🎯 배경 및 목표

### 현재 상황

phase-16 (Reliability Layer 강화) 완료 후 두 종류의 미해결 부채가 누적:

**① 내부 신뢰성 (phase-16 회고에서 식별)**
- RCA-001 invariant 위반 (sdd CLI marker 버그 3 종) — *spec-17-01 에서 해소 ✓*
- `installed.json` 캐시 필드가 tracked 파일 안에 있어 워킹트리 항상 dirty (C3)
- Phase-level integration test 자동화 부재 (W2)
- `doctor.sh` 가 신규 산출물 경로 (rca/decisions) 점검 누락 (W6)
- §6.4 closure rule 표현 모호 / stale ADR 회귀 마커 fragile / ADR 가이드 누락 (W1/W3/W4)
- CHANGELOG.md 의 phase 통합 정책 부재 (W7)

**② 외부 접근성 (Icebox 누적)**
- 신규 사용자가 키트를 설치하려면 git clone + `install.sh` — *단일 명령* 없음 (curl 한 줄 인스톨러 부재)
- 키트 사용자가 매번 슬래시 커맨드 10여개를 외워야 함 — *단일 진입점* 부재 (`/hk` 가 state 보고 다음 행동 추천하지 못함)
- README 가 install / 사용 흐름을 *현 상태 정확히* 반영하지 못함 (slogan 만 phase-16 에서 추가됨)

### 본 phase 의 정체성

**phase-17 = 운영 성숙도** — 키트가 *외부 사용자에게 잘 닿고* (도달성) + *내부적으로 자기 정합* (신뢰성). 두 면이 *분리된 phase 가 아니라 한 phase 의 두 묶음*. 이유:

1. **두 면이 자기 강화** — 외부 도달성이 좋아도 내부 신뢰성이 부족하면 사용자 이탈. 내부 신뢰성이 완벽해도 외부 도달성이 없으면 채택 0.
2. **phase 단위 피로감 회피** — 작은 정리 phase 를 여러 개 만드는 것보다 *thematic chunk* 한 개가 인지/관리 비용 ↓ (사용자 피드백, 2026-05-17).
3. **회고 / phase-ship 절차의 정량 가치** — phase 1 회당 회고 1 회 + phase-ship 1 회. 작은 phase 들로 쪼개면 ceremony 가 가치 대비 크다.

### 목표 (Goal)

본 phase 가 끝났을 때:

1. **내부 신뢰성 부채 종식** — sdd CLI marker 멱등성 (✓ 17-01), 워킹트리 cleanliness, phase-level 자동 검증, doctor 새 경로 인지, governance/test 잡탕 정리.
2. **외부 접근성 확립** — 신규 사용자가 *단일 명령* 으로 install 가능. 키트 사용자가 *단일 진입점* (`/hk`) 으로 다음 행동 안내 받음.
3. **운영 자동화 진입점 완성** — 후속 phase 가 *같은 패턴* 으로 phase integration test / install 흐름 / 진입점 확장 가능.

### 성공 기준 (Success Criteria) — 정량 우선

1. **Marker 멱등성** (✓ spec-17-01 완료) — `tests/test-sdd-marker-idempotent.sh` 3/3 PASS.
2. **워킹트리 cleanliness** — SessionStart hook (`check-kit-version.sh`) 실행 후 `git status --porcelain` 빈 출력.
3. **Phase-16 integration self-test** — `tests/test-phase16-integration.sh` 한 명령으로 시나리오 1/2/3 모두 PASS.
4. **`doctor.sh` 확장** — `docs/rca/`, `docs/decisions/`, `rca.md`, `adr.md` 4 항목 점검 — fixture 누락 시 FAIL.
5. **단일 명령 install** — `curl -sSL <url> | bash` 한 줄로 새 프로젝트에 키트 설치 가능 (fixture 환경 검증).
6. **`/hk` 단일 진입점** — `/hk` 호출 시 sdd status 기반으로 *현 상태에 맞는 다음 행동* (예: "Plan Accept 필요", "Ship 가능", "phase done 권장") 1 줄 안내.
7. **Governance/test 잡탕 정리** — §6.4 표현 명확화 + stale ADR 회귀 마커 self-contained + ADR 가이드 1 줄 + CHANGELOG 정책.

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신합니다.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-17-01` | sdd-marker-bugs-fix | P0 | Merged | `specs/spec-17-01-sdd-marker-bugs-fix/` |
| `spec-17-02` | accessibility-install-and-entry | P0 | Merged | `specs/spec-17-02-accessibility-install-and-entry/` |
| `spec-17-03` | internal-reliability-infra | P? | Merged | `specs/spec-17-03-internal-reliability-infra/` |
| `spec-17-04` | governance-test-coherence | P2 | Active | `specs/spec-17-04-governance-test-coherence/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-17-01 — sdd CLI marker 버그 3 종 fix (✓ Merged)

- **요점**: `sdd ship` / `sdd spec new` / `sdd phase done` 의 marker 처리 멱등성 확보.
- **상태**: 머지됨 (commit `5aebd0d`, PR #122). RCA-001 prevention 직접 구현.
- **연관 모듈**: `sources/bin/sdd`, `tests/test-sdd-marker-idempotent.sh`

### spec-17-02 — Accessibility: install + entry point + onboarding (📦 묶음, P0)

- **요점**: 외부 사용자가 키트에 *낮은 마찰* 로 닿도록 — 단일 명령 install (검증) + 단일 진입점 + README onboarding.
  - **curl 인스톨러 검증**: `get.sh` 이미 존재 + README 에 명시 — 동작 검증만, 수정 거의 없음 가능성 큼.
  - **`/hk` 단일 진입점 (메인 작업)**: `.claude/commands/hk.md` 신규. `sdd status --json` 기반으로 *현 상태에 맞는 다음 행동 1 줄* 추천 + 관련 슬래시 커맨드 안내. 슬래시 커맨드 10여개를 외울 필요 ↓.
  - **README onboarding 갱신**: Step 1 에 `/hk` 도 안내 (`/hk-align` 또는 `/hk`). 기존 한국어 본문 구조 유지, minor 3-5 줄.
- **방향성**: *외부 사용자 경험* 우선. 사용자가 키트 채택 후 *어떤 슬래시 커맨드를 외워야 하나* 의 부담 ↓. 한 spec 으로 묶어야 onboarding 흐름이 일관됨 — 분리 시 부분만 노출 위험.
- **참조**: Icebox "접근성 개선 Phase 후보" (phase-16 회고 시점 사용자 의도)
- **연관 모듈**: `sources/commands/hk.md` (신규), `.claude/commands/hk.md` (신규), `README.md`, `get.sh` (검증만)

### spec-17-03 — Internal reliability infrastructure (📦 묶음)

- **요점**: phase-16 회고에서 식별된 *내부 운영 인프라 부채* 4 건 한 spec 으로 묶음 처리.
  - **C3 cache 분리**: `installed.json` 의 `lastVersionCheck` / `latestKnownVersion` 두 필드를 `.harness-kit/cache.json` 으로 이관 + `.gitignore`. install.sh 마이그레이션 로직.
  - **W2 phase integration test**: `tests/test-phase16-integration.sh` 작성 (시나리오 1/2/3 한 스크립트). `phase-NN-integration.sh` 명명 규약 신설.
  - **W6 doctor 확장**: `doctor.sh` 의 checklist 에 `docs/rca/`, `docs/decisions/`, `rca.md`, `adr.md` 4 항목 추가 (optional — 디렉토리 부재 시 silent skip).
  - **선택**: `sdd_marker_grep` helper 일반화 — spec-17-01 의 호출 측 분기 우회를 일반화 (선택, 시간 남으면).
- **방향성**: 각 fix 가 작아도 *내부 도그푸딩 인프라* 라는 동일 테마. 4-6 commit 예상.
- **참조**: phase-16 회고 W2/W6/C3, spec-17-01 walkthrough 의 marker helper 일반화 후보
- **연관 모듈**: `sources/hooks/check-kit-version.sh`, `sources/bin/sdd`, `install.sh`, `.gitignore`, `doctor.sh`, `tests/test-phase16-integration.sh` (신규)

### spec-17-04 — Governance + test coherence (📦 잡탕 cleanup, P2)

- **요점**: phase-16 회고의 작은 governance/test 잔재 4 건을 한 spec 으로 묶음 정리.
  - **W1 §6.4 표현 명확화**: "Used in" 열 (RCA 전용 어휘) vs Rules ("ADR adopt closure") 표현 충돌 → 명확화. 인간 작성자 혼선 해소.
  - **W3 stale ADR 회귀 마커 self-contained**: `tests/test-drift-stale-adr.sh` 의 ADR-001 본문 종속을 별도 fixture (ADR-998-valid-paths 같은) 로 분리.
  - **W4 ADR 가이드**: `_drift_stale_adr` 의 "stale 검사 대상 경로 형식 = inline backtick + 슬래시 + 확장자" 안내를 ADR 템플릿 또는 agent.md 에 1 줄.
  - **W7 CHANGELOG 정책**: "phase ship 시 CHANGELOG draft entry 추가" 룰을 CLAUDE.md "릴리스 전략" 섹션에 추가. 다음 release 시 catch-up 부담 ↓.
- **방향성**: 본 spec 의 각 항목이 *단발 fix* 라 spec-x 분리하면 5 PR 누적 — 한 spec 묶음으로 review 1 회. 3-5 commit 예상.
- **참조**: phase-16 회고 W1/W3/W4/W7
- **연관 모듈**: `sources/governance/constitution.md`, `tests/test-drift-stale-adr.sh`, `sources/templates/adr.md`, `sources/governance/agent.md`, `CLAUDE.md`

## 📌 결정 기록 (Review)

> Phase PR review 중 발생한 결정·합의·발견을 누적합니다.

| 이슈 | 선택지 | 결정 | 이유 |
|---|---|---|---|
| Phase base branch 사용 시점 | 처음부터 / mid-phase 도입 / 미사용 | **처음부터** (`phase-17-coherence-fix`) | phase-16 의 mid-phase 전환 cost 학습 |
| 당초 sdd marker 버그 3 종 묶음 | 묶음 / 개별 | **묶음 (spec-17-01)** | 동일 marker 처리 패턴, helper 공유 |
| 당초 Out of Scope (W1/W3/W4/W7/W9 + 접근성) | 포함 / Icebox 잔류 | **(취소) Icebox 잔류** | 사용자 피드백으로 *재정의* (아래) |
| **(재정의 2026-05-17) Phase scope 확장** | 좁게 (3 정합성 spec) / 넓게 (4 spec: 정합성 + 접근성 + governance 잡탕) | **넓게** (운영 성숙도) | 사용자 피드백: "phase-17, phase-18 이런게 너무 자잘한 내용을 처리해서 처리 단위에 대한 피로감만 커". 작은 phase 여럿보다 *thematic chunk* 한 개가 인지/관리 비용 ↓. 외부 도달성 + 내부 신뢰성을 한 phase 로 묶어 자기 강화 |
| **(재정의 2026-05-17) 접근성 개선** | 별 phase-18 / phase-17 통합 | **phase-17 통합** (spec-17-03) | 외부 가치 + 내부 신뢰성이 같은 phase 에서 ship 되면 키트 채택률 ↑ 효과 1 회 ship 으로 |
| **(재정의 2026-05-17) governance/test 잡탕** | 5 spec-x 분리 / 1 spec 묶음 | **1 spec 묶음** (spec-17-04) | 단발 fix 5 개 = 5 PR ceremony. 묶으면 review 1 회 |

## 🧪 통합 테스트 시나리오

> 본 phase 의 Done 조건 중 하나. 자세한 구현은 각 spec 의 task.md / `tests/`.

### 시나리오 1: Marker 멱등성 (✓ spec-17-01 완료)

- **Given**: fixture phase-99 + spec-99-01 (Backlog)
- **When**: `sdd spec new marker-test` / `sdd phase done 99`
- **Then**: phase-99.md 행 수 1, queue.md done entry `**phase-99** — 제목 — completed YYYY-MM-DD`
- **연관 SPEC**: spec-17-01 ✓

### 시나리오 2: 워킹트리 cleanliness + integration self-test

- **Given**: spec-17-02 머지 후
- **When**: SessionStart hook 실행 → `git status --porcelain` / `bash tests/test-phase16-integration.sh`
- **Then**: 워킹트리 변경 0 / 시나리오 1/2/3 모두 PASS
- **연관 SPEC**: spec-17-02

### 시나리오 3: 단일 명령 install + 진입점

- **Given**: 깨끗한 임시 디렉토리 + git init
- **When**: `curl -sSL <url> | bash` / `/hk` 호출 (또는 dry-run 시뮬레이션)
- **Then**: 키트 설치 완료 (`.harness-kit/` 존재) / `/hk` 가 현 상태에 맞는 1 줄 안내 출력
- **연관 SPEC**: spec-17-03

### 시나리오 4: Governance/test coherence

- **Given**: spec-17-04 머지 후
- **When**: `grep -E "Used in.*RCA" constitution.md` / `tests/test-drift-stale-adr.sh` / `grep "backtick + 슬래시" agent.md`
- **Then**: §6.4 표현 명확 / 회귀 마커가 self-contained / ADR 가이드 hit
- **연관 SPEC**: spec-17-04

## 🔗 의존성

- **선행 phase**: phase-16 (Reliability Layer 강화) — 본 phase 가 phase-16 산출물의 *운영 성숙도 강화*
- **외부 시스템**: 없음 (로컬 git + bash + curl)
- **연관 ADR**: ADR-001-knowledge-types
- **연관 RCA**: RCA-001-sdd-ship-spec-add-missing (spec-17-01 이 prevention 의 직접 구현 ✓)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| spec 묶음이 너무 커서 review 부담 ↑ | spec-17-02/03/04 가 각 multi-feature — PR 분량 큼 | walkthrough 결정 기록 표를 *commit 단위* 로 자세히 — review 가 commit-by-commit 가능. PR 본문에 *기능별 hash* 명시 |
| curl 인스톨러의 보안 우려 (외부 URL pipe to bash) | 사용자가 install 거부하거나 보안 사고 | README 에 URL 정확성 + verify 옵션 (sha256, `curl ... -o install.sh && cat && bash`) 명시 |
| `/hk` 진입점이 너무 많은 케이스 추천하려다 잘못된 행동 안내 | 사용자 혼란 | 첫 버전은 *4-5 핵심 상태* 만 (no phase / active spec planning / Plan Accept 가능 / Ship 가능 / phase ship 가능). 나머지는 폴백 |
| spec-17-04 의 묶음이 잡탕화 — 응집성 ↓ | 무엇이 어디 들어가는지 헷갈림 | walkthrough 에 항목별 분리 commit + 매핑 표 |

## 🏁 Phase Done 조건

- [ ] spec-17-01 ✓ / 02 / 03 / 04 모두 merge (phase branch → main)
- [ ] 통합 테스트 시나리오 4 개 PASS
- [ ] 성공 기준 7 개 정량 측정 결과 기록 (본 문서 "검증 결과" 섹션)
- [ ] phase-16 회고 W5/W10/C3/W2/W6/W1/W3/W4/W7 + 접근성 개선 Icebox 항목 모두 *closed* 처리
- [ ] 사용자 최종 승인

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
