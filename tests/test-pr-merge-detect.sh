#!/usr/bin/env bash
set -euo pipefail

# test-pr-merge-detect.sh
# spec-13-02: sdd pr-watch 서브커맨드 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"
SDD_INSTALLED="$ROOT/.harness-kit/bin/sdd"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " pr-watch Verification (spec-13-02)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# Check 1: sdd pr-watch 인자 없이 실행 시 사용법 안내 출력
# ──────────────────────────────────────────────
echo "▶ Check 1: sdd pr-watch 인자 없이 실행 → 사용법 안내"
check
output=$(bash "$SDD" pr-watch 2>&1 || true)
if echo "$output" | grep -q "알 수 없는 명령"; then
  fail "sdd pr-watch 미구현 — 알 수 없는 명령 오류 출력"
elif echo "$output" | grep -qE "(usage|사용법|pr-watch|pr_watch|PR.번호|pr-number)"; then
  pass "사용법 안내 출력됨"
else
  fail "사용법 안내 없음 (출력: $output)"
fi

# ──────────────────────────────────────────────
# Check 2: sdd help 출력에 pr-watch 항목 포함
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 2: sdd help에 pr-watch 항목 포함"
check
if bash "$SDD" help 2>&1 | grep -q "pr-watch"; then
  pass "sdd help에 pr-watch 포함"
else
  fail "sdd help에 pr-watch 없음"
fi

# ──────────────────────────────────────────────
# Check 3: gh 미설치 시 graceful 안내 + exit 0
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 3: gh 미설치 환경에서 graceful 안내 + exit 0"
# gh 없는 환경 시뮬레이션: fake_bin 에 gh 없이 PATH 재구성
# bash/sh 는 절대 경로로 호출하므로 PATH 는 gh 탐색에만 영향
BASH_PATH="$(command -v bash)"
BASH_DIR="$(dirname "$BASH_PATH")"
fake_bin=$(mktemp -d)
trap 'rm -rf "$fake_bin"' EXIT
# bash 디렉토리 + 기타 필수 도구 포함, gh 만 제외
no_gh_path="$fake_bin:$BASH_DIR:/usr/bin:/bin"

check
if PATH="$no_gh_path" bash "$SDD" pr-watch 123 > /dev/null 2>&1; then
  pass "gh 없는 환경에서 exit 0"
else
  fail "gh 없는 환경에서 exit $? (0이어야 함)"
fi

check
output=$(PATH="$no_gh_path" bash "$SDD" pr-watch 123 2>&1 || true)
if echo "$output" | grep -qE "(gh|설치|install)"; then
  pass "gh 미설치 안내 메시지 출력됨"
else
  fail "gh 미설치 안내 없음 (출력: $output)"
fi

# ──────────────────────────────────────────────
# Check 4: sources/bin/sdd ↔ .harness-kit/bin/sdd 동기화 확인
# ──────────────────────────────────────────────
echo ""
echo "▶ Check 4: sources/bin/sdd ↔ .harness-kit/bin/sdd 동기화"
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
