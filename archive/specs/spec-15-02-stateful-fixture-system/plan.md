# Implementation Plan: spec-15-02

## 📋 Branch Strategy

- 신규 브랜치: `spec-15-02-stateful-fixture-system`
- **시작 지점**: `phase-15-upgrade-safety` (phase base branch — sdd state.baseBranch 인식)
- 첫 task 가 브랜치 생성 수행 (`git checkout phase-15-upgrade-safety && git checkout -b spec-15-02-...`)
- PR target: `phase-15-upgrade-safety`

## 🛑 사용자 검토 필요 (User Review Required)

> [!IMPORTANT]
> - [ ] **lib 위치 합의** — `tests/lib/fixture.sh`. 다른 후보 (`tests/helpers/`, `tests/_fixture.sh`) 도 가능. 본 plan 은 `lib/` 사용.
> - [ ] **mixin 함수 시그니처** — `with_<scenario> <dir> [args...]`. 첫 인자 항상 fixture dir. 가변 인자는 가능 (`with_pre_defined_phases`).
> - [ ] **함수 prefix 정책** — public 은 prefix 없음, internal 은 `_fx_`. 다른 테스트들이 자기 헬퍼 이름과 충돌하지 않도록.

> [!WARNING]
> - [ ] **기존 fixture 패턴 회귀 0** — `make_fixture()` 가 본 lib 의 함수와 동일 이름이지만 *기존 테스트 파일 안의 정의가 우선* (bash 함수 declaration 순서). 신규 lib 를 source 한 테스트만 본 헬퍼 사용.

## 🎯 핵심 전략 (Core Strategy)

### lib 구조

```
tests/lib/fixture.sh          # source 가능. 0 부수효과.
├── make_fixture()             # base — 빈 사용자 환경 (mktemp + install + git init)
├── with_in_flight_phase()     # mixin
├── with_pre_defined_phases()  # mixin
├── with_customized_fragment() # mixin
├── with_dirty_queue_icebox()  # mixin
├── with_user_hook()           # mixin
└── _fx_*()                    # internal
```

### 사용 예 (spec-15-03 에서 어떻게 쓰일지 시연)

```bash
#!/usr/bin/env bash
set -uo pipefail
source "$(dirname "$0")/lib/fixture.sh"

# 시나리오 1 — in-flight phase 보유 사용자 update
F=$(make_fixture)
trap "rm -rf '$F'" EXIT
with_in_flight_phase "$F" "phase-08" "spec-08-03-stock-lock"

before=$(jq -c '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}' \
         "$F/.claude/state/current.json")
bash "$ROOT/update.sh" --yes "$F" >/dev/null 2>&1
after=$(jq -c '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}' \
        "$F/.claude/state/current.json")

[ "$before" = "$after" ] && ok "in-flight 6 fields 보존" || fail "..."
```

### 주요 결정

| 컴포넌트 | 전략 | 이유 |
|:---:|:---|:---|
| **lib 위치** | `tests/lib/fixture.sh` | 다른 헬퍼가 추가될 가능성 — `lib/` 디렉토리가 자연스러움 |
| **make_fixture 의 install** | 본 프로젝트 install.sh 사용 (= base) | 도그푸딩 정합성. install.sh 자체 검증과 별개 |
| **state 주입 방식** | jq 로 직접 편집 | bash 3.2 호환, 간결 |
| **사용자 추가분 식별 마커** | `# TEST_USER_LINE` 등 (각 mixin 마다 고유) | 보존 검증 시 grep 으로 정확 매치 |
| **trap 정리** | 각 테스트에서 책임 (lib 가 강제 안 함) | 단일 lib 가 글로벌 trap 설치하면 다른 테스트와 충돌 |

## 📂 Proposed Changes

### [NEW] `tests/lib/fixture.sh`

