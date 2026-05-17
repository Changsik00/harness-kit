#!/usr/bin/env bash
# tests/test-sdd-search.sh
# spec-x-sdd-search: sdd search <keyword> [--scope=<s>] [--ignore-case] 검증
#
# 시나리오:
#   T1: 전체 scope, archive 매치 → exit 0 + 그룹 헤더 + 매치 라인
#   T2: 매치 없음 → exit 1 + "검색 결과 없음"
#   T3: --scope=decisions 만 매치 → 다른 그룹 헤더 없음
#   T4: --ignore-case 매치
#   T5: regex "foo|bar" 매치
#   T6: 인자 없음 → die
#   T7: invalid scope → die

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-sdd-search ==="

[ -f "$LIB" ] || { fail "tests/lib/fixture.sh 없음"; exit 1; }
[ -f "$SDD" ] || { fail "sources/bin/sdd 없음"; exit 1; }

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

# 시나리오용 markdown 자산 주입 헬퍼
seed_assets() {
  local fx="$1"
  mkdir -p "$fx/specs/spec-active-1" "$fx/archive/specs/spec-archived-1" "$fx/docs/decisions" "$fx/docs/rca" "$fx/backlog"
  echo "active foo content" > "$fx/specs/spec-active-1/spec.md"
  echo "archived foo finding" > "$fx/archive/specs/spec-archived-1/walkthrough.md"
  echo "decision FOO uppercase" > "$fx/docs/decisions/ADR-001-test.md"
  echo "rca bar entry" > "$fx/docs/rca/RCA-001-test.md"
  echo "backlog baz item" > "$fx/backlog/phase-99.md"
}

# ─────────────────────────────────────────────────────────
# T1: 전체 scope, archive 매치
# ─────────────────────────────────────────────────────────
echo ""
echo "T1: sdd search foo (all scope) → archive 그룹 + active 그룹 매치"
F1=$(make_fixture); FIXTURES_TO_CLEAN+=("$F1")
seed_assets "$F1"
OUT1=$(run_sdd "$F1" search foo)
RC1=$?
if [ "$RC1" -eq 0 ] && echo "$OUT1" | grep -q "▶ archive" && echo "$OUT1" | grep -q "▶ active"; then
  ok "전체 scope 그룹 헤더 + 매치 출력"
else
  fail "T1 실패 — rc=$RC1, out=$OUT1"
fi

# ─────────────────────────────────────────────────────────
# T2: 매치 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "T2: sdd search nonexistent_xyz → exit 1 + 검색 결과 없음"
F2=$(make_fixture); FIXTURES_TO_CLEAN+=("$F2")
seed_assets "$F2"
OUT2=$(run_sdd "$F2" search nonexistent_xyz)
RC2=$?
if [ "$RC2" -ne 0 ] && echo "$OUT2" | grep -q "검색 결과 없음"; then
  ok "매치 없음 → exit 1 + 메시지"
else
  fail "T2 실패 — rc=$RC2, out=$OUT2"
fi

# ─────────────────────────────────────────────────────────
# T3: --scope=decisions 만
# ─────────────────────────────────────────────────────────
echo ""
echo "T3: sdd search foo --scope=decisions → decisions 만"
F3=$(make_fixture); FIXTURES_TO_CLEAN+=("$F3")
seed_assets "$F3"
OUT3=$(run_sdd "$F3" search foo --scope=decisions --ignore-case)
RC3=$?
if [ "$RC3" -eq 0 ] && echo "$OUT3" | grep -q "▶ decisions" && ! echo "$OUT3" | grep -q "▶ active" && ! echo "$OUT3" | grep -q "▶ archive"; then
  ok "scope 제한 동작"
else
  fail "T3 실패 — rc=$RC3, out=$OUT3"
fi

# ─────────────────────────────────────────────────────────
# T4: --ignore-case
# ─────────────────────────────────────────────────────────
echo ""
echo "T4: sdd search foo --ignore-case → FOO (대문자) 매치"
F4=$(make_fixture); FIXTURES_TO_CLEAN+=("$F4")
seed_assets "$F4"
OUT4=$(run_sdd "$F4" search foo --ignore-case)
RC4=$?
if [ "$RC4" -eq 0 ] && echo "$OUT4" | grep -q "▶ decisions"; then
  ok "--ignore-case 매치"
else
  fail "T4 실패 — rc=$RC4, out=$OUT4"
fi

# ─────────────────────────────────────────────────────────
# T5: regex "foo|bar"
# ─────────────────────────────────────────────────────────
echo ""
echo "T5: sdd search 'foo|bar' → archive + rca 동시 매치"
F5=$(make_fixture); FIXTURES_TO_CLEAN+=("$F5")
seed_assets "$F5"
OUT5=$(run_sdd "$F5" search 'foo|bar')
RC5=$?
if [ "$RC5" -eq 0 ] && echo "$OUT5" | grep -q "▶ archive" && echo "$OUT5" | grep -q "▶ rca"; then
  ok "regex 매치"
else
  fail "T5 실패 — rc=$RC5, out=$OUT5"
fi

# ─────────────────────────────────────────────────────────
# T6: 인자 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "T6: sdd search (인자 없음) → die"
F6=$(make_fixture); FIXTURES_TO_CLEAN+=("$F6")
OUT6=$(run_sdd "$F6" search 2>&1)
RC6=$?
if [ "$RC6" -ne 0 ] && echo "$OUT6" | grep -qE "사용법|usage"; then
  ok "인자 없음 → die"
else
  fail "T6 실패 — rc=$RC6, out=$OUT6"
fi

# ─────────────────────────────────────────────────────────
# T7: invalid scope
# ─────────────────────────────────────────────────────────
echo ""
echo "T7: sdd search foo --scope=invalid → die"
F7=$(make_fixture); FIXTURES_TO_CLEAN+=("$F7")
OUT7=$(run_sdd "$F7" search foo --scope=invalid 2>&1)
RC7=$?
if [ "$RC7" -ne 0 ] && echo "$OUT7" | grep -qiE "scope|잘못"; then
  ok "invalid scope → die"
else
  fail "T7 실패 — rc=$RC7, out=$OUT7"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
