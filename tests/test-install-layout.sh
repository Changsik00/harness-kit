#!/usr/bin/env bash
set -euo pipefail

# test-install-layout.sh
# spec-9-001: install.sh 가 .harness-kit/ 레이아웃으로 설치하는지 검증
#
# 검증 항목:
#   1) .harness-kit/agent/ 존재
#   2) .harness-kit/bin/sdd 존재 + 실행 가능
#   3) .harness-kit/hooks/ 존재
#   4) .harness-kit/installed.json 존재 + kitVersion 포함
#   5) agent/ 미생성 (충돌 방지)
#   6) scripts/harness/ 미생성 (충돌 방지)
#   7) .gitignore 에 .harness-kit/ 포함 (기본값: gitignore=true)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Install Layout Verification (spec-9-001)"
echo "═══════════════════════════════════════════"
echo ""

# --- 픽스처: 빈 git repo ---
FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_DIR"' EXIT

git -C "$FIXTURE_DIR" init -q
git -C "$FIXTURE_DIR" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_DIR" config user.email "test@harness-kit.local"
git -C "$FIXTURE_DIR" config user.name "harness-kit test"

echo "▶ install.sh --yes 실행 중..."
if ! bash "$INSTALL" --yes --shell=bash "$FIXTURE_DIR" > /dev/null 2>&1; then
  echo "  ❌ install.sh 실행 실패"
  exit 1
fi
echo ""

# --- Check 1: .harness-kit/agent/ 존재 ---
echo "▶ Check 1: .harness-kit/agent/ 존재"
check
if [ -d "$FIXTURE_DIR/.harness-kit/agent" ]; then
  pass ".harness-kit/agent/ 존재"
else
  fail ".harness-kit/agent/ 없음"
fi

# --- Check 2: .harness-kit/bin/sdd 존재 + 실행 가능 ---
echo "▶ Check 2: .harness-kit/bin/sdd 존재 및 실행 가능"
check
if [ -x "$FIXTURE_DIR/.harness-kit/bin/sdd" ]; then
  pass ".harness-kit/bin/sdd 존재 + 실행 가능"
else
  fail ".harness-kit/bin/sdd 없거나 실행 불가"
fi

# --- Check 3: .harness-kit/hooks/ 존재 ---
echo "▶ Check 3: .harness-kit/hooks/ 존재"
check
if [ -d "$FIXTURE_DIR/.harness-kit/hooks" ]; then
  pass ".harness-kit/hooks/ 존재"
else
  fail ".harness-kit/hooks/ 없음"
fi

# --- Check 4: .harness-kit/installed.json 존재 + kitVersion 포함 ---
echo "▶ Check 4: .harness-kit/installed.json + kitVersion"
check
INSTALLED_JSON="$FIXTURE_DIR/.harness-kit/installed.json"
if [ -f "$INSTALLED_JSON" ] && command -v jq >/dev/null 2>&1; then
  KIT_VER="$(jq -r '.kitVersion // empty' "$INSTALLED_JSON" 2>/dev/null || echo "")"
  if [ -n "$KIT_VER" ]; then
    pass ".harness-kit/installed.json 존재, kitVersion=$KIT_VER"
  else
    fail ".harness-kit/installed.json 에 kitVersion 없음"
  fi
elif [ -f "$INSTALLED_JSON" ]; then
  pass ".harness-kit/installed.json 존재 (jq 없어 내용 미검증)"
else
  fail ".harness-kit/installed.json 없음"
fi

# --- Check 5: agent/ 미생성 ---
echo "▶ Check 5: agent/ 미생성 (충돌 방지)"
check
if [ ! -d "$FIXTURE_DIR/agent" ]; then
  pass "agent/ 없음 (정상)"
else
  fail "agent/ 가 생성됨 — 기존 프로젝트 충돌 위험"
fi

# --- Check 6: scripts/harness/ 미생성 ---
echo "▶ Check 6: scripts/harness/ 미생성 (충돌 방지)"
check
if [ ! -d "$FIXTURE_DIR/scripts/harness" ]; then
  pass "scripts/harness/ 없음 (정상)"
else
  fail "scripts/harness/ 가 생성됨 — scripts/ 네임스페이스 오염"
fi

# --- Check 7: .gitignore 에 .harness-kit/ 포함 (기본값: gitignore=true) ---
echo "▶ Check 7: .gitignore 에 .harness-kit/ 포함 (기본값: gitignore=true)"
check
GI="$FIXTURE_DIR/.gitignore"
if [ -f "$GI" ] && grep -q '^\.harness-kit/' "$GI"; then
  pass ".gitignore 에 .harness-kit/ 포함 (gitignore=true 기본값)"
else
  fail ".gitignore 에 .harness-kit/ 없음"
fi

# --- 결과 ---
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL PASS ($TOTAL/$TOTAL)"
else
  echo " ❌ FAIL: $FAIL/$TOTAL"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
