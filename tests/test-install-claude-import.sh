#!/usr/bin/env bash
set -euo pipefail

# test-install-claude-import.sh
# spec-9-002: install.sh 가 CLAUDE.md 에 @import 3줄만 삽입하는지 검증
#
# 검증 항목:
#   1) .harness-kit/CLAUDE.fragment.md 생성 확인
#   2) CLAUDE.md 에 @.harness-kit/CLAUDE.fragment.md 줄 존재
#   3) CLAUDE.md 에 규약 내용 직접 삽입 미존재 (3줄 @import 방식 확인)
#   4) fragment 내 핵심 규칙 요약 존재
#   5) 멱등성: 재실행 시 @import 줄 중복 없음
#   6) 기존 CLAUDE.md 내용 보존 확인

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " CLAUDE.md @import Install Verification (spec-9-002)"
echo "═══════════════════════════════════════════"
echo ""

# --- 픽스처: 빈 git repo ---
FIXTURE_DIR="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_DIR"' EXIT

git -C "$FIXTURE_DIR" init -q
git -C "$FIXTURE_DIR" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_DIR" config user.email "test@harness-kit.local"
git -C "$FIXTURE_DIR" config user.name "harness-kit test"

# 기존 CLAUDE.md 내용 미리 작성 (보존 확인용)
echo "# My Project" > "$FIXTURE_DIR/CLAUDE.md"
echo "" >> "$FIXTURE_DIR/CLAUDE.md"
echo "사용자 커스텀 지침 내용입니다." >> "$FIXTURE_DIR/CLAUDE.md"

# install 실행
bash "$INSTALL" --yes "$FIXTURE_DIR" > /dev/null 2>&1

# --- Check 1: .harness-kit/CLAUDE.fragment.md 생성 ---
echo "▶ Check 1: .harness-kit/CLAUDE.fragment.md 생성"
check
if [ -f "$FIXTURE_DIR/.harness-kit/CLAUDE.fragment.md" ]; then
  pass ".harness-kit/CLAUDE.fragment.md 존재"
else
  fail ".harness-kit/CLAUDE.fragment.md 미생성"
fi

# --- Check 2: CLAUDE.md 에 @import 줄 존재 ---
echo ""
echo "▶ Check 2: CLAUDE.md 에 @import 줄 존재"
check
if grep -q '^@\.harness-kit/CLAUDE\.fragment\.md' "$FIXTURE_DIR/CLAUDE.md" 2>/dev/null; then
  pass "CLAUDE.md 에 @.harness-kit/CLAUDE.fragment.md 존재"
else
  fail "CLAUDE.md 에 @import 줄 누락"
fi

# --- Check 3: CLAUDE.md 에 규약 내용 직접 삽입 미존재 ---
echo ""
echo "▶ Check 3: CLAUDE.md 에 규약 내용 직접 삽입 없음 (3줄 @import 방식)"
check
if grep -q '에이전트 운영 규약' "$FIXTURE_DIR/CLAUDE.md" 2>/dev/null; then
  fail "CLAUDE.md 에 규약 내용이 직접 삽입됨 (구 방식)"
else
  pass "규약 내용 직접 삽입 없음 (올바른 @import 방식)"
fi

# --- Check 4: fragment 내 핵심 규칙 요약 존재 ---
echo ""
echo "▶ Check 4: fragment 내 핵심 규칙 요약 존재"
check
if grep -q '핵심 규칙 요약' "$FIXTURE_DIR/.harness-kit/CLAUDE.fragment.md" 2>/dev/null; then
  pass "fragment 에 핵심 규칙 요약 존재"
else
  fail "fragment 에 핵심 규칙 요약 누락"
fi

# --- Check 5: 멱등성 — 재실행 시 @import 줄 중복 없음 ---
echo ""
echo "▶ Check 5: 멱등성 — 재실행 시 @import 중복 없음"
bash "$INSTALL" --yes "$FIXTURE_DIR" > /dev/null 2>&1
check
import_count=$(grep -c '^@\.harness-kit/CLAUDE\.fragment\.md' "$FIXTURE_DIR/CLAUDE.md" 2>/dev/null || true)
import_count="${import_count:-0}"
if [ "$import_count" -eq 1 ]; then
  pass "@import 줄 1개 (중복 없음)"
else
  fail "@import 줄 ${import_count}개 (중복 발생)"
fi

# --- Check 6: 기존 CLAUDE.md 내용 보존 ---
echo ""
echo "▶ Check 6: 기존 CLAUDE.md 내용 보존"
check
if grep -q '사용자 커스텀 지침 내용입니다' "$FIXTURE_DIR/CLAUDE.md" 2>/dev/null; then
  pass "기존 CLAUDE.md 내용 보존됨"
else
  fail "기존 CLAUDE.md 내용 손실"
fi

# --- 결과 ---
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL PASS ($TOTAL/$TOTAL)"
else
  echo " ❌ ${FAIL}/${TOTAL} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
