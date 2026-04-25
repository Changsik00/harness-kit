# phase-14: 정합성 / 멱등성 버그 일괄 수정

> 본 phase 의 모든 SPEC 을 한 파일에 요점/방향성으로 나열합니다.
> *구체적* 작업 내용은 `specs/spec-14-{seq}-{slug}/spec.md` 에서 다룹니다.
>
> 본 문서는 "이번 phase 에서 무엇을 어디까지 할 것인가" 를 한 번에 보기 위한 *업무 지도* 입니다.

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-14` |
| **상태** | Planning |
| **시작일** | 2026-04-25 |
| **목표 종료일** | 2026-05-02 |
| **소유자** | dennis |
| **Base Branch** | 없음 (각 spec 이 main 으로 직접 PR) |

## 🎯 배경 및 목표

### 현재 상황

phase-13 (DX 향상) 도그푸딩 과정에서 다음 세 종류의 정합성/멱등성 버그가 누적 보고됨:

1. **`sdd:queued` marker 미구현 (Bug #01)** — `backlog/queue.md` 의 "📋 대기 Phase" 섹션에 `<!-- sdd:queued:start ~ end -->` 마커가 정의되어 있고 자동 갱신을 안내하지만, `sdd` 바이너리에는 이를 읽거나 쓰는 코드가 0건. 한 번 쓰여진 표는 영구 stale.
2. **`sdd doctor` bash 4.0+ false positive (Bug #02)** — doctor 가 bash 4.0+ 를 required 로 검사하지만, 코드베이스에 bash 4+ 전용 기능은 0건. macOS 기본 bash 3.2 에서 모든 sdd 명령이 정상 동작함에도 onboarding 첫 화면이 ❌ FAIL.
3. **append 시 멱등 체크 누락** — `install.sh:402-445` 에서 `.gitignore` 4줄 블록을 추가할 때 `# harness-kit` 헤더 grep 한 번에만 의존. 또한 `sdd_marker_append()` 자체가 라인 중복 가드 없이 무조건 append → `sdd specx done` 등 4 개 호출 지점이 모두 잠재 중복 위험.

`docs/harness-kit-bug-01-sdd-queued-marker-unimplemented.md`, `docs/harness-kit-bug-02-doctor-bash-version-false-positive.md` 에 상세 분석 존재 (본 phase 작업 시 spec 디렉토리로 흡수 또는 참조).

### 목표 (Goal)

- `queue.md` queued 섹션이 phase 전이마다 자동 갱신되거나, marker 자체가 명확히 제거되어 dead marker 가 사라진다.
- macOS 기본 bash 3.2 환경에서 `sdd doctor` 첫 화면이 PASS 로 나온다 (실제 호환되는 한).
- 동일한 install/append 동작을 N 회 반복해도 결과 파일에 중복 라인이 0건이 되는 *멱등성 보장* 이 코드 차원에서 강제된다.

### 성공 기준 (Success Criteria) — 정량 우선

1. `bash docs/harness-kit-bug-01-...md` 의 재현 시나리오: phase done 후 queued 표가 모순 없이 갱신 (또는 marker 부재로 안내문이 일관) — **PASS**
2. macOS bash 3.2 환경에서 `sdd doctor` 결과 `bash` 항목이 ✅ — 전체 FAIL/WARN 카운트에 본 항목이 잡히지 않음
3. `install.sh` 를 동일 디렉토리에 2 회 연속 실행 후 `.gitignore` 의 `.harness-kit/`, `.harness-backup-*/`, `.claude/state/` 각 라인이 **정확히 1 회씩** 존재 (grep -c 로 검증)
4. `sdd specx done <slug>` 를 같은 slug 로 2 회 실행 후 `queue.md` done 섹션에 해당 라인이 **정확히 1 회** 존재 (다른 3 개 호출 지점에도 동일 회귀 테스트)
5. 모든 spec 의 단위 테스트 PASS, 통합 테스트 시나리오 4 건 모두 PASS

## 🧩 작업 단위 (SPECs)

