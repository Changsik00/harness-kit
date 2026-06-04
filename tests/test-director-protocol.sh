#!/usr/bin/env bash
set -euo pipefail

# test-director-protocol.sh
# Verifies §6.8 Director Mode Protocol presence, mirror parity, and word budget.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

AGENT="$ROOT/sources/governance/agent.md"
AGENT_MIRROR="$ROOT/.harness-kit/agent/agent.md"
CONSTITUTION="$ROOT/sources/governance/constitution.md"

FAIL=0
TOTAL_CHECKS=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL_CHECKS=$((TOTAL_CHECKS + 1)); }

echo "═══════════════════════════════════════════"
echo " Director Protocol Verification"
echo "═══════════════════════════════════════════"
echo ""

# --- Check 1: §6.8 section exists ---
echo "▶ Check 1: §6.8 Director Mode Protocol 섹션 존재"
check
if grep -q "6.8 Director Mode Protocol" "$AGENT" 2>/dev/null; then
  pass "§6.8 Director Mode Protocol 섹션 발견"
else
  fail "§6.8 Director Mode Protocol 섹션 없음 (sources/governance/agent.md)"
fi

# --- Check 2: Key invariant terms ---
echo ""
echo "▶ Check 2: 핵심 불변식 용어 존재"

check
if grep -qi "intent handshake" "$AGENT" 2>/dev/null; then
  pass "'intent handshake' 용어 확인"
else
  fail "'intent handshake' 용어 없음"
fi

check
if grep -qi "distilled contract" "$AGENT" 2>/dev/null; then
  pass "'distilled contract' 용어 확인"
else
  fail "'distilled contract' 용어 없음"
fi

check
if grep -qi "re-ingestion\|full transcript" "$AGENT" 2>/dev/null; then
  pass "'re-ingestion' 또는 'full transcript' 용어 확인"
else
  fail "'re-ingestion' / 'full transcript' 용어 없음"
fi

check
if grep -q "Plan Accept" "$AGENT" 2>/dev/null; then
  pass "'Plan Accept' 용어 확인"
else
  fail "'Plan Accept' 용어 없음"
fi

# --- Check 3: Mirror parity ---
echo ""
echo "▶ Check 3: sources ↔ .harness-kit 미러 parity"
check
if diff -q "$AGENT" "$AGENT_MIRROR" > /dev/null 2>&1; then
  pass "agent.md 미러 동기화 OK"
else
  fail "agent.md 미러 불일치 (sources ↔ .harness-kit)"
fi

# --- Check 4: Word budget ---
echo ""
echo "▶ Check 4: 단어 예산 (constitution+agent.md 합계 8000w 이하)"
check

CONST_WORDS=$(wc -w < "$CONSTITUTION" | tr -d ' ')
AGENT_WORDS=$(wc -w < "$AGENT" | tr -d ' ')
TOTAL=$((CONST_WORDS + AGENT_WORDS))

echo "  constitution.md: ${CONST_WORDS} words"
echo "  agent.md:        ${AGENT_WORDS} words"
echo "  합계:            ${TOTAL} words"

LIMIT=8000
if [ "$TOTAL" -le "$LIMIT" ]; then
  pass "합계 ${TOTAL}w — 상한(${LIMIT}w) 이하"
else
  fail "합계 ${TOTAL}w — 상한(${LIMIT}w) 초과"
fi

# --- Summary ---
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL ${TOTAL_CHECKS} CHECKS PASSED"
else
  echo " ❌ ${FAIL}/${TOTAL_CHECKS} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
