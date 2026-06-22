#!/usr/bin/env bash
set -uo pipefail

# test-test-trust.sh
# spec-25-02: 칸0 — commit-time 가짜 green 휴리스틱 (경고).
#   (a) 구현 변경 ∧ 테스트 무변경 → 경고
#   (b) 단언 없는 테스트 추가 → 경고
#   안전 경로(docs/·*.md 등)·구현+테스트 동반 → 무경고
#   mode 무관(blast-radius 가드처럼 항상), exit 0(경고만).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$ROOT/sources/hooks/check-test-trust.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEAN=()
trap 'for d in "${CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

_mkrepo() {
  local d; d=$(mktemp -d); CLEAN+=("$d")
  git -C "$d" init -q
  git -C "$d" config user.email t@l; git -C "$d" config user.name t
  git -C "$d" commit --allow-empty -q -m init
  printf '%s' "$d"
}
# run_tt <repodir> → stderr, _rc
_out=""; _rc=0
run_tt() { _out="$( cd "$1" && HARNESS_GIT_HOOK_MODE=1 bash "$HOOK" 2>&1 1>/dev/null )"; _rc=$?; }

echo "═══════════════════════════════════════════════════════"
echo " test-test-trust (spec-25-02 칸0)"
echo "═══════════════════════════════════════════════════════"

# A) 구현 변경 + 테스트 무변경 → 경고
A=$(_mkrepo); mkdir -p "$A/src"; echo 'echo hi' > "$A/src/foo.sh"; git -C "$A" add src/foo.sh
run_tt "$A"
if [ "$_rc" -eq 0 ] && echo "$_out" | grep -q "test-trust:warn" && echo "$_out" | grep -q "src/foo.sh"; then
  ok "구현 변경 ∧ 테스트 무변경 → 경고"
else
  fail "(a) 경고 기대 (rc=$_rc, out=$_out)"
fi

# B) 구현 + 테스트(단언 있음) 동반 → 무경고
B=$(_mkrepo); mkdir -p "$B/src" "$B/tests"
echo 'echo hi' > "$B/src/foo.sh"
printf 'ok "result"\nassert_eq 1 1\n' > "$B/tests/test-foo.sh"
git -C "$B" add src/foo.sh tests/test-foo.sh
run_tt "$B"
if [ "$_rc" -eq 0 ] && ! echo "$_out" | grep -q "test-trust:warn"; then
  ok "구현 + 테스트 동반 → 무경고"
else
  fail "(b) 무경고 기대인데 발동 (rc=$_rc, out=$_out)"
fi

# C) 단언 없는 테스트 추가 → 경고
C=$(_mkrepo); mkdir -p "$C/tests"
printf 'echo "plain output line"\n' > "$C/tests/test-empty.sh"
git -C "$C" add tests/test-empty.sh
run_tt "$C"
if [ "$_rc" -eq 0 ] && echo "$_out" | grep -q "test-trust:warn" && echo "$_out" | grep -q "test-empty.sh"; then
  ok "단언 없는 테스트 → 경고"
else
  fail "(c) 경고 기대 (rc=$_rc, out=$_out)"
fi

# D) 안전 경로(docs/*.md)만 → 무경고
D=$(_mkrepo); mkdir -p "$D/docs"; echo '# doc' > "$D/docs/x.md"; git -C "$D" add docs/x.md
run_tt "$D"
if [ "$_rc" -eq 0 ] && ! echo "$_out" | grep -q "test-trust:warn"; then
  ok "안전 경로(docs/*.md) → 무경고"
else
  fail "(d) 무경고 기대인데 발동 (rc=$_rc, out=$_out)"
fi

# E) self-match 오탐 방지: 'check-test-trust.sh' 같은 이름은 구현(테스트 아님)
E=$(_mkrepo); mkdir -p "$E/sources/hooks"
echo 'echo impl' > "$E/sources/hooks/check-test-trust.sh"
git -C "$E" add sources/hooks/check-test-trust.sh
run_tt "$E"
# 구현으로 분류 + 테스트 무변경 → (a) 경고가 나야 정상 (테스트로 오분류되면 (a) 안 남)
if [ "$_rc" -eq 0 ] && echo "$_out" | grep -q "test-trust:warn"; then
  ok "이름에 'test' 포함 구현 → 테스트 오분류 안 함 (a 경고)"
else
  fail "(e) self-match 오탐 — 구현인데 테스트로 분류 (rc=$_rc, out=$_out)"
fi

echo ""
echo "─────────────────────────────────────────"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