> 본 표는 phase 의 *작업 지도* 입니다. SPEC 은 *요점 + 방향성 + 참조* 까지만 적습니다.
> 자세한 spec/plan/task 는 `specs/spec-14-{seq}-{slug}/` 에서 작성합니다.
> sdd 가 `<!-- sdd:specs:start --> ~ <!-- sdd:specs:end -->` 사이를 자동 갱신하므로 마커는 그대로 두세요.

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-14-01 | sdd-queued-marker | P1 | Merged | `specs/spec-14-01-sdd-queued-marker/` |
| spec-14-02 | doctor-bash-version | P1 | Merged | `specs/spec-14-02-doctor-bash-version/` |
| spec-14-03 | gitignore-idempotent | P1 | Merged | `specs/spec-14-03-gitignore-idempotent/` |
| spec-14-04 | marker-append-guard | P1 | Merged | `specs/spec-14-04-marker-append-guard/` |
| `spec-14-05` | phase-review-followup | P? | Active | `specs/spec-14-05-phase-review-followup/` |
<!-- sdd:specs:end -->

> 상태 허용값: `Backlog` / `In Progress` / `Merged`
> sdd가 ship 시 자동으로 `Merged`로 갱신합니다. `In Progress`는 active spec에 자동 마킹됩니다.

### spec-14-01 — sdd-queued-marker

- **요점**: `queue.md` 의 `sdd:queued` marker 가 sdd 코드에 의해 갱신되도록 구현하거나, marker 와 안내문을 모두 제거하여 dead marker 를 제거.
- **방향성**: spec.md 작성 시 두 옵션의 trade-off 를 정량적으로 비교하여 결정.
  - **Option A (구현)**: `phase_new()` / `queue_mark_done()` 에서 `queue_sync_queued_table()` 호출 — backlog/ + archive/backlog/ 의 `phase-*.md` 스캔 후 표 재생성.
  - **Option B (제거)**: queue.md 템플릿에서 marker + 자동 갱신 안내 제거 — 표는 사람이 직접 관리.
- **참조**:
  - `docs/harness-kit-bug-01-sdd-queued-marker-unimplemented.md`
  - `sources/bin/sdd` queue_mark_done(), phase_new()
  - `sources/templates/queue.md`
- **연관 모듈**: `sources/bin/sdd`, `sources/bin/lib/common.sh`, `sources/templates/queue.md`, `.harness-kit/agent/templates/queue.md` (도그푸딩 동기화)

### spec-14-02 — doctor-bash-version

- **요점**: `sdd doctor` 의 bash 요구사항을 실제 코드 사용 범위에 맞게 완화 (3.2 허용 또는 optional/warn 으로 다운그레이드).
- **방향성**: `_check_tool "bash" "4.0" "required"` 한 줄 수정. 단, 향후 bash 4+ 도입 정책이 명시되어 있는지 ADR/이슈 확인 후 결정. 회귀 방지를 위해 `tests/` 에 doctor 출력 검증 스모크 테스트 추가.
- **참조**:
  - `docs/harness-kit-bug-02-doctor-bash-version-false-positive.md`
  - `CLAUDE.md` (bash 4.0+ 전용 정책 명시 — 본 spec 에서 정책 자체 재확인 필요)
- **연관 모듈**: `sources/bin/sdd:1427`

> ⚠️ **정책 충돌 주의**: 프로젝트 `CLAUDE.md` 는 "bash 4.0+ 전용" 을 명시. 본 spec 은 이 정책의 실효성을 재평가하는 단계 — 정책 유지 vs 완화를 spec.md 에서 결정.

### spec-14-03 — gitignore-idempotent

- **요점**: `install.sh:402-445` 의 `.gitignore` 4줄 블록 추가 로직을 라인 단위 멱등 처리로 재작성.
- **방향성**: `# harness-kit` 헤더 유무로 분기하지 않고, 4 개 라인 각각에 대해 grep 으로 존재 여부 확인 후 누락된 것만 추가. 사용자가 헤더만 지운 경우 / 라인 일부만 지운 경우 / 처음 설치 모두 동일하게 동작.
- **참조**:
  - `install.sh:402-445`
- **연관 모듈**: `install.sh`

### spec-14-04 — marker-append-guard

- **요점**: `sdd_marker_append()` 에 "동일 라인이 마커 사이에 이미 있으면 append 생략" 가드 추가.
- **방향성**: `common.sh:80` 의 함수 본문에 마커 사이 콘텐츠를 grep 하는 한 단계 추가. 호출자(4 곳)는 변경 불필요. 회귀 테스트는 `sdd specx done` 두 번 호출 시나리오로 검증.
- **참조**:
  - `sources/bin/lib/common.sh:80`
  - `sources/bin/sdd:582,749,1180,1214` (호출 지점)
- **연관 모듈**: `sources/bin/lib/common.sh`

