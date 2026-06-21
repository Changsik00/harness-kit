#!/usr/bin/env bash
set -uo pipefail

# test-stop-rules.sh
# spec-24-03: 정지규칙 엔진
#   ② check-irreversible.sh — 비가역/파괴 명령 감지 (PreToolUse Bash, 경고 모드)
#   ③ post-commit-verify.sh — 반복 실패 카운터 (Task 2 에서 추가)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$ROOT/sources/hooks/check-irreversible.sh"

# ③ 테스트용 fixture (post-commit-verify 를 설치된 환경에서 검증)
source "$SCRIPT_DIR/lib/fixture.sh"
FIXTURES_TO_CLEAN=()
trap 'for d in "${FIXTURES_TO_CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

# fixture state/precheck 헬퍼
_set_mode()    { local t; t=$(mktemp); jq --arg v "$2" '.mode=$v' "$1/.claude/state/current.json" > "$t" && mv "$t" "$1/.claude/state/current.json"; }
_set_count()   { local t; t=$(mktemp); jq --argjson v "$2" '.autoFailCount=$v' "$1/.claude/state/current.json" > "$t" && mv "$t" "$1/.claude/state/current.json"; }
_get_count()   { jq -r '.autoFailCount // 0' "$1/.claude/state/current.json"; }
_set_precheck(){ local t; t=$(mktemp); jq --arg c "$2" '.precheck=[$c]' "$1/.harness-kit/installed.json" > "$t" && mv "$t" "$1/.harness-kit/installed.json"; }
_commit_count(){ git -C "$1" log --oneline | wc -l | tr -d ' '; }
_fresh_commit(){ echo "x$RANDOM" > "$1/f.txt"; git -C "$1" add f.txt; git -C "$1" commit -q -m "feat: change"; }
_run_verify()  { ( cd "$1" && bash "$1/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ); }

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
echo "▶ ③ 반복 테스트 실패 카운터 (post-commit-verify, auto)"

# T11: auto + 실패(count 0→1) → revert + 카운터 증가, hard-stop 아님
FX11="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX11")
_set_mode "$FX11" auto; _set_precheck "$FX11" "false"; _set_count "$FX11" 0
_fresh_commit "$FX11"
before11="$(_commit_count "$FX11")"
out11="$(_run_verify "$FX11")"
after11="$(_commit_count "$FX11")"; cnt11="$(_get_count "$FX11")"
if [ "$cnt11" = "1" ] && [ "$after11" -gt "$before11" ] && ! echo "$out11" | grep -q "hard-stop"; then
  ok "T11: 실패 1회 → count=1 + auto-revert (hard-stop 아님)"
else
  fail "T11: count=$cnt11 revert=${before11}-${after11} out=$out11"
fi

# T12: auto + 실패(count 2→3=MAX) → hard-stop, revert 안 함
FX12="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX12")
_set_mode "$FX12" auto; _set_precheck "$FX12" "false"; _set_count "$FX12" 2
_fresh_commit "$FX12"
before12="$(_commit_count "$FX12")"
out12="$(_run_verify "$FX12")"
after12="$(_commit_count "$FX12")"; cnt12="$(_get_count "$FX12")"
if [ "$cnt12" = "3" ] && [ "$after12" -eq "$before12" ] && echo "$out12" | grep -q "hard-stop"; then
  ok "T12: 3회(MAX) 연속 실패 → hard-stop + revert 보류"
else
  fail "T12: count=$cnt12 revert=${before12}-${after12} out=$out12"
fi

# T13: auto + 통과 → 카운터 0 리셋
FX13="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX13")
_set_mode "$FX13" auto; _set_precheck "$FX13" "true"; _set_count "$FX13" 2
_fresh_commit "$FX13"
out13="$(_run_verify "$FX13")"; cnt13="$(_get_count "$FX13")"
if [ "$cnt13" = "0" ] && echo "$out13" | grep -q "검증 통과"; then
  ok "T13: 통과 → 카운터 0 리셋"
else
  fail "T13: count=$cnt13 (기대 0) out=$out13"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
