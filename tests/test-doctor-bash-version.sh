#!/usr/bin/env bash
set -euo pipefail

# test-doctor-bash-version.sh
# spec-14-02: doctor 가 bash 4.0+ 를 required 로 요구하지 않는지 검증.
# bug-02 (docs/harness-kit-bug-02-...md) 의 false positive 회귀 방지.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " doctor bash version (spec-14-02)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# 검증 1 (lint-style): sources/bin/sdd 에 _check_tool "bash" "4.0" "required" 부재
# ─────────────────────────────────────────────────────────

echo "▶ Check 1: sources/bin/sdd 에 bash 4.0 required 부재"
check
if grep -E '_check_tool "bash" "4\.[0-9]+" "required"' "$SDD" > /dev/null; then
  fail "sdd 에 _check_tool \"bash\" \"4.x\" \"required\" 잔존"
  grep -nE '_check_tool "bash"' "$SDD" | sed 's/^/    /'
else
  pass "sdd 에 bash 4.x required 미사용"
fi

echo ""

# ─────────────────────────────────────────────────────────
# 검증 2: doctor 출력에 ❌ bash 패턴 부재
# ─────────────────────────────────────────────────────────

echo "▶ Check 2: doctor 출력에 ❌ bash 부재"
check
DOCTOR_OUT=$(bash "$SDD" doctor 2>&1 || true)
if echo "$DOCTOR_OUT" | grep -E "^[[:space:]]*❌[[:space:]]*bash" > /dev/null; then
  fail "doctor 출력에 ❌ bash 잔존"
  echo "$DOCTOR_OUT" | grep -E "bash" | sed 's/^/    /'
else
  pass "doctor 출력에 ❌ bash 없음"
fi

echo ""

# ─────────────────────────────────────────────────────────
# 검증 3: doctor 출력의 bash 라인이 ✅ 또는 ⚠️ 로 표시 (FAIL 아님)
# ─────────────────────────────────────────────────────────

echo "▶ Check 3: doctor 의 bash 라인이 PASS/WARN"
check
BASH_LINE=$(echo "$DOCTOR_OUT" | grep -E "^[[:space:]]*[✅⚠️❌][[:space:]]*bash" | head -1)
if [ -z "$BASH_LINE" ]; then
  fail "doctor 출력에 bash 라인 없음 (예상치 못한 형식)"
  echo "    출력 일부:"
  echo "$DOCTOR_OUT" | head -10 | sed 's/^/      /'
elif echo "$BASH_LINE" | grep -qE "^[[:space:]]*✅[[:space:]]*bash"; then
  pass "bash 라인 = PASS ($(echo "$BASH_LINE" | sed 's/^[[:space:]]*//'))"
elif echo "$BASH_LINE" | grep -qE "^[[:space:]]*⚠️"; then
  pass "bash 라인 = WARN (허용 범위)"
else
  fail "bash 라인 = FAIL"
  echo "    $BASH_LINE"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
  echo " ✅ ALL ${TOTAL} CHECKS PASSED"
else
  echo " ❌ FAIL: ${FAIL}/${TOTAL}"
  exit 1
fi
