#!/usr/bin/env bash
set -euo pipefail

# test-doctor-wiki.sh
# spec-19-03: sdd doctor wiki layer 점검 검증
#   1. sdd doctor 출력에 "wiki layer" 섹션 존재
#   2. W-1: docs/wiki/ 없는 환경에서 ⚠ 경고 포함 출력
#   3. docs/project-guide.md 존재
#   4. CLAUDE.md 에 docs/project-guide.md 포인터 포함
#   5. sources/governance/constitution.md 에 Rule Prune Guidance 섹션 존재

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FAIL=0
TOTAL=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " doctor wiki 점검 (spec-19-03)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
# 검증 1: sdd doctor 출력에 "wiki layer" 섹션 존재
# ─────────────────────────────────────────────
echo "▶ Check 1: sdd doctor — wiki layer 섹션 출력"
check
# grep -q 가 파이프 조기 닫으면 sdd 가 SIGPIPE → pipefail 트리거. 출력 캡처 후 grep.
_doctor_out=$(bash "$ROOT/.harness-kit/bin/sdd" doctor 2>&1 || true)
if echo "$_doctor_out" | grep -q "wiki layer"; then
  pass "sdd doctor — 'wiki layer' 섹션 포함"
else
  fail "sdd doctor — 'wiki layer' 섹션 없음"
fi

# ─────────────────────────────────────────────
# 검증 2: W-1 — sdd doctor 코드에 wiki layer 없음 경고 경로 존재
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 2: W-1 — sdd 코드에 'wiki layer 없음' 경고 문구 포함"
check
if grep -q "wiki layer 없음" "$ROOT/.harness-kit/bin/sdd"; then
  pass "W-1 경고 문구 — .harness-kit/bin/sdd 포함"
else
  fail "W-1 경고 문구 — .harness-kit/bin/sdd 없음"
fi

# ─────────────────────────────────────────────
# 검증 3: docs/project-guide.md 존재
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 3: docs/project-guide.md 존재"
check
if [ -f "$ROOT/docs/project-guide.md" ]; then
  pass "docs/project-guide.md 존재"
else
  fail "docs/project-guide.md 없음"
fi

# ─────────────────────────────────────────────
# 검증 4: CLAUDE.md 에 docs/project-guide.md 포인터 포함
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 4: CLAUDE.md — docs/project-guide.md 포인터"
check
if grep -q "project-guide.md" "$ROOT/CLAUDE.md"; then
  pass "CLAUDE.md — project-guide.md 포인터 포함"
else
  fail "CLAUDE.md — project-guide.md 포인터 없음"
fi

# ─────────────────────────────────────────────
# 검증 5: constitution.md 에 Rule Prune Guidance 섹션 존재
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 5: sources/governance/constitution.md — Rule Prune Guidance"
check
if grep -q "Rule Prune Guidance" "$ROOT/sources/governance/constitution.md"; then
  pass "constitution.md — Rule Prune Guidance 섹션 포함"
else
  fail "constitution.md — Rule Prune Guidance 섹션 없음"
fi

# ─────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────"
echo " 결과: $((TOTAL - FAIL))/$TOTAL PASS"
echo "───────────────────────────────────────────"
if [ "$FAIL" -gt 0 ]; then
  echo " ✗ FAIL ($FAIL 개 실패)"
  exit 1
else
  echo " ✓ ALL PASS"
fi