<!-- 추가 SPEC 들... -->

## 🧪 통합 테스트 시나리오 (간결)

> 본 phase 의 Done 조건 중 하나. `tests/` 디렉토리에 phase-14 시나리오 추가 또는 기존 스모크 테스트 확장.

### 시나리오 1: queue.md queued 섹션 정합성 (spec-14-01)
- **Given**: `backlog/phase-N.md` 가 active 상태로 존재
- **When**: `sdd phase done phase-N` 실행
- **Then**: `queue.md` 의 done 섹션 / queued 섹션이 모순 없이 갱신 (Option A: queued 표에서 Done 으로 / Option B: 안내문이 "사람이 관리" 로 일관)
- **연관 SPEC**: spec-14-01

### 시나리오 2: macOS bash 3.2 doctor PASS (spec-14-02)
- **Given**: `/bin/bash` (3.2.x) 환경
- **When**: `bash .harness-kit/bin/sdd doctor` 실행
- **Then**: 출력에 `❌ bash 3.2 (>= 4.0 필요)` 가 **나타나지 않음**, 결과 라인의 FAIL 카운트가 본 항목으로 증가하지 않음
- **연관 SPEC**: spec-14-02

### 시나리오 3: install.sh 재실행 멱등 (spec-14-03)
- **Given**: 이미 install 된 프로젝트의 `.gitignore`
- **When**: `bash install.sh` 동일 옵션으로 2 회 실행
- **Then**: `.harness-kit/`, `.harness-backup-*/`, `.claude/state/` 각 라인이 `grep -c` 로 정확히 1 회 (헤더가 사용자에 의해 지워진 경우 시뮬레이션도 포함)
- **연관 SPEC**: spec-14-03

### 시나리오 4: sdd specx done 멱등 (spec-14-04)
- **Given**: spec-x 가 specx 섹션에 등록된 상태
- **When**: `sdd specx done <slug>` 를 2 회 실행
- **Then**: `queue.md` done 섹션의 해당 라인이 정확히 1 줄 (마찬가지로 `sdd phase new` 후 `sdd phase done` 재호출 시나리오에도 적용)
- **연관 SPEC**: spec-14-04

### 통합 테스트 실행
```bash
# 본 phase 의 통합 테스트만
bash tests/run.sh phase-14
```

## 🔗 의존성

- **선행 phase**: phase-13 (Merged) — sdd doctor / pr-watch / run-test 가 본 phase 의 검증 도구로 사용됨
- **외부 시스템**: 없음 (모두 로컬)
- **연관 ADR**:
  - 없음 (필요 시 spec-14-01 의 Option A/B 결정 시 ADR 신규 작성)

## 📝 위험 요소 및 완화

| 위험 | 영향 | 완화책 |
|---|---|---|
| Option A 선택 시 사용자가 수기로 채운 queued 표가 강제 재생성으로 손실 | Med | spec-14-01 plan 단계에서 migration 경로 (기존 내용 보존 vs 강제 재생성) 명시 결정 + walkthrough 에 변경점 고지 |
| bash 정책 완화 후 향후 진짜 bash 4+ 기능이 필요해지면 다시 강화 필요 | Low | spec-14-02 에서 정책 변경 사유를 ADR 또는 walkthrough 에 명시 — 재강화 시 참고 |
| `sdd_marker_append` 가드 추가가 정상 케이스의 동작을 미세하게 바꿀 수 있음 (예: 의도적 중복) | Low | 4 개 호출 지점 모두 의도가 "유일한 라인 추가" 이므로 회귀 위험 낮음. 단위 테스트로 검증 |
| install.sh 멱등성 수정으로 기존 .gitignore 의 사용자 커스텀 라인 영향 | Low | grep 매치를 정확한 라인 (`^...$`) 으로 한정, 부분 일치 회피 |

## 🏁 Phase Done 조건

- [ ] 모든 SPEC (spec-14-01 ~ 04) 이 main 으로 merge
- [ ] 통합 테스트 시나리오 4 건 모두 PASS
- [ ] 성공 기준 1~5 정량 측정 결과를 본 문서 하단 "검증 결과" 섹션에 기록
- [ ] 사용자 최종 승인 (`/hk-phase-ship` go/no-go)

## 📊 검증 결과 (phase 완료 시 작성)

<!-- 통합 테스트 로그, 성공 기준 측정값, 회귀 점검 결과 등을 여기 첨부 -->
