#!/usr/bin/env bash
# tests/test-sdd-config.sh
# spec-x-governance-ask-user-guideline: sdd config ux-mode 커맨드 검증
#
# 4 시나리오:
#   T1: sdd config ux-mode text        → installed.json uxMode=text 갱신
#   T2: sdd config ux-mode interactive → installed.json uxMode=interactive 갱신
#   T3: sdd config ux-mode (인자 없음) → 현재 설정 출력
#   T4: 잘못된 값                       → 오류 메시지 출력

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-sdd-config ==="

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

get_ux_mode() {
  local fx="$1"
  jq -r '.uxMode // empty' "$fx/.harness-kit/installed.json" 2>/dev/null || echo ""
}

# ─────────────────────────────────────────────────────────
# T1: sdd config ux-mode text → installed.json uxMode=text
# ─────────────────────────────────────────────────────────
echo ""
echo "T1: sdd config ux-mode text → installed.json uxMode=text"
F1=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F1")

run_sdd "$F1" config ux-mode text >/dev/null
ACTUAL=$(get_ux_mode "$F1")
if [ "$ACTUAL" = "text" ]; then
  ok "installed.json uxMode=text 갱신됨"
else
  fail "uxMode 갱신 실패 — 예상: text, 실제: $ACTUAL"
fi

# ─────────────────────────────────────────────────────────
# T2: sdd config ux-mode interactive → uxMode=interactive
# ─────────────────────────────────────────────────────────
echo ""
echo "T2: sdd config ux-mode interactive → uxMode=interactive"
F2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F2")

# 먼저 text로 설정 후 interactive로 복원
run_sdd "$F2" config ux-mode text >/dev/null
run_sdd "$F2" config ux-mode interactive >/dev/null
ACTUAL2=$(get_ux_mode "$F2")
if [ "$ACTUAL2" = "interactive" ]; then
  ok "installed.json uxMode=interactive 복원됨"
else
  fail "uxMode 복원 실패 — 예상: interactive, 실제: $ACTUAL2"
fi

# ─────────────────────────────────────────────────────────
# T3: sdd config ux-mode (인자 없음) → 현재 설정 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T3: sdd config ux-mode (인자 없음) → 현재값 출력"
F3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F3")

# uxMode=text 로 설정 후 인자 없이 호출
run_sdd "$F3" config ux-mode text >/dev/null
OUT3=$(run_sdd "$F3" config ux-mode)
if echo "$OUT3" | grep -qE "text"; then
  ok "현재 uxMode 출력됨: $OUT3"
else
  fail "현재 uxMode 출력 실패 — 실제: $OUT3"
fi

# ─────────────────────────────────────────────────────────
# T4: 잘못된 값 → 오류 메시지
# ─────────────────────────────────────────────────────────
echo ""
echo "T4: sdd config ux-mode invalid → 오류 출력"
F4=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F4")

OUT4=$(run_sdd "$F4" config ux-mode invalid 2>&1 || true)
if echo "$OUT4" | grep -qiE "invalid|error|오류|허용|interactive|text"; then
  ok "잘못된 값에 오류 메시지 출력"
else
  fail "오류 메시지 누락 — 실제: $OUT4"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
