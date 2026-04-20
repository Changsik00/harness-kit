#!/usr/bin/env bash
set -euo pipefail

# test-export-format.sh
# spec-12-02: install.sh --export-format 옵션 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Export Format Option Verification (spec-12-02)"
echo "═══════════════════════════════════════════"
echo ""

_make_repo() {
  local d; d="$(mktemp -d)"
  git -C "$d" init -q
  git -C "$d" checkout -b main 2>/dev/null || true
  git -C "$d" config user.email "test@local"
  git -C "$d" config user.name "test"
  echo "$d"
}

# ──────────────────────────────────────────────
# Check 1: --export-format 미지정 → .cursorrules 생성 안 됨
# ──────────────────────────────────────────────
echo "▶ Check 1: --export-format 미지정 → .cursorrules 생성 안 됨"
check

REPO1="$(_make_repo)"
trap 'rm -rf "$REPO1"' EXIT

bash "$INSTALL" --yes "$REPO1" > /dev/null 2>&1

if [ ! -f "$REPO1/.cursorrules" ]; then
  pass ".cursorrules 없음 (기본 동작 유지)"
else
  fail ".cursorrules가 생성됨 (기본값=none 이어야 함)"
fi

echo ""

# ──────────────────────────────────────────────
# Check 2: --export-format=cursor → .cursorrules 생성
# ──────────────────────────────────────────────
echo "▶ Check 2: --export-format=cursor → .cursorrules 생성"
check

REPO2="$(_make_repo)"
trap 'rm -rf "$REPO1" "$REPO2"' EXIT

bash "$INSTALL" --yes --export-format=cursor "$REPO2" > /dev/null 2>&1

if [ -f "$REPO2/.cursorrules" ]; then
  pass ".cursorrules 생성됨"
else
  fail ".cursorrules 없음"
fi

echo ""

# ──────────────────────────────────────────────
# Check 3: .cursorrules 내용이 CLAUDE.fragment.md를 포함
# ──────────────────────────────────────────────
echo "▶ Check 3: .cursorrules 내용이 CLAUDE.fragment.md 내용 포함"
check

if [ -f "$REPO2/.cursorrules" ]; then
  fragment_line="$(head -3 "$ROOT/sources/claude-fragments/CLAUDE.fragment.md" | tail -1 | tr -d '[:space:]')"
  cursorrules_content="$(tr -d '[:space:]' < "$REPO2/.cursorrules")"
  if echo "$cursorrules_content" | grep -qF "$fragment_line" 2>/dev/null; then
    pass "CLAUDE.fragment.md 내용 포함됨"
  else
    fail ".cursorrules에 CLAUDE.fragment.md 내용 없음"
  fi
else
  fail ".cursorrules 파일 없음 (Check 2 실패 영향)"
fi

echo ""

# ──────────────────────────────────────────────
# Check 4: --export-format=copilot → .github/copilot-instructions.md 생성
# ──────────────────────────────────────────────
echo "▶ Check 4: --export-format=copilot → .github/copilot-instructions.md 생성"
check

REPO4="$(_make_repo)"
trap 'rm -rf "$REPO1" "$REPO2" "$REPO4"' EXIT

bash "$INSTALL" --yes --export-format=copilot "$REPO4" > /dev/null 2>&1

if [ -f "$REPO4/.github/copilot-instructions.md" ]; then
  pass ".github/copilot-instructions.md 생성됨"
else
  fail ".github/copilot-instructions.md 없음"
fi

echo ""

# ──────────────────────────────────────────────
# Check 5: 파일 이미 존재 시 덮어쓰기 경고 출력
# ──────────────────────────────────────────────
echo "▶ Check 5: 파일 이미 존재 시 경고 출력"
check

REPO5="$(_make_repo)"
trap 'rm -rf "$REPO1" "$REPO2" "$REPO4" "$REPO5"' EXIT

# 첫 번째 설치
bash "$INSTALL" --yes --export-format=cursor "$REPO5" > /dev/null 2>&1
# 두 번째 설치 (파일 이미 존재)
output5="$(bash "$INSTALL" --yes --export-format=cursor "$REPO5" 2>&1)"

if echo "$output5" | grep -qi "덮어\|overwrite\|exist\|경고\|warn\|already"; then
  pass "기존 파일 경고 출력됨"
else
  fail "기존 파일 경고 없음: '$output5'"
fi

echo ""

# ──────────────────────────────────────────────
# 결과
# ──────────────────────────────────────────────
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL ${TOTAL} CHECKS PASSED"
else
  echo " ❌ ${FAIL}/${TOTAL} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
