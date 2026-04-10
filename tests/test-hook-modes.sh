#!/usr/bin/env bash
set -euo pipefail

# test-hook-modes.sh
# Per-hook 모드 해석 및 기본값 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FAIL=0
TOTAL_CHECKS=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); }

echo "═══════════════════════════════════════════"
echo " Hook Mode Verification"
echo "═══════════════════════════════════════════"
echo ""

# --- Check 1: _lib.sh에 hook_resolve_mode 함수 존재 ---
echo "▶ Check 1: _lib.sh에 hook_resolve_mode 함수 존재"
check
if grep -q 'hook_resolve_mode()' "$ROOT/sources/hooks/_lib.sh" 2>/dev/null; then
  pass "hook_resolve_mode 함수 존재"
else
  fail "hook_resolve_mode 함수 누락"
fi

# --- Check 2: check-branch.sh 기본 모드 = block ---
echo ""
echo "▶ Check 2: check-branch.sh 기본 모드 = block"
check
if grep -q 'hook_resolve_mode "BRANCH" "block"' "$ROOT/sources/hooks/check-branch.sh" 2>/dev/null; then
  pass "check-branch.sh 기본 block"
else
  fail "check-branch.sh에 hook_resolve_mode BRANCH block 누락"
fi

# --- Check 3: check-plan-accept.sh 기본 모드 = warn ---
echo ""
echo "▶ Check 3: check-plan-accept.sh 기본 모드 = warn"
check
if grep -q 'hook_resolve_mode "PLAN_ACCEPT" "warn"' "$ROOT/sources/hooks/check-plan-accept.sh" 2>/dev/null; then
  pass "check-plan-accept.sh 기본 warn"
else
  fail "check-plan-accept.sh에 hook_resolve_mode PLAN_ACCEPT warn 누락"
fi

# --- Check 4: check-test-passed.sh 기본 모드 = warn ---
echo ""
echo "▶ Check 4: check-test-passed.sh 기본 모드 = warn"
check
if grep -q 'hook_resolve_mode "TEST_PASSED" "warn"' "$ROOT/sources/hooks/check-test-passed.sh" 2>/dev/null; then
  pass "check-test-passed.sh 기본 warn"
else
  fail "check-test-passed.sh에 hook_resolve_mode TEST_PASSED warn 누락"
fi

# --- Check 5: sources ↔ scripts/harness 동기화 ---
echo ""
echo "▶ Check 5: sources/ ↔ scripts/harness/ 동기화"

for f in _lib.sh check-branch.sh check-plan-accept.sh check-test-passed.sh; do
  check
  if diff -q "$ROOT/sources/hooks/$f" "$ROOT/scripts/harness/hooks/$f" > /dev/null 2>&1; then
    pass "$f 동기화 OK"
  else
    fail "$f 불일치"
  fi
done

check
if diff -q "$ROOT/sources/bin/sdd" "$ROOT/scripts/harness/bin/sdd" > /dev/null 2>&1; then
  pass "sdd 동기화 OK"
else
  fail "sdd 불일치"
fi

# --- Check 6: sdd hooks 서브커맨드 존재 ---
echo ""
echo "▶ Check 6: sdd hooks 서브커맨드 존재"
check
if grep -q 'cmd_hooks' "$ROOT/sources/bin/sdd" 2>/dev/null; then
  pass "cmd_hooks 함수 존재"
else
  fail "cmd_hooks 함수 누락"
fi

check
if grep -q 'hooks).*cmd_hooks' "$ROOT/sources/bin/sdd" 2>/dev/null; then
  pass "hooks dispatch 등록됨"
else
  fail "hooks dispatch 미등록"
fi

# --- Check 7: sdd hooks 실행 테스트 ---
echo ""
echo "▶ Check 7: sdd hooks 실행 테스트"
check
output=$(bash "$ROOT/scripts/harness/bin/sdd" hooks 2>&1)
if echo "$output" | grep -q 'check-branch.sh' 2>/dev/null; then
  pass "sdd hooks 출력에 check-branch.sh 표시"
else
  fail "sdd hooks 실행 실패"
fi

# --- 결과 ---
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL ${TOTAL_CHECKS} CHECKS PASSED"
else
  echo " ❌ ${FAIL}/${TOTAL_CHECKS} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