```bash
#!/usr/bin/env bash
# tests/lib/fixture.sh
# stateful upgrade fixture 헬퍼 라이브러리 (spec-15-02).
# 사용: source 후 make_fixture / with_* 호출.

# 자기 위치 + 프로젝트 루트
_FX_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_FX_ROOT="$(cd "$_FX_LIB_DIR/../.." && pwd)"

# Base — 빈 사용자 환경
make_fixture() {
  local dir
  dir=$(mktemp -d)
  bash "$_FX_ROOT/install.sh" --yes "$dir" >/dev/null 2>&1
  git -C "$dir" init -q
  git -C "$dir" config user.email t@l
  git -C "$dir" config user.name t
  git -C "$dir" commit --allow-empty -m init -q
  echo "$dir"
}

# in-flight phase/spec 사용자
with_in_flight_phase() {
  local dir="$1"
  local phase="${2:-phase-08}"
  local spec="${3:-spec-08-03-something}"
  # state.json 6 필드 주입
  local _tmp
  _tmp=$(mktemp)
  jq --arg p "$phase" --arg s "$spec" \
     '.phase=$p | .spec=$s | .branch=$s | .baseBranch=null
      | .planAccepted=true | .lastTestPass="2026-04-01T00:00:00Z"' \
     "$dir/.claude/state/current.json" > "$_tmp"
  mv "$_tmp" "$dir/.claude/state/current.json"
  # phase.md 생성
  cat > "$dir/backlog/${phase}.md" <<EOF
# ${phase}: in-flight (test fixture)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->
EOF
  # spec 디렉토리
  mkdir -p "$dir/specs/${spec}"
  cat > "$dir/specs/${spec}/spec.md" <<<"# ${spec}: in flight (test fixture)"
}

# 사전 정의 phase 들
with_pre_defined_phases() {
  local dir="$1"; shift
  local p
  for p in "$@"; do
    cat > "$dir/backlog/${p}.md" <<EOF
# ${p}: 사전 정의 (test fixture)

| 항목 | 값 |
|---|---|
| **Phase ID** | \`${p}\` |
| **상태** | Planning |

본문 — update 후 보존되어야 함.
EOF
  done
}

# 커스터마이즈된 fragment
with_customized_fragment() {
  local dir="$1"
  printf '\n## TEST_USER_FRAGMENT\n사용자 추가분 — 보존되어야 함.\n' \
    >> "$dir/.harness-kit/CLAUDE.fragment.md"
}

# dirty queue (Icebox 메모)
with_dirty_queue_icebox() {
  local dir="$1"
  local q="$dir/backlog/queue.md"
  local _tmp
  _tmp=$(mktemp)
  awk '
    /^## 🧊 Icebox/ {
      print
      print ""
      print "- TEST_USER_ICEBOX_NOTE: 보존되어야 함"
      next
    }
    { print }
  ' "$q" > "$_tmp"
  mv "$_tmp" "$q"
}

# 사용자 추가 hook
with_user_hook() {
  local dir="$1"
  local s="$dir/.claude/settings.json"
  local _tmp
  _tmp=$(mktemp)
  jq '.hooks.UserAddedHook = [{"matcher":"*","hooks":[{"type":"command","command":"echo TEST_USER_HOOK"}]}]' \
     "$s" > "$_tmp"
  mv "$_tmp" "$s"
}
```

### [NEW] `tests/test-fixture-lib.sh`

각 mixin 마다 검증 항목 ≥ 3:

| Mixin | Check 항목 |
|---|---|
| `make_fixture` | 디렉토리 존재 / `.harness-kit/` 존재 / `.claude/state/current.json` 존재 |
| `with_in_flight_phase` | state.phase 일치 / state.spec 일치 / phase.md 존재 / specs/ 디렉토리 존재 |
| `with_pre_defined_phases` | 파일 존재 (다중) / 본문에 식별 마커 / 가변 인자 정상 |
| `with_customized_fragment` | fragment 파일에 마커 존재 / 기존 본문 보존 |
| `with_dirty_queue_icebox` | queue.md 에 마커 존재 / 마커 영역 (sdd:active 등) 손상 없음 |
| `with_user_hook` | settings.json 에 UserAddedHook 키 존재 / 기존 hooks 보존 |
| **조합** | in_flight + dirty_queue + user_hook 동시 적용 시 모두 정상 |

총 ≥ 18 checks.

### [MODIFY 없음]

기존 테스트 파일은 본 spec 에서 손대지 않음.

## 🧪 검증 계획

### 단위 테스트
```bash
bash tests/test-fixture-lib.sh
```

### 회귀
```bash
bash tests/test-version-bump.sh   # 전체 스위트 자동 실행
```

### shellcheck (선택)
```bash
shellcheck tests/lib/fixture.sh tests/test-fixture-lib.sh
```

## 🔁 Rollback Plan

- 본 spec 은 *추가만* — 기존 파일 변경 없음. PR revert 시 lib 만 제거.

## 📦 Deliverables 체크

- [ ] task.md 작성
- [ ] 사용자 Plan Accept
- [ ] `tests/lib/fixture.sh` 구현
- [ ] `tests/test-fixture-lib.sh` 18+ checks PASS
- [ ] 회귀 PASS
- [ ] walkthrough.md / pr_description.md ship + PR
