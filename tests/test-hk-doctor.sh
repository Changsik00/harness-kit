#!/usr/bin/env bash
set -euo pipefail

# test-hk-doctor.sh
# spec-13-01: sdd doctor 서브커맨드 + hk-doctor 슬래시 커맨드 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"
CMD="$ROOT/sources/commands/hk-doctor.md"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " hk-doctor Verification (spec-13-01)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# Check 1: sdd doctor 실행 시 체크리스트 형식 출력
# ──────────────────────────────────────────────
echo "▶ Check 1: sdd doctor 체크리스트 출력"
check
output=$(bash "$SDD" doctor 2>&1 || true)
if echo "$output" | grep -q "알 수 없는 명령"; then
  fail "sdd doctor 미구현 — 알 수 없는 명령 오류 출력"
else
  pass "sdd doctor 명령 인식됨"
fi

# ──────────────────────────────────────────────
# Check 2: sdd doctor 종료 코드 0 (FAIL 항목 있어도)
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 2: sdd doctor exit code 0"
check
bash "$SDD" doctor > /dev/null 2>&1
exit_code=$?
if [ "$exit_code" -eq 0 ]; then
  pass "exit code 0"
else
  fail "exit code $exit_code (doctor는 항상 0이어야 함)"
fi

# ──────────────────────────────────────────────
# Check 3: hk-doctor.md 파일 존재 + description frontmatter
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 3: sources/commands/hk-doctor.md 존재 및 frontmatter"
check
if [ -f "$CMD" ]; then
  pass "hk-doctor.md 존재"
else
  fail "hk-doctor.md 없음: $CMD"
fi

check
if [ -f "$CMD" ] && grep -q "^description:" "$CMD"; then
  pass "description frontmatter 포함"
else
  fail "description frontmatter 없음"
fi

# ──────────────────────────────────────────────
# Check 4: sdd help 출력에 doctor 항목 포함
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 4: sdd help에 doctor 항목 포함"
check
if bash "$SDD" help 2>&1 | grep -q "doctor"; then
  pass "sdd help에 doctor 포함"
else
  fail "sdd help에 doctor 없음"
fi

# ──────────────────────────────────────────────
# Check 5: sdd doctor 출력에 필수 도구 항목 포함
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 5: sdd doctor 출력에 필수 도구 항목 포함 (bash, jq, git)"
check
output=$(bash "$SDD" doctor 2>&1 || true)
for tool in bash jq git; do
  if echo "$output" | grep -qi "$tool"; then
    : # ok
  else
    fail "doctor 출력에 '$tool' 없음"
    TOTAL=$((TOTAL - 1)) # 이미 check() 호출됨
  fi
done
if echo "$output" | grep -qi "bash" && echo "$output" | grep -qi "jq" && echo "$output" | grep -qi "git"; then
  pass "bash / jq / git 항목 모두 포함"
else
  : # already failed above
fi

# ──────────────────────────────────────────────
# 결과
# ──────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
  echo " ✅ ALL ${TOTAL} CHECKS PASSED"
else
  echo " ❌ FAIL: ${FAIL}/${TOTAL}"
fi
echo "═══════════════════════════════════════════"

exit "$FAIL"
