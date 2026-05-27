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
if bash "$ROOT/.harness-kit/bin/sdd" doctor 2>&1 | grep -q "wiki layer"; then
  pass "sdd doctor — 'wiki layer' 섹션 포함"
else
  fail "sdd doctor — 'wiki layer' 섹션 없음"
fi

# ─────────────────────────────────────────────
# 검증 2: W-1 — docs/wiki/ 없는 환경에서 ⚠ 경고 출력
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 2: W-1 — docs/wiki/ 부재 시 ⚠ 경고"
TMPDIR_TEST=$(mktemp -d)
check
# sdd doctor 는 SDD_ROOT 환경변수로 루트를 재정의할 수 있어야 함
# 없으면 fixture 에서 직접 grep 하여 W-1 코드 경로 검증
if SDD_ROOT="$TMPDIR_TEST" bash "$ROOT/.harness-kit/bin/sdd" doctor 2>&1 | grep -q "wiki layer 없음"; then
  pass "W-1 경고 — wiki layer 없음 출력 확인"
else
  fail "W-1 경고 — wiki layer 없음 출력 안 됨"
fi
rm -rf "$TMPDIR_TEST"

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
