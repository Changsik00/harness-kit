#!/usr/bin/env bash
# tests/lib/fixture.sh
# spec-15-02: stateful upgrade fixture 헬퍼 라이브러리.
#
# 사용:
#   source "$(dirname "$0")/lib/fixture.sh"
#   F=$(make_fixture)
#   with_in_flight_phase "$F" "phase-08" "spec-08-03-stock-lock"
#   ...
#
# 정책:
#   - source 만으로는 0 부수효과 (어떤 디렉토리도 생성 안 됨).
#   - 각 테스트가 trap 으로 정리 책임. lib 가 글로벌 trap 설치 안 함.
#   - public 함수는 prefix 없음 (가독성). internal 은 _fx_ prefix.
#   - bash 3.2+ 호환 (declare -A / mapfile / ** 미사용).

# 자기 위치 + 프로젝트 루트
_FX_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_FX_ROOT="$(cd "$_FX_LIB_DIR/../.." && pwd)"

# ─────────────────────────────────────────────────────────
# Base — 빈 사용자 환경 (mktemp + install + git init)
# ─────────────────────────────────────────────────────────
make_fixture() {
  local dir
  dir=$(mktemp -d)
  bash "$_FX_ROOT/install.sh" --yes "$dir" >/dev/null 2>&1
  # install.sh 는 backlog/ 디렉토리만 만들고 queue.md 는 sdd 첫 호출 시 생성됨.
  # "사용 중인 사용자" 시뮬레이션 — queue.md 템플릿 복사로 초기 sdd 사용 후 상태 모사.
  if [ ! -f "$dir/backlog/queue.md" ] && [ -f "$dir/.harness-kit/agent/templates/queue.md" ]; then
    cp "$dir/.harness-kit/agent/templates/queue.md" "$dir/backlog/queue.md"
  fi
  git -C "$dir" init -q
  git -C "$dir" config user.email t@l
  git -C "$dir" config user.name t
  git -C "$dir" commit --allow-empty -m init -q 2>/dev/null
  echo "$dir"
}

# ─────────────────────────────────────────────────────────
# Mixin — in-flight phase/spec 가 진행 중인 사용자
# 사용: with_in_flight_phase <dir> [phase] [spec]
# ─────────────────────────────────────────────────────────
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

  # phase.md 생성 (sdd 마커 포함하여 sdd 도구가 인식 가능하게)
  cat > "$dir/backlog/${phase}.md" <<EOF
# ${phase}: in-flight (test fixture)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->
EOF

  # spec 디렉토리 + spec.md
  mkdir -p "$dir/specs/${spec}"
  cat > "$dir/specs/${spec}/spec.md" <<EOF
# ${spec}: in flight (test fixture)
EOF
}

# ─────────────────────────────────────────────────────────
# Mixin — 사용자가 미리 작성한 phase 들
# 사용: with_pre_defined_phases <dir> <phase-id>...
# ─────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────
# Mixin — 사용자가 커스터마이즈한 CLAUDE.fragment.md
# 사용: with_customized_fragment <dir>
# ─────────────────────────────────────────────────────────
with_customized_fragment() {
  local dir="$1"
  printf '\n## TEST_USER_FRAGMENT\n사용자 추가분 — 보존되어야 함.\n' \
    >> "$dir/.harness-kit/CLAUDE.fragment.md"
}

# ─────────────────────────────────────────────────────────
# Mixin — queue.md Icebox 영역에 사용자 메모
# 사용: with_dirty_queue_icebox <dir>
# ─────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────
# Mixin — settings.json 에 사용자 추가 hook (Pattern B 검증용)
# 사용: with_user_hook <dir>
# ─────────────────────────────────────────────────────────
with_user_hook() {
  local dir="$1"
  local s="$dir/.claude/settings.json"
  local _tmp
  _tmp=$(mktemp)
  jq '.hooks.UserAddedHook = [{"matcher":"*","hooks":[{"type":"command","command":"echo TEST_USER_HOOK"}]}]' \
     "$s" > "$_tmp"
  mv "$_tmp" "$s"
}
