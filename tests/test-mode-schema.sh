#!/usr/bin/env bash
# tests/test-mode-schema.sh
# spec-21-01: sdd mode 서브커맨드 + state mode 필드 검증
#
# 7 케이스:
#   T01: sdd mode status (mode 필드 없음) → "governed" 기본값 출력
#   T02: sdd mode turbo → current.json mode="turbo" 설정
#   T03: sdd mode status (turbo 설정 후) → "turbo" 출력
#   T04: sdd mode governed → current.json mode="governed" 복귀
#   T05: sdd mode status (governed 복귀 후) → "governed" 출력
#   T06: sdd status → "Active Mode" 행 포함
#   T07: sdd mode <잘못된 값> → exit 1

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-mode-schema ==="

if [ ! -f "$LIB" ]; then
  fail "tests/lib/fixture.sh 없음"
  exit 1
fi
if [ ! -f "$SDD" ]; then
  fail "sources/bin/sdd 없음"
  exit 1
fi

source "$LIB"

FIXTURES_TO_CLEAN=()
cleanup() {
  local d
  for d in "${FIXTURES_TO_CLEAN[@]:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
  done
}
trap cleanup EXIT

run_sdd() {
  local fx="$1"; shift
  ( cd "$fx" && HARNESS_DRIFT_FETCH=0 bash "$SDD" "$@" 2>&1 )
}

get_mode() {
  local fx="$1"
  jq -r '.mode // empty' "$fx/.claude/state/current.json" 2>/dev/null || echo ""
}

# ─────────────────────────────────────────────────────────
# T01: mode 필드 없을 때 status → "governed" 기본값
# ─────────────────────────────────────────────────────────
echo ""
echo "T01: sdd mode status — 기본값 governed"
FX=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX")

out=$(run_sdd "$FX" mode status)
if echo "$out" | grep -q "governed"; then
  ok "T01: 기본값 governed 출력"
else
  fail "T01: 기본값 governed 출력 안 됨 — got: $out"
fi

# ─────────────────────────────────────────────────────────
# T02: sdd mode turbo → state mode=turbo
# ─────────────────────────────────────────────────────────
echo ""
echo "T02: sdd mode turbo — state 파일 mode=turbo"
run_sdd "$FX" mode turbo >/dev/null 2>&1
mode_val=$(get_mode "$FX")
if [ "$mode_val" = "turbo" ]; then
  ok "T02: current.json mode=turbo 설정됨"
else
  fail "T02: current.json mode 기대=turbo, 실제=$mode_val"
fi

# ─────────────────────────────────────────────────────────
# T03: turbo 설정 후 status → "turbo" 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T03: sdd mode status — turbo 설정 후 turbo 출력"
out=$(run_sdd "$FX" mode status)
if echo "$out" | grep -q "turbo"; then
  ok "T03: status 출력에 turbo 포함"
else
  fail "T03: status 출력에 turbo 없음 — got: $out"
fi

# ─────────────────────────────────────────────────────────
# T04: sdd mode governed → state mode=governed
# ─────────────────────────────────────────────────────────
echo ""
echo "T04: sdd mode governed — state 파일 mode=governed 복귀"
run_sdd "$FX" mode governed >/dev/null 2>&1
mode_val=$(get_mode "$FX")
if [ "$mode_val" = "governed" ]; then
  ok "T04: current.json mode=governed 복귀"
else
  fail "T04: current.json mode 기대=governed, 실제=$mode_val"
fi

# ─────────────────────────────────────────────────────────
# T05: governed 복귀 후 status → "governed" 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T05: sdd mode status — governed 복귀 후 governed 출력"
out=$(run_sdd "$FX" mode status)
if echo "$out" | grep -q "governed"; then
  ok "T05: status 출력에 governed 포함"
else
  fail "T05: status 출력에 governed 없음 — got: $out"
fi

# ─────────────────────────────────────────────────────────
# T06: sdd status → "Active Mode" 행 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T06: sdd status — Active Mode 행 포함"
out=$(run_sdd "$FX" status)
if echo "$out" | grep -qi "active mode\|Active Mode"; then
  ok "T06: sdd status 에 Active Mode 행 있음"
else
  fail "T06: sdd status 에 Active Mode 행 없음"
fi

# ─────────────────────────────────────────────────────────
# T07: sdd mode <잘못된 값> → exit 1
# ─────────────────────────────────────────────────────────
echo ""
echo "T07: sdd mode invalid → exit 1"
FX2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX2")
if ! run_sdd "$FX2" mode invalid >/dev/null 2>&1; then
  ok "T07: 잘못된 mode 값 → exit 1"
else
  fail "T07: 잘못된 mode 값에도 exit 0 (오류 미감지)"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "=== 결과: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
