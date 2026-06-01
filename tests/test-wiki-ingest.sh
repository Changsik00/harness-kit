#!/usr/bin/env bash
set -euo pipefail

# test-wiki-ingest.sh
# spec-19-02: hk-wiki-ingest 관련 검증
#   1. sdd archive 완료 출력에 /hk-wiki-ingest 힌트 포함 여부
#   2. hk-wiki-ingest 커맨드 파일 존재 여부
#   3. docs/wiki/log.md 인제스트 형식 유효성

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FAIL=0
TOTAL=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " wiki ingest (spec-19-02)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
# 검증 1: hk-wiki-ingest 커맨드 파일 존재
# ─────────────────────────────────────────────
echo "▶ Check 1: hk-wiki-ingest 커맨드 파일 존재"
check
if [ -f "$ROOT/sources/commands/hk-wiki-ingest.md" ]; then
  pass "sources/commands/hk-wiki-ingest.md 존재"
else
  fail "sources/commands/hk-wiki-ingest.md 없음"
fi

check
if [ -f "$ROOT/.claude/commands/hk-wiki-ingest.md" ]; then
  pass ".claude/commands/hk-wiki-ingest.md 존재"
else
  fail ".claude/commands/hk-wiki-ingest.md 없음"
fi

# ─────────────────────────────────────────────
# 검증 2: sources/bin/sdd archive 힌트 포함
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 2: sdd archive 힌트 출력 포함"
check
if grep -q "wiki 갱신: /hk-wiki-ingest" "$ROOT/sources/bin/sdd"; then
  pass "sources/bin/sdd — archive 힌트 포함"
else
  fail "sources/bin/sdd — archive 힌트 없음"
fi

check
if grep -q "wiki 갱신: /hk-wiki-ingest" "$ROOT/.harness-kit/bin/sdd"; then
  pass ".harness-kit/bin/sdd — archive 힌트 포함"
else
  fail ".harness-kit/bin/sdd — archive 힌트 없음"
fi

# ─────────────────────────────────────────────
# 검증 3: hk-wiki-ingest 커맨드 내용 유효성
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 3: hk-wiki-ingest 커맨드 내용 유효성"
CMD="$ROOT/sources/commands/hk-wiki-ingest.md"
if [ -f "$CMD" ]; then
  check
  if grep -q "log.md" "$CMD"; then
    pass "log.md 참조 포함"
  else
    fail "log.md 참조 없음"
  fi

  check
  if grep -q "decisions.md" "$CMD"; then
    pass "decisions.md 참조 포함"
  else
    fail "decisions.md 참조 없음"
  fi

  check
  if grep -q "patterns.md" "$CMD"; then
    pass "patterns.md 참조 포함"
  else
    fail "patterns.md 참조 없음"
  fi
fi

# ─────────────────────────────────────────────
# 검증 4: docs/wiki/log.md 형식 유효성
# ─────────────────────────────────────────────
echo ""
echo "▶ Check 4: docs/wiki/log.md 인제스트 항목 형식"
LOG="$ROOT/docs/wiki/log.md"
check
if [ -f "$LOG" ]; then
  pass "log.md 존재"
else
  fail "log.md 없음"
fi

check
if grep -q "^### [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]" "$LOG"; then
  pass "log.md — 날짜 형식 항목 존재 (### YYYY-MM-DD)"
else
  fail "log.md — 날짜 형식 항목 없음"
fi

check
if grep -q "^\- \*\*대상\*\*:" "$LOG"; then
  pass "log.md — 대상 필드 존재"
else
  fail "log.md — 대상 필드 없음"
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
