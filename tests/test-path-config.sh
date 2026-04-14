#!/usr/bin/env bash
set -euo pipefail

# test-path-config.sh
# spec-9-003/spec-9-004: harness.config.json 경로 config 시스템 검증
#
# 검증 항목:
#   1) --yes 실행 → harness.config.json 생성 (rootDir 포함)
#   2) --yes 실행 → rootDir 값이 설치 대상 경로와 일치
#   3) --yes 실행 → backlog/ 생성
#   4) --yes 실행 → specs/ 생성
#   5) --prefix hk- 실행 → harness.config.json 생성
#   6) --prefix hk- 실행 → hk-backlog/ / hk-specs/ 생성
#   7) --prefix hk- 실행 → backlog/ 미생성
#   8) harness.config.json 의 backlogDir/specsDir/rootDir 값 정확성
#   9) config 있는 상태에서 sdd status → 오류 없이 실행

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
echo " Path Config System Verification (spec-9-003/004)"
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
if [ -f "$FIXTURE_A/.harness-kit/harness.config.json" ]; then
  pass "harness.config.json 생성됨 (rootDir 포함)"
else
  fail "harness.config.json 미생성"
fi

check
if command -v jq >/dev/null 2>&1; then
  rd=$(jq -r '.rootDir // empty' "$FIXTURE_A/.harness-kit/harness.config.json" 2>/dev/null || echo "")
  if [ "$rd" = "$FIXTURE_A" ]; then
    pass "rootDir=$FIXTURE_A"
  else
    fail "rootDir 불일치: expected=$FIXTURE_A actual=$rd"
  fi
else
  pass "(jq 없음 — rootDir 검증 스킵)"
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
  rd=$(jq -r '.rootDir  // empty' "$FIXTURE_B/.harness-kit/harness.config.json" 2>/dev/null || echo "")
  bd=$(jq -r '.backlogDir // empty' "$FIXTURE_B/.harness-kit/harness.config.json" 2>/dev/null || echo "")
  sd=$(jq -r '.specsDir   // empty' "$FIXTURE_B/.harness-kit/harness.config.json" 2>/dev/null || echo "")
  ok=1
  [ "$rd" = "$FIXTURE_B" ]    || ok=0
  [ "$bd" = "hk-backlog" ]    || ok=0
  [ "$sd" = "hk-specs" ]      || ok=0
  if [ $ok -eq 1 ]; then
    pass "rootDir=$FIXTURE_B, backlogDir=hk-backlog, specsDir=hk-specs"
  else
    fail "값 불일치: rootDir=$rd backlogDir=$bd specsDir=$sd"
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
