# phase-15: upgrade-safety — 기존 사용자 update 경로 안전성

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-15-{seq}-{slug}/spec.md` 에서 다룹니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-15` |
| **상태** | Planning |
| **시작일** | 2026-04-28 |
| **목표 종료일** | 미정 (research 결과로 확정) |
| **소유자** | dennis |
| **Base Branch** | `phase-15-upgrade-safety` (opt-in, 회고/통합 테스트 위해) |

## 🎯 배경 및 목표

### 현재 상황

최근 한 달간 머지된 spec-x 들 중 **다수가 "update 후 기존 사용자 환경에서 무언가 깨짐"** 패턴이었다:

| Spec / PR | 증상 | 분류 |
|---|---|---|
| `spec-x-update-preserve-state` (#82) | `branch`, `baseBranch` 가 update 후 영구 소실 | 부분 백업 로직 누락 |
| `spec-x-install-phase-ship-template` (#83) | install 시 `phase-ship.md` 템플릿 미복사 | 신규 산출물의 install 경로 누락 |
| `spec-x-sdd-phase-activate` (#84) | 사전 정의 phase 가 인식되지 않음 | 도구가 사용자 작성물을 무시 |
| (이전) gitignore 중복 | update 후 `.gitignore` 항목 중복 누적 | 멱등성 위반 |

**공통 분모**: 기존 사용자 = state.json 채워져 있고 / phase·spec 진행 중이고 / queue.md 손댄 상태 = 라는 환경 위에 update.sh 가 새 키트를 덮어쓸 때 사일런트로 깨짐. 현재 테스트 스위트는 **빈 fixture 에서 시작**하므로 이 시나리오를 거의 다루지 않음.

본 프로젝트가 *다른 프로젝트에 설치되는 메타 도구* 라는 특성상, **upgrade 경로의 안전성** 은 거의 모든 사용자 시나리오의 진입점이다. 같은 자리에서 같은 패턴 버그가 반복되는 것은 테스트 인프라가 대응을 못 하기 때문이라는 진단.

### 목표 (Goal)

**stateful upgrade** 시나리오를 테스트 인프라 자체로 잡아낸다. 즉:
1. "사용 중인 사용자 환경" 을 모사하는 fixture 시스템이 있고,
2. install/update 코드가 그 위에서 멱등 + 상태 보존 + 사용자 작성물 보존을 보장하며,
3. 과거 버그들이 모두 stateful 회귀 테스트로 잠겨 있다.

### 성공 기준 (Success Criteria) — 정량 우선

1. **Stateful upgrade fixture 시스템** — `tests/fixtures/stateful/` (또는 동등 위치) 에 ≥ 5개 시나리오 (in-flight phase / partial spec / dirty queue / pre-defined phase / customized claude-fragment 등) 매트릭스 구축
2. **회귀 테스트 커버리지** — 위 4개 기존 버그(state 손실 / gitignore dup / 템플릿 누락 / phase activate)가 stateful 형태로 회귀 테스트 보유 및 PASS
3. **install/update 정책 명문화** — 어떤 파일이 덮어쓰기 / 머지 / 사용자 영역인지 표 형식으로 문서화 (예: `docs/design/upgrade-policy.md`)
4. **Audit 기반 추가 픽스** — research 결과로 발견된 잠재 버그 모두 spec 으로 등록 + 우선순위 부여 (실제 픽스는 본 phase 또는 후속 phase 로 분배 가능)

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-15-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-15-01` | upgrade-danger-audit | P? | Merged | `specs/spec-15-01-upgrade-danger-audit/` |
| `spec-15-02` | stateful-fixture-system | P? | Merged | `specs/spec-15-02-stateful-fixture-system/` |
| `spec-15-03` | uninstall-cmd-list-stale | P? | Merged | `specs/spec-15-03-uninstall-cmd-list-stale/` |
| `spec-15-04` | historical-regression-tests | P? | Merged | `specs/spec-15-04-historical-regression-tests/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`

### spec-15-01 — upgrade-danger-audit (Research)

- **요점**: 최근 update 관련 버그 카탈로그 + 공통 패턴 + fixture 설계안 + install/update 정책 정리. 후속 spec 명세 도출.
- **방향성**: 코드 수정 0. 산출물은 `report.md` (constitution §9 Research Spec 형식). Trade-off Analysis ≥ 2 안, Go/No-Go 권고 포함.
- **참조**:
  - `install.sh`, `update.sh`, `sources/claude-fragments/`
  - 최근 4개 버그 spec 디렉토리 (#82, #83, #84, gitignore dup)
- **연관 모듈**: `install.sh`, `update.sh`, `sources/`

### spec-15-02 — stateful-fixture-system (Implementation)

- **요점**: stateful upgrade fixture 헬퍼 + 시나리오 매트릭스 구현.
- **방향성**: 기존 `make_fixture()` 패턴(`tests/test-sdd-base-branch.sh`) 을 stateful 버전으로 확장. "사용 중인 사용자" 의 다양한 상태를 함수 인자로 합성 가능하게.
- **참조**: spec-15-01 의 fixture 설계안
- **연관 모듈**: `tests/`

### spec-15-03 — uninstall-cmd-list-stale (P0, audit 발견)

- **요점**: `uninstall.sh:92` 의 KIT_COMMANDS 가 구 슬래시 커맨드 명단 (`align`, `spec-new` 등) — 현재 `hk-*` prefix 와 불일치. 슬래시 커맨드 이름 변경/제거 시 사용자 환경에 stale 잔재.
- **방향성**: `installed.json` 에 install 시점의 `hk-*` 명단 기록 → uninstall 이 그 목록 사용 (대칭화). 또는 `.claude/commands/hk-*.md` 일괄 제거.
- **참조**: spec-15-01 §5.3.1
- **연관 모듈**: `uninstall.sh`, `install.sh`

### spec-15-04 — historical-regression-tests (Tests)

- **요점**: 과거 4개 버그를 stateful 회귀 테스트로 잠금. 향후 동일 패턴 회귀 즉시 감지.
- **방향성**: spec-15-02 의 헬퍼를 사용. 각 버그마다 "버그가 발생하던 환경 복원 → update 실행 → 사후 상태 검증" 플로우.
- **연관 모듈**: `tests/test-update-stateful.sh` (신규 또는 분할)

### spec-15-05 — dedupe-hardcoded-lists (P1, audit 발견)

- **요점**: `install.sh:257-264` (governance 3 + templates 8 하드코딩) + `update.sh:120` (state 6 필드 하드코딩) 을 단일 진실 원천으로 통합.
- **방향성**: `sources/install.manifest` 또는 헬퍼 함수로 통합 + 회귀 테스트.
- **참조**: spec-15-01 §5.4 P1 항목
- **연관 모듈**: `install.sh`, `update.sh`, `sources/`

### spec-15-06 — user-hook-preserve (P1, audit 발견, 우선순위 검토 필요)

- **요점**: `install.sh:347-348` 의 `hooks = kit-overwrite` 정책 → 사용자 추가 hook 영구 손실 (Pattern B).
- **방향성**: 사용자 hook 영역 분리 또는 marker 기반 머지. UX 영향 확인 후 결정.
- **참조**: spec-15-01 §5.4
- **연관 모듈**: `install.sh`, settings.json 머지

### spec-15-07 — harness-config-overwrite (P2, 후속 phase 후보)

- **요점**: `install.sh:461-474` harness.config.json 항상 OVERWRITE.
- **방향성**: 영향 적음 (키트 영역). 사용자 수정분이 있는 경우 jq merge 검토. **본 phase 또는 Icebox.**
- **참조**: spec-15-01 §5.4

> P2 추가 후보 (Icebox / 후속 phase): `inplace-upgrade-rewrite` (update.sh 모델 리팩토링), `report-md-spec-md-cleanup` (거버넌스 흠집).

## 🧪 통합 테스트 시나리오 (간결)

### 시나리오 1: in-flight phase 보유 사용자가 update 실행

- **Given**: 사용자 환경 = `state.json` 에 `phase=phase-08`, `spec=spec-08-03-...`, `branch="..."`, `baseBranch="..."`, `planAccepted=true`, `lastTestPass=<timestamp>` 가 채워져 있음. `backlog/phase-08.md`, 진행 중인 `specs/spec-08-03-.../task.md` 존재.
- **When**: `bash update.sh` 실행 (현재 버전에서 다음 minor 로 업그레이드)
- **Then**:
  - state.json 의 6개 필드(phase, spec, branch, baseBranch, planAccepted, lastTestPass) 모두 보존
  - `kitVersion` 만 새 값
  - `backlog/phase-08.md` 본문 손상 없음
  - `specs/spec-08-03-.../` 디렉토리 손상 없음
- **연관 SPEC**: spec-15-02, spec-15-03

### 시나리오 2: 사전 정의 phase 보유 사용자가 update 실행

- **Given**: `backlog/phase-09.md ~ phase-13.md` 가 활성화 안 된 채 사용자가 직접 작성해 둔 상태
- **When**: `bash update.sh`
- **Then**: 모든 사전 정의 phase 파일 본문 무수정. `sdd phase activate phase-09` 가 update 후에도 정상 동작.
- **연관 SPEC**: spec-15-02, spec-15-03

### 시나리오 3: 커스터마이즈된 claude-fragment 보유 사용자가 update 실행

- **Given**: `.harness-kit/CLAUDE.fragment.md` 또는 `CLAUDE.md` 의 HARNESS-KIT 블록이 사용자에 의해 일부 수정됨
- **When**: `bash update.sh`
- **Then**: 사용자 추가분 보존 또는 명시적 conflict 표시. 사일런트 덮어쓰기 금지. 멱등성 (재실행 시 중복 추가 없음).
- **연관 SPEC**: spec-15-02, spec-15-03

### 시나리오 4: queue.md 가 dirty 한 사용자가 update 실행

- **Given**: `queue.md` 의 active/specx/done 마커 영역에 진행 중 항목 존재 + Icebox/대기 Phase 섹션에 사용자 메모 존재
- **When**: `bash update.sh`
- **Then**: 마커 외부 사용자 영역(Icebox / 대기 Phase) 보존. 마커 내부 항목 손상 없음.
- **연관 SPEC**: spec-15-02, spec-15-03

### 시나리오 5: 신규 산출물(템플릿/훅) 도입된 버전으로 update

- **Given**: 새 버전이 `phase-ship.md` 같은 신규 템플릿을 추가
- **When**: `bash update.sh`
- **Then**: 신규 산출물 install 누락 없음. 기존 산출물 위에 덮어쓰지 않음 (사용자 수정분 보존).
- **연관 SPEC**: spec-15-02, spec-15-03

### 통합 테스트 실행

```bash
bash tests/test-update-stateful.sh   # spec-15-03 결과
```

## 🔗 의존성

- **선행 phase**: 없음
- **외부 시스템**: bash 3.2+, jq, git
- **연관 ADR**: 없음 (필요 시 spec-15-01 audit 에서 발의)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| Audit 결과 spec 수가 폭증 | phase 가 무한 확장 | spec-15-01 결과 P0(15-04) 1건 / P1(15-05, 15-06) 2건 / P2(15-07+) 분류 완료. 본 phase 는 P0+P1 흡수, P2 는 후속 phase / Icebox |
| stateful fixture 가 실제 사용자 환경과 어긋남 | 회귀 테스트 통과해도 실환경 버그 | 통합 시나리오 1 (in-flight phase) 에 알려진 사용자 환경 6 필드를 1:1 반영 (`tests/test-update.sh:42-52` 패턴) |
| 본 phase 작업 중 또 다른 update 버그 발견 | 메타 작업 중 사용자 영향 | 발견 즉시 별도 spec-x 또는 본 phase 의 spec-15-04+ 로 흡수 |
| **uninstall.sh:92 KIT_COMMANDS stale** (P0, spec-15-01 §5.3.1) | 슬래시 커맨드 이름 변경/제거 시 사용자 환경에 stale 잔재 | spec-15-03 으로 즉시 픽스 — installed.json 에 명단 기록 → uninstall 이 그 목록 사용 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC 이 `phase-15-upgrade-safety` 로 merge
- [ ] 5개 통합 테스트 시나리오 PASS (`/hk-phase-ship` 시 실행)
- [ ] **Phase 회고** (`/hk-phase-review` — 독립 Opus sub-agent 검증)
- [ ] 성공 기준 4개 정량 측정 결과 본 문서 §검증 결과 에 기록
- [ ] 사용자 최종 승인 (phase PR `phase-15-upgrade-safety` → `main`)

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
