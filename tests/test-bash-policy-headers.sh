#!/usr/bin/env bash
set -euo pipefail

# test-bash-policy-headers.sh
# spec-14-05: M3 — "bash 4.0+" 헤더 주석 잔재 제거 검증
#
# spec-14-02 가 CLAUDE.md / doctor 만 갱신했고 코드 헤더 주석은 그대로 남았음.
# 본 테스트는 sources/, install.sh, .harness-kit/ 영역에서 "bash 4.0+" 표현이
# 0 매치임을 검증.
#
# 제외 영역:
#   .harness-kit/agent/templates/  — 사용자 산출물 템플릿 (제어 외)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " bash policy headers (spec-14-05)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# 검증: "bash 4.0+" 표현이 sources/, install.sh, .harness-kit/ 에 없음
# ─────────────────────────────────────────────────────────

echo "▶ 'bash 4.0+' 표현 0 매치"

# sources/ 검사
check
SRC_HITS=$(grep -rn "bash 4\.0+" "$ROOT/sources" 2>/dev/null || true)
if [ -z "$SRC_HITS" ]; then
  pass "sources/ — 'bash 4.0+' 0 매치"
else
  fail "sources/ — 'bash 4.0+' 잔존:"
  echo "$SRC_HITS" | sed 's/^/    /'
fi

# install.sh 검사
check
INSTALL_HITS=$(grep -n "bash 4\.0+" "$ROOT/install.sh" 2>/dev/null || true)
if [ -z "$INSTALL_HITS" ]; then
  pass "install.sh — 'bash 4.0+' 0 매치"
else
  fail "install.sh — 'bash 4.0+' 잔존:"
  echo "$INSTALL_HITS" | sed 's/^/    /'
fi

# .harness-kit/ (단, agent/templates 제외)
check
HK_HITS=$(grep -rn "bash 4\.0+" "$ROOT/.harness-kit" --exclude-dir=templates 2>/dev/null || true)
if [ -z "$HK_HITS" ]; then
  pass ".harness-kit/ — 'bash 4.0+' 0 매치 (templates/ 제외)"
else
  fail ".harness-kit/ — 'bash 4.0+' 잔존:"
  echo "$HK_HITS" | sed 's/^/    /'
fi

echo ""

# ─────────────────────────────────────────────────────────
# 검증 추가: "bash 4.0+ 전용" 표현도 0 매치
# ─────────────────────────────────────────────────────────

echo "▶ 'bash 4.0+ 전용' 표현 0 매치"

check
EXCL_HITS=$(grep -rn "bash 4\.0+ 전용\|bash 4 전용\|bash 4\.0 전용" "$ROOT/sources" "$ROOT/install.sh" "$ROOT/.harness-kit" --exclude-dir=templates 2>/dev/null || true)
if [ -z "$EXCL_HITS" ]; then
  pass "'bash 4.0+ 전용' / '4 전용' 표현 0 매치"
else
  fail "'bash 4 전용' 표현 잔존:"
  echo "$EXCL_HITS" | sed 's/^/    /'
fi

echo ""
echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
  echo " ✅ ALL ${TOTAL} CHECKS PASSED"
else
  echo " ❌ FAIL: ${FAIL}/${TOTAL}"
  exit 1
fi
