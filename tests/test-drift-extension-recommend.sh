#!/usr/bin/env bash
# tests/test-drift-extension-recommend.sh
# spec-23-01: _drift_extension_recommend() 검증
#   T1: 코드 프로젝트(.ts tracked) + serena 미설치 → "확장 권장" 출력
#   T2: tracked 코드 파일 없음 + 미설치 → 미출력
#   T3: 코드 프로젝트 + serena 설치됨(installed.json .extensions.serena) → 미출력
#
# bash 3.2+ 호환. fixture.sh 헬퍼 사용.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

[ -f "$LIB" ] || { echo "lib/fixture.sh 없음"; exit 1; }
[ -f "$SDD" ] || { echo "sources/bin/sdd 없음"; exit 1; }

# shellcheck source=lib/fixture.sh
source "$LIB"

FIXTURES_TO_CLEAN=()
cleanup() {
  local d
  for d in "${FIXTURES_TO_CLEAN[@]:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
  done
}
trap cleanup EXIT

run_sdd_status() {
  local fx="$1"; shift
  ( cd "$fx" && HARNESS_DRIFT_FETCH=0 bash "$SDD" status "$@" 2>&1 )
}

RECOMMEND="확장 권장"

echo "=== test-drift-extension-recommend ==="

# ── T1: 코드 프로젝트 + 미설치 → 권장 ──────────────────────
echo ""
echo "T1: 코드 프로젝트(.ts) + serena 미설치 → 권장 출력"
F1=$(make_fixture); FIXTURES_TO_CLEAN+=("$F1")
printf 'export const x = 1\n' > "$F1/app.ts"
git -C "$F1" add app.ts >/dev/null 2>&1
git -C "$F1" commit -q -m "add code" >/dev/null 2>&1
OUT1=$(run_sdd_status "$F1")
if echo "$OUT1" | grep -q "$RECOMMEND"; then
  ok "권장 라인 출력"
else
  fail "권장 라인 누락"
fi

# ── T2: tracked 코드 없음 → 미출력 ─────────────────────────
echo ""
echo "T2: tracked 코드 파일 없음 → 미출력"
F2=$(make_fixture); FIXTURES_TO_CLEAN+=("$F2")
OUT2=$(run_sdd_status "$F2")
if echo "$OUT2" | grep -q "$RECOMMEND"; then
  fail "비코드인데 권장 출력됨"
else
  ok "권장 미출력"
fi

# ── T3: 코드 프로젝트 + serena 설치됨 → 미출력 ──────────────
echo ""
echo "T3: 코드 프로젝트 + serena 설치됨 → 미출력"
F3=$(make_fixture); FIXTURES_TO_CLEAN+=("$F3")
printf 'export const x = 1\n' > "$F3/app.ts"
git -C "$F3" add app.ts >/dev/null 2>&1
git -C "$F3" commit -q -m "add code" >/dev/null 2>&1
_tmp=$(mktemp)
jq '.extensions.serena = {"scope":"local"}' "$F3/.harness-kit/installed.json" > "$_tmp"
mv "$_tmp" "$F3/.harness-kit/installed.json"
OUT3=$(run_sdd_status "$F3")
if echo "$OUT3" | grep -q "$RECOMMEND"; then
  fail "설치됨인데 권장 출력됨"
else
  ok "권장 미출력"
fi

echo ""
echo "── 결과: ${PASS} PASS / ${FAIL} FAIL ──"
[ "$FAIL" -eq 0 ] || exit 1
