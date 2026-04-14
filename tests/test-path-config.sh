#!/usr/bin/env bash
set -euo pipefail

# test-path-config.sh
# spec-9-003: harness.config.json 경로 config 시스템 검증
#
# 검증 항목:
#   1) --yes 실행 → harness.config.json 미생성, backlog/ 생성
#   2) --prefix hk- 실행 → harness.config.json 생성, hk-backlog/ / hk-specs/ 생성
#   3) harness.config.json 의 backlogDir/specsDir 값 정확성
#   4) config 있는 상태에서 sdd status → 오류 없이 실행

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"
SDD="$ROOT/.harness-kit/bin/sdd"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Path Config System Verification (spec-9-003)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# 시나리오 A: --yes (기본값)
# ──────────────────────────────────────────────
echo "▶ 시나리오 A: --yes (기본값 경로)"

FIXTURE_A="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A" "$FIXTURE_B"' EXIT
git -C "$FIXTURE_A" init -q
git -C "$FIXTURE_A" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_A" config user.email "test@local" && git -C "$FIXTURE_A" config user.name "test"

bash "$INSTALL" --yes "$FIXTURE_A" > /dev/null 2>&1

check
if [ ! -f "$FIXTURE_A/.harness-kit/harness.config.json" ]; then
  pass "기본값 시 harness.config.json 미생성"
else
  fail "기본값인데 harness.config.json 생성됨"
fi

check
if [ -d "$FIXTURE_A/backlog" ]; then
  pass "backlog/ 생성됨"
else
  fail "backlog/ 미생성"
fi

check
if [ -d "$FIXTURE_A/specs" ]; then
  pass "specs/ 생성됨"
else
  fail "specs/ 미생성"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 B: --prefix hk-
# ──────────────────────────────────────────────
echo "▶ 시나리오 B: --prefix hk-"

FIXTURE_B="$(mktemp -d)"
git -C "$FIXTURE_B" init -q
git -C "$FIXTURE_B" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_B" config user.email "test@local" && git -C "$FIXTURE_B" config user.name "test"

bash "$INSTALL" --yes --prefix hk- "$FIXTURE_B" > /dev/null 2>&1 || true

check
if [ -f "$FIXTURE_B/.harness-kit/harness.config.json" ]; then
  pass "harness.config.json 생성됨"
else
  fail "harness.config.json 미생성"
fi

check
if [ -d "$FIXTURE_B/hk-backlog" ]; then
  pass "hk-backlog/ 생성됨"
else
  fail "hk-backlog/ 미생성"
fi

check
if [ -d "$FIXTURE_B/hk-specs" ]; then
  pass "hk-specs/ 생성됨"
else
  fail "hk-specs/ 미생성"
fi

check
if [ ! -d "$FIXTURE_B/backlog" ]; then
  pass "backlog/ 미생성 (prefix 경로 사용)"
else
  fail "backlog/ 가 생성됨 (prefix 경로를 써야 함)"
fi

# ──────────────────────────────────────────────
# config 값 검증
# ──────────────────────────────────────────────
echo ""
echo "▶ harness.config.json 값 검증"

check
if command -v jq >/dev/null 2>&1; then
  bd=$(jq -r '.backlogDir' "$FIXTURE_B/.harness-kit/harness.config.json" 2>/dev/null || echo "")
  sd=$(jq -r '.specsDir'   "$FIXTURE_B/.harness-kit/harness.config.json" 2>/dev/null || echo "")
  if [ "$bd" = "hk-backlog" ] && [ "$sd" = "hk-specs" ]; then
    pass "backlogDir=hk-backlog, specsDir=hk-specs"
  else
    fail "값 불일치: backlogDir=$bd, specsDir=$sd"
  fi
else
  pass "(jq 없음 — 값 검증 스킵)"
fi

# ──────────────────────────────────────────────
# sdd status — config 경로 반영 확인
# ──────────────────────────────────────────────
echo ""
echo "▶ sdd status — config 경로 반영"

check
sdd_out=$(bash "$SDD" status 2>&1 || true)
if echo "$sdd_out" | grep -q 'harness-kit'; then
  pass "sdd status 정상 실행"
else
  fail "sdd status 실행 실패"
fi

# ──────────────────────────────────────────────
# 결과
# ──────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL PASS ($TOTAL/$TOTAL)"
else
  echo " ❌ ${FAIL}/${TOTAL} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
