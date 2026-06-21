#!/usr/bin/env bash
set -uo pipefail

# test-stop-rules.sh
# spec-24-03: 정지규칙 엔진
#   ② check-irreversible.sh — 비가역/파괴 명령 감지 (PreToolUse Bash, 경고 모드)
#   ③ post-commit-verify.sh — 반복 실패 카운터 (Task 2 에서 추가)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$ROOT/sources/hooks/check-irreversible.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "═══════════════════════════════════════════════════════"
echo " test-stop-rules (spec-24-03)"
echo "═══════════════════════════════════════════════════════"

# run_hook <mode> <command> → _out(stderr), _rc
# mode: warn | block
_out=""; _rc=0
run_hook() {
  local mode="$1" cmd="$2"
  if [ "$mode" = "block" ]; then
    _out="$(CLAUDE_TOOL_INPUT_command="$cmd" HARNESS_HOOK_MODE_STOP_RULES=block bash "$HOOK" 2>&1 1>/dev/null)"; _rc=$?
  else
    _out="$(CLAUDE_TOOL_INPUT_command="$cmd" bash "$HOOK" 2>&1 1>/dev/null)"; _rc=$?
  fi
}

# 경고 발동 + 미차단(exit 0)
assert_warn() {
  local label="$1"
  if [ "$_rc" -eq 0 ] && echo "$_out" | grep -q "hook:warn"; then
    ok "$label → 경고 + exit 0"
  else
    fail "$label → 경고/exit0 기대 (rc=$_rc, warn=$(echo "$_out" | grep -c hook:warn))"
  fi
}

# 무경고 + 통과
assert_quiet() {
  local label="$1"
  if [ "$_rc" -eq 0 ] && ! echo "$_out" | grep -q "hook:"; then
    ok "$label → 무경고 + exit 0"
  else
    fail "$label → 무경고 기대인데 발동 (rc=$_rc)"
  fi
}

# ─────────────────────────────────────────────────────────
echo ""
echo "▶ ② 비가역 행동 감지 훅"

# T1: 훅 존재
if [ -f "$HOOK" ]; then ok "T1: check-irreversible.sh 존재"; else fail "T1: check-irreversible.sh 없음 ($HOOK)"; fi

# T2~T6: 비가역 명령 → 경고
run_hook warn "git push --force origin main"; assert_warn "T2: git push --force"
run_hook warn "git push -f"; assert_warn "T3: git push -f"
run_hook warn "rm -rf /"; assert_warn "T4: rm -rf /"
run_hook warn "git clean -fdx"; assert_warn "T5: git clean -fdx"
run_hook warn "npm publish"; assert_warn "T6: npm publish"

# T7~T9: 정상/경계 명령 → 무경고 (false-positive 없음)
run_hook warn "git status"; assert_quiet "T7: git status"
run_hook warn "git commit -m 'feat: x'"; assert_quiet "T8: git commit"
run_hook warn "git reset --hard HEAD~1"; assert_quiet "T9: git reset --hard (경계 제외)"

# T10: block 모드 → exit 2
run_hook block "git push --force"
if [ "$_rc" -eq 2 ] && echo "$_out" | grep -q "hook:block"; then
  ok "T10: block 모드 → exit 2"
else
  fail "T10: block 모드 exit 2 기대 (rc=$_rc)"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
