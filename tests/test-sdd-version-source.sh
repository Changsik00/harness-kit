#!/usr/bin/env bash
# tests/test-sdd-version-source.sh
# spec-x-sdd-version-source-fix: sdd status/version 이 kitVersion 을 installed.json 에서 읽는지 검증
#
# 3 시나리오:
#   T1: current.json=0.6.2, installed.json=0.8.0 → sdd status 헤더에 0.8.0 표시
#   T2: current.json=0.6.2, installed.json=0.8.0 → sdd version 출력에 0.8.0 표시
#   T3: installed.json 없음 → sdd status 헤더에 '?' (graceful fallback)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-sdd-version-source ==="

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

# fixture 의 installed.json 버전을 강제로 덮어쓰는 헬퍼
set_installed_ver() {
  local fx="$1" ver="$2"
  local f="$fx/.harness-kit/installed.json"
  [ -f "$f" ] || return 1
  local tmp
  tmp=$(mktemp)
  jq --arg v "$ver" '.kitVersion = $v' "$f" > "$tmp" && mv "$tmp" "$f"
}

# fixture 의 current.json 버전만 변경하는 헬퍼
set_state_ver() {
  local fx="$1" ver="$2"
  local f="$fx/.claude/state/current.json"
  [ -f "$f" ] || return 1
  local tmp
  tmp=$(mktemp)
  jq --arg v "$ver" '.kitVersion = $v' "$f" > "$tmp" && mv "$tmp" "$f"
}

# ─────────────────────────────────────────────────────────
# T1: current.json=0.6.2, installed.json=0.8.0
#     → sdd status 헤더에 installed.json 버전(0.8.0) 표시
# ─────────────────────────────────────────────────────────
echo ""
echo "T1: installed.json=0.8.0, current.json=0.6.2 → status 헤더 0.8.0"
F1=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F1")

set_installed_ver "$F1" "0.8.0"
set_state_ver     "$F1" "0.6.2"

OUT1=$(run_sdd "$F1" status --no-drift)
if echo "$OUT1" | grep -qE "harness-kit 0\.8\.0"; then
  ok "status 헤더에 installed.json 버전(0.8.0) 표시됨"
else
  fail "status 헤더 버전 틀림 — 예상: 0.8.0, 실제: $(echo "$OUT1" | grep -oE 'harness-kit [0-9]+\.[0-9]+\.[0-9]+')"
fi
if echo "$OUT1" | grep -qE "harness-kit 0\.6\.2"; then
  fail "current.json 버전(0.6.2)이 표시되어선 안 됨"
else
  ok "current.json 버전(0.6.2) 미표시 확인"
fi

# ─────────────────────────────────────────────────────────
# T2: current.json=0.6.2, installed.json=0.8.0
#     → sdd version 출력에 0.8.0 표시
# ─────────────────────────────────────────────────────────
echo ""
echo "T2: installed.json=0.8.0, current.json=0.6.2 → sdd version 0.8.0"
F2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F2")

set_installed_ver "$F2" "0.8.0"
set_state_ver     "$F2" "0.6.2"

OUT2=$(run_sdd "$F2" version)
if echo "$OUT2" | grep -qE "harness-kit 0\.8\.0"; then
  ok "sdd version 에 installed.json 버전(0.8.0) 표시됨"
else
  fail "sdd version 버전 틀림 — 예상: 0.8.0, 실제: $OUT2"
fi

# ─────────────────────────────────────────────────────────
# T3: installed.json 없음 → sdd status 헤더에 '?' graceful fallback
# ─────────────────────────────────────────────────────────
echo ""
echo "T3: installed.json 없음 → sdd status 헤더 '?'"
F3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F3")

rm -f "$F3/.harness-kit/installed.json"

OUT3=$(run_sdd "$F3" status --no-drift)
if echo "$OUT3" | grep -qE "harness-kit \?"; then
  ok "installed.json 없을 때 '?' fallback 정상"
else
  fail "fallback '?' 미표시 — 실제: $(echo "$OUT3" | grep -oE 'harness-kit .*')"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
