#!/usr/bin/env bash
set -uo pipefail

# test-askquestion-auto.sh
# spec-25-01: auto 모드에서 AskUserQuestion 을 PreToolUse hook 으로 차단하는 백스톱.
#   - mode=auto      → 차단(exit 2) + stderr 리다이렉트 지침
#   - mode=governed  → 통과(exit 0)
#   - mode=turbo     → 통과(exit 0)
#   - HARNESS_HOOK_MODE_ASKQUESTION=warn → 경고(exit 0) override
#   - state/mode 부재 → fail-safe 통과(exit 0)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$ROOT/sources/hooks/check-askquestion-auto.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

# run_hook <mode|none> [extra_env]
#   임시 프로젝트 루트(.claude/state/current.json) 를 만들고 그 안에서 hook 실행.
#   _out = stderr, _rc = exit code
_out=""; _rc=0
run_hook() {
  local mode="$1" extra_env="${2:-}"
  local dir; dir=$(mktemp -d)
  if [ "$mode" != "none" ]; then
    mkdir -p "$dir/.claude/state"
    printf '{"mode":"%s"}\n' "$mode" > "$dir/.claude/state/current.json"
  fi
  if [ -n "$extra_env" ]; then
    _out="$( cd "$dir" && env $extra_env bash "$HOOK" 2>&1 1>/dev/null )"; _rc=$?
  else
    _out="$( cd "$dir" && bash "$HOOK" 2>&1 1>/dev/null )"; _rc=$?
  fi
  rm -rf "$dir"
}

echo "═══════════════════════════════════════════════════════"
echo " test-askquestion-auto (spec-25-01)"
echo "═══════════════════════════════════════════════════════"

# 1) auto → 차단(exit 2) + 리다이렉트 지침
run_hook auto
if [ "$_rc" -eq 2 ] && echo "$_out" | grep -q "hook:block"; then
  ok "auto → 차단 (exit 2 + hook:block)"
else
  fail "auto → 차단 기대 (rc=$_rc)"
fi
if echo "$_out" | grep -qi "decision add"; then
  ok "auto → stderr 에 'decision add' 리다이렉트 지침"
else
  fail "auto → 리다이렉트 지침 누락"
fi

# 2) governed → 통과(exit 0, 무발동)
run_hook governed
if [ "$_rc" -eq 0 ] && ! echo "$_out" | grep -q "hook:"; then
  ok "governed → 통과 (exit 0, 무발동)"
else
  fail "governed → 통과 기대 (rc=$_rc, out=$_out)"
fi

# 3) turbo → 통과(exit 0, 무발동)
run_hook turbo
if [ "$_rc" -eq 0 ] && ! echo "$_out" | grep -q "hook:"; then
  ok "turbo → 통과 (exit 0, 무발동)"
else
  fail "turbo → 통과 기대 (rc=$_rc, out=$_out)"
fi

# 4) auto + warn override → 경고만(exit 0)
run_hook auto "HARNESS_HOOK_MODE_ASKQUESTION=warn"
if [ "$_rc" -eq 0 ] && echo "$_out" | grep -q "hook:warn"; then
  ok "auto + warn override → 경고 + exit 0"
else
  fail "auto + warn override → 경고/exit0 기대 (rc=$_rc)"
fi

# 5) state/mode 부재 → fail-safe 통과(exit 0)
run_hook none
if [ "$_rc" -eq 0 ]; then
  ok "mode 부재 → fail-safe 통과 (exit 0)"
else
  fail "mode 부재 → 통과 기대 (rc=$_rc)"
fi

echo ""
echo "─────────────────────────────────────────"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
