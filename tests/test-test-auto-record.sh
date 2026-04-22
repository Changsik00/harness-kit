#!/usr/bin/env bash
set -euo pipefail

# test-test-auto-record.sh
# spec-13-03: sdd run-test 서브커맨드 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"
SDD_INSTALLED="$ROOT/.harness-kit/bin/sdd"
STATE_FILE="$ROOT/.claude/state/current.json"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " run-test Verification (spec-13-03)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# Check 1: sdd run-test 인자 없이 실행 → 사용법 안내 + exit 0
# ──────────────────────────────────────────────
echo "▶ Check 1: sdd run-test 인자 없이 실행 → 사용법 안내"
check
output=$(bash "$SDD" run-test 2>&1 || true)
if echo "$output" | grep -q "알 수 없는 명령"; then
  fail "sdd run-test 미구현 — 알 수 없는 명령 오류 출력"
elif echo "$output" | grep -qE "(usage|사용법|run-test|run_test|cmd)"; then
  pass "사용법 안내 출력됨"
else
  fail "사용법 안내 없음 (출력: $output)"
fi

check
if bash "$SDD" run-test > /dev/null 2>&1; then
  pass "인자 없이 실행 시 exit 0"
else
  fail "인자 없이 실행 시 exit 0 아님"
fi

# ──────────────────────────────────────────────
# Check 2: sdd help 출력에 run-test 항목 포함
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 2: sdd help에 run-test 항목 포함"
check
if bash "$SDD" help 2>&1 | grep -q "run-test"; then
  pass "sdd help에 run-test 포함"
else
  fail "sdd help에 run-test 없음"
fi

# ──────────────────────────────────────────────
# Check 3: exit 0 명령 실행 시 lastTestPass 갱신
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 3: exit 0 명령 실행 시 lastTestPass 자동 갱신"
check
# 현재 lastTestPass 저장 (JSON 공백 허용 패턴)
_get_last_test_pass() { grep -o '"lastTestPass": *"[^"]*"' "$STATE_FILE" 2>/dev/null || echo '"lastTestPass":null'; }
before=$(_get_last_test_pass)

bash "$SDD" run-test true > /dev/null 2>&1 || true

after=$(_get_last_test_pass)
if [ "$before" != "$after" ] && echo "$after" | grep -q '"lastTestPass"'; then
  pass "exit 0 명령 후 lastTestPass 갱신됨"
else
  fail "exit 0 명령 후 lastTestPass 갱신 안 됨 (before=$before after=$after)"
fi

# ──────────────────────────────────────────────
# Check 4: exit 1 명령 실행 시 lastTestPass 갱신 안 됨
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 4: exit 1 명령 실행 시 lastTestPass 갱신 안 됨"
check
before=$(_get_last_test_pass)

bash "$SDD" run-test false > /dev/null 2>&1 || true

after=$(_get_last_test_pass)
if [ "$before" = "$after" ]; then
  pass "exit 1 명령 후 lastTestPass 변경 없음"
else
  fail "exit 1 명령인데 lastTestPass 가 변경됨"
fi

check
if bash "$SDD" run-test false > /dev/null 2>&1; then
  fail "exit 1 명령인데 sdd run-test 가 exit 0 반환"
else
  pass "exit 1 명령 시 sdd run-test 도 exit 1 반환"
fi

# ──────────────────────────────────────────────
# Check 5: sources/bin/sdd ↔ .harness-kit/bin/sdd 동기화 확인
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 5: sources/bin/sdd ↔ .harness-kit/bin/sdd 동기화"
check
if diff -q "$SDD" "$SDD_INSTALLED" > /dev/null 2>&1; then
  pass "두 파일 동일 (동기화됨)"
else
  fail "sources/bin/sdd 와 .harness-kit/bin/sdd 불일치 — cp sources/bin/sdd .harness-kit/bin/sdd 필요"
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
