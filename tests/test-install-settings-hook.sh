#!/usr/bin/env bash
# tests/test-install-settings-hook.sh
# spec-15-06: install 후 settings.json hook 보존 동작 검증.
#   - 키트 hook event type(PreToolUse, SessionStart)은 fragment 최신 버전으로 갱신
#   - 사용자 추가 hook event type은 install 후에도 보존
#   - 재설치 후 사용자 hook 중복 없음 (멱등성)
#   - 사용자 hook 없을 때 kit hook만 존재 (기존 동작 유지)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

echo "═══════════════════════════════════════════════════════"
echo " test-install-settings-hook (spec-15-06) — hook preserve"
echo "═══════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────
# Test 1: 키트 hook(PreToolUse) 갱신 확인
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 1: install 후 PreToolUse 가 fragment 버전으로 갱신됨"
F1=$(mktemp -d); CLEANUP+=("$F1")
bash "$ROOT/install.sh" --yes "$F1" >/dev/null 2>&1

kit_hook_count=$(jq '.hooks.PreToolUse | length' "$F1/.claude/settings.json" 2>/dev/null || echo "0")
if [ "$kit_hook_count" -gt 0 ]; then
  ok "Test 1: PreToolUse 존재 ($kit_hook_count 개 matcher)"
else
  fail "Test 1: PreToolUse 없음"
fi

# ─────────────────────────────────────────────────────────
# Test 2: 사용자 추가 hook event type 보존
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 2: 사용자 UserAddedHook → install 후 보존"
F2=$(mktemp -d); CLEANUP+=("$F2")
bash "$ROOT/install.sh" --yes "$F2" >/dev/null 2>&1

# 사용자가 settings.json 에 커스텀 hook event type 추가
_tmp=$(mktemp)
jq '.hooks.UserAddedHook = [{"matcher":"*","hooks":[{"type":"command","command":"echo TEST_USER_HOOK"}]}]' \
   "$F2/.claude/settings.json" > "$_tmp"
mv "$_tmp" "$F2/.claude/settings.json"

# 재설치
bash "$ROOT/install.sh" --yes "$F2" >/dev/null 2>&1

user_hook=$(jq -r '.hooks.UserAddedHook[0].hooks[0].command // ""' "$F2/.claude/settings.json" 2>/dev/null)
if [ "$user_hook" = "echo TEST_USER_HOOK" ]; then
  ok "Test 2: UserAddedHook 보존됨"
else
  fail "Test 2: UserAddedHook 손실 (값: '$user_hook')"
fi

# ─────────────────────────────────────────────────────────
# Test 3: 사용자 hook 멱등성 — 재설치 후 중복 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 3: 재설치 후 UserAddedHook 중복 없음 (멱등성)"
F3=$(mktemp -d); CLEANUP+=("$F3")
bash "$ROOT/install.sh" --yes "$F3" >/dev/null 2>&1

_tmp=$(mktemp)
jq '.hooks.UserAddedHook = [{"matcher":"*","hooks":[{"type":"command","command":"echo IDEMPOTENT"}]}]' \
   "$F3/.claude/settings.json" > "$_tmp"
mv "$_tmp" "$F3/.claude/settings.json"

# 두 번 재설치
bash "$ROOT/install.sh" --yes "$F3" >/dev/null 2>&1
bash "$ROOT/install.sh" --yes "$F3" >/dev/null 2>&1

user_hook_count=$(jq '.hooks.UserAddedHook | length' "$F3/.claude/settings.json" 2>/dev/null || echo "0")
if [ "$user_hook_count" -eq 1 ]; then
  ok "Test 3: UserAddedHook 중복 없음 (count=1)"
else
  fail "Test 3: UserAddedHook 중복 발생 (count=$user_hook_count)"
fi

# ─────────────────────────────────────────────────────────
# Test 4: 사용자 hook 없을 때 기존 동작 유지
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 4: 사용자 hook 없을 때 kit hook 정상 존재"
F4=$(mktemp -d); CLEANUP+=("$F4")
bash "$ROOT/install.sh" --yes "$F4" >/dev/null 2>&1

pre_tool_use=$(jq '.hooks.PreToolUse | length' "$F4/.claude/settings.json" 2>/dev/null || echo "0")
session_start=$(jq '.hooks.SessionStart | length' "$F4/.claude/settings.json" 2>/dev/null || echo "0")
user_added=$(jq 'has("UserAddedHook")' "$F4/.claude/settings.json" 2>/dev/null || echo "false")

if [ "$pre_tool_use" -gt 0 ] && [ "$session_start" -gt 0 ] && [ "$user_added" = "false" ]; then
  ok "Test 4: kit hook만 존재 (PreToolUse=$pre_tool_use, SessionStart=$session_start, 사용자 hook 없음)"
else
  fail "Test 4: 예상과 다름 (PreToolUse=$pre_tool_use, SessionStart=$session_start, UserAddedHook=$user_added)"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
