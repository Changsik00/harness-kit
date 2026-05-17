# Implementation Plan: spec-x-sdd-state-guard

## 📋 Branch Strategy

- 신규 브랜치: `spec-x-sdd-state-guard`
- 시작 지점: `main` (현재 HEAD `b824a8a`)
- 첫 task 가 브랜치 생성을 수행함

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **가드 적용 범위**: `phase_activate` / `phase_new` / `spec_new` 세 진입점 — 이 외 진입점 (예: `specx_new`) 은 본 spec 에서 제외 (`specx_new` 는 *새로 spec 을 만드는 명령* 이라 충돌 시점이 다르며, 별도 검토)
> - [ ] **`--force` 의미**: 활성 spec 가드 우회 = state 의 `spec` / `planAccepted` 를 silent 덮어쓴다는 뜻. 사용자는 *진행 중인 다른 작업을 잃을 수 있음*을 명시적으로 인지하고 호출해야 함
> - [ ] **`phase_new --force` 의미 확장**: 기존엔 "사전 정의 phase 우회"만 의미했음. 본 spec 후엔 "사전 정의 phase + 활성 spec 모두 우회" 로 확장. 기존 사용자 없음 (도그푸딩 단계) 이라 호환성 이슈 없음

> [!WARNING]
> - [ ] **`sources/bin/` 과 `.harness-kit/bin/` 양쪽 동시 변경 필요** — 도그푸딩 패턴 (이전 release 흐름과 동일)
> - [ ] **회귀 위험**: 기존 `test-sdd-phase-activate.sh` 의 fixture 는 활성 spec 없는 상태에서 시작 → 가드 미발동. 회귀 없음을 명시적으로 검증

## 🎯 핵심 전략 (Core Strategy)

### 아키텍처 컨텍스트

```
호출 시점 state                guard            결과
─────────────────────────  ────────────  ──────────────
spec=null                  통과            기존 동작 유지
spec=spec-x-foo            die            "sdd specx done foo" 안내
spec=spec-01-02-bar        die            "sdd ship" 안내
spec=spec-x-foo + --force  통과            silent 덮어쓰기 (사용자 의도)
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **helper 위치** | `state.sh` 에 `die_if_active_spec` | state 검사 책임을 state.sh 에 응집. 호출자는 한 줄로 invoke |
| **메시지 분기** | `case "$active" in spec-x-*) ... ;; *) ... esac` | spec-x 와 SDD-P spec 에 다른 해결 명령 제시 (specx done vs ship) |
| **--force 처리** | 호출자가 사전 파싱 후 가드 호출 자체를 skip | helper 가 옵션 파싱 로직을 알 필요 없음. 호출자별로 자유롭게 |
| **테스트 위치** | `tests/test-sdd-state-guard.sh` 신설 | 기존 `test-sdd-phase-activate.sh` 와 분리 — 책임 명확화 |

### 📑 ADR 후보

- [ ] 본 spec 내부 결정 (helper 위치, 메시지 분기 방식 등) 은 routine — ADR 가치 없음.
- [x] **별도 ADR 후보**: `state-namespace-split` (type: decision) — state 공간 분할은 본 spec 의 *근본 해결* 이지만 별도 작업. 본 spec 머지 후 walkthrough 에서 carry-over 로 명시.

## 📂 Proposed Changes

### Helper 신설

#### [MODIFY] `sources/bin/lib/state.sh` + `.harness-kit/bin/lib/state.sh`

`state_get` / `state_set` 다음에 `die_if_active_spec` 추가.

```bash
# 활성 spec 존재 시 die. --force 처리는 호출자가 사전 수행 (가드 호출 자체를 skip).
# action: 호출 명령 이름 (예: "phase activate", "phase new", "spec new")
die_if_active_spec() {
  local action="$1"
  local active
  active="$(state_get spec)"
  if [ -n "$active" ] && [ "$active" != "null" ]; then
    err "활성 spec 존재: $active"
    err ""
    err "${action} 은 활성 spec 컨텍스트를 silent reset 합니다."
    err ""
    err "해결:"
    case "$active" in
      spec-x-*)
        err "  1) spec-x 완료:    sdd specx done ${active#spec-x-}"
        ;;
      *)
        err "  1) SDD-P spec 완료: sdd ship (또는 PR merge 대기)"
        ;;
    esac
    err "  2) 의도적 강제:    --force 플래그 추가"
    exit 1
  fi
}
```

### 진입점 가드 적용

#### [MODIFY] `phase_activate` (sources/bin/sdd + .harness-kit/bin/sdd)

`phase_activate` 함수 진입부에 `--force` 파싱 + 가드 호출 추가.

```bash
phase_activate() {
  local id="${1:-}"
  [ -z "$id" ] && die "사용법: sdd phase activate <phase-NN> [--base] [--force]"

  # --force 사전 파싱 (기존 --base 파싱은 그대로 유지)
  local force_mode=0
  local arg
  for arg in "${@:2}"; do
    case "$arg" in --force) force_mode=1 ;; esac
  done

  [ $force_mode -eq 0 ] && die_if_active_spec "phase activate"

  # ... 이하 기존 로직
}
```

#### [MODIFY] `phase_new` (sources/bin/sdd + .harness-kit/bin/sdd)

기존 `force_mode` 변수가 활성 spec 가드도 함께 우회하도록 확장.

```bash
phase_new() {
  # ... (slug 검증, --base / --force 플래그 파싱은 기존 그대로)

  [ $force_mode -eq 0 ] && die_if_active_spec "phase new"

  # 사전 정의 phase 가드 (기존 로직)
  if [ $force_mode -eq 0 ]; then
    # ...
  fi

  # ... 이하 기존 로직
}
```

#### [MODIFY] `spec_new` (sources/bin/sdd + .harness-kit/bin/sdd)

`spec_new` 함수 진입부에 `--force` 파싱 + 가드 호출 추가.

```bash
spec_new() {
  local slug="${1:-}"
  [ -z "$slug" ] && die "사용법: sdd spec new <slug> [--force]"
  sdd_slug_ok "$slug" || die "slug 형식 오류: 소문자/숫자/하이픈"

  # --force 사전 파싱
  local force_mode=0
  local arg
  for arg in "${@:2}"; do
    case "$arg" in --force) force_mode=1 ;; esac
  done

  [ $force_mode -eq 0 ] && die_if_active_spec "spec new"

  _pre_spec_validation "$slug"

  # ... 이하 기존 로직
}
```

### help 문구 갱신

#### [MODIFY] `sources/bin/sdd` cmd_help (+ .harness-kit/bin/sdd)

- `phase new` 와 `phase activate` 에 `[--force]` 표기
- `spec new` 에 `[--force]` 표기
- 한 줄 설명에 "활성 spec 존재 시 die — `--force` 로 우회" 추가

### 테스트 신설

#### [NEW] `tests/test-sdd-state-guard.sh`

기존 `test-sdd-phase-activate.sh` 의 fixture 헬퍼 패턴을 차용.

Check 항목:
1. **활성 spec-x 상태에서 `phase activate` → die + state 보존**
2. **활성 spec-x 상태에서 `phase activate --force` → 통과 + state 덮어쓰기**
3. **활성 spec-x 상태에서 `phase new` → die + state 보존**
4. **활성 spec-x 상태에서 `phase new <slug> --force` → 통과 + state 덮어쓰기**
5. **활성 SDD-P spec 상태에서 `spec new` → die + 안내 메시지에 `sdd ship` 포함**
6. **활성 SDD-P spec 상태에서 `spec new <slug> --force` → 통과**
7. **활성 spec 없는 상태에서 모든 명령 → 기존 동작 (회귀 가드)**

## 🧪 검증 계획 (Verification Plan)

### 단위 테스트 (필수)

```bash
bash tests/test-sdd-state-guard.sh        # 신설 — 7 check
bash tests/test-sdd-phase-activate.sh     # 회귀 — 9 check 모두 PASS
bash tests/test-sdd-spec-new-seq.sh       # 회귀 — spec_new 변경 영향
```

### 수동 검증 시나리오

1. 본 spec-x 자체가 도그푸딩 사례 — `sdd specx new sdd-state-guard` 실행 직후 (`spec=spec-x-sdd-state-guard`) `sdd phase activate phase-01` 시도 → die 메시지 + `sdd specx done sdd-state-guard` 안내 노출 기대.
2. `sdd phase activate phase-01 --force` 호출 → 통과 + `spec=null` 로 덮어써짐 (의도된 동작).

## 🔁 Rollback Plan

- 가드 자체는 *추가 검사* 이므로 회귀 위험 낮음.
- 문제 발생 시 `die_if_active_spec` 호출 라인 3 줄 제거 + helper 본문 제거 = revert 가능.
- state.json 형식 변경 없음 → 데이터 손실 없음.

## 📦 Deliverables 체크

- [ ] task.md 작성 (다음 단계)
- [ ] 사용자 Plan Accept 받음
- [ ] (실행 후) 모든 task 완료
- [ ] (실행 후) walkthrough.md / pr_description.md ship
