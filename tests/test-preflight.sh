#!/usr/bin/env bash
set -euo pipefail

# test-preflight.sh
# spec-9-009: install.sh / update.sh preflight 스캔 검증
#
# 검증 항목:
#   A) 클린 디렉토리 설치 — 경고 없음
#   B) 이미 설치됨 — "이미 설치됨" 경고
#   C) v0.3 레이아웃 감지 — "v0.3" 경고
#   D) 버전 다운그레이드 — "다운그레이드" 경고 (update.sh)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"
UPDATE="$ROOT/update.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Preflight Scan Verification (spec-9-009)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# 시나리오 A: 클린 디렉토리 — 경고 없음
# ──────────────────────────────────────────────
echo "▶ 시나리오 A: 클린 디렉토리 설치 — preflight 경고 없음"

FIXTURE_A="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A"' EXIT
git -C "$FIXTURE_A" init -q
git -C "$FIXTURE_A" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_A" config user.email "test@local"
git -C "$FIXTURE_A" config user.name "test"

output_a="$(bash "$INSTALL" --yes "$FIXTURE_A" 2>&1)"
exit_a=$?

check
if [ $exit_a -eq 0 ]; then
  pass "exit 0"
else
  fail "exit code: $exit_a"
fi

check
if echo "$output_a" | grep -q "⚠"; then
  fail "클린 설치인데 경고 발생: $(echo "$output_a" | grep '⚠')"
else
  pass "preflight 경고 없음"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 B: 이미 설치됨 — "이미 설치됨" 경고
# ──────────────────────────────────────────────
echo "▶ 시나리오 B: 이미 설치됨 — 재설치 시 경고"

FIXTURE_B="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A" "$FIXTURE_B"' EXIT
git -C "$FIXTURE_B" init -q
git -C "$FIXTURE_B" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_B" config user.email "test@local"
git -C "$FIXTURE_B" config user.name "test"

# 첫 번째 설치
bash "$INSTALL" --yes "$FIXTURE_B" > /dev/null 2>&1

# 두 번째 설치 (이미 설치됨 상태)
output_b="$(bash "$INSTALL" --yes "$FIXTURE_B" 2>&1)"

check
if echo "$output_b" | grep -q "이미 설치됨"; then
  pass "\"이미 설치됨\" 경고 출력됨"
else
  fail "\"이미 설치됨\" 경고 없음 (출력: $(echo "$output_b" | grep '⚠' || echo '없음'))"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 C: v0.3 레이아웃 감지 — "v0.3" 경고
# ──────────────────────────────────────────────
echo "▶ 시나리오 C: v0.3 레이아웃 감지 — 경고"

FIXTURE_C="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A" "$FIXTURE_B" "$FIXTURE_C"' EXIT
git -C "$FIXTURE_C" init -q
git -C "$FIXTURE_C" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_C" config user.email "test@local"
git -C "$FIXTURE_C" config user.name "test"

# v0.3 아티팩트 생성
mkdir -p "$FIXTURE_C/agent"
echo "# fake constitution" > "$FIXTURE_C/agent/constitution.md"

output_c="$(bash "$INSTALL" --yes "$FIXTURE_C" 2>&1)"

check
if echo "$output_c" | grep -q "v0.3"; then
  pass "\"v0.3\" 경고 출력됨"
else
  fail "\"v0.3\" 경고 없음 (출력: $(echo "$output_c" | grep '⚠' || echo '없음'))"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 D: 버전 다운그레이드 — "다운그레이드" 경고 (update.sh)
# ──────────────────────────────────────────────
echo "▶ 시나리오 D: 버전 다운그레이드 — update.sh 경고"

FIXTURE_D="$(mktemp -d)"
trap 'rm -rf "$FIXTURE_A" "$FIXTURE_B" "$FIXTURE_C" "$FIXTURE_D"' EXIT
git -C "$FIXTURE_D" init -q
git -C "$FIXTURE_D" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_D" config user.email "test@local"
git -C "$FIXTURE_D" config user.name "test"

# 설치
bash "$INSTALL" --yes "$FIXTURE_D" > /dev/null 2>&1

# installed.json 의 kitVersion 을 미래 버전으로 조작 (다운그레이드 시뮬레이션)
jq '.kitVersion = "9.9.9"' "$FIXTURE_D/.harness-kit/installed.json" > /tmp/pf_test_installed.json
mv /tmp/pf_test_installed.json "$FIXTURE_D/.harness-kit/installed.json"

output_d="$(bash "$UPDATE" --yes "$FIXTURE_D" 2>&1)"

check
if echo "$output_d" | grep -q "다운그레이드"; then
  pass "\"다운그레이드\" 경고 출력됨"
else
  fail "\"다운그레이드\" 경고 없음 (출력: $(echo "$output_d" | grep '⚠' || echo '없음'))"
fi

echo ""

# ──────────────────────────────────────────────
# 결과
# ──────────────────────────────────────────────
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL PASS ($TOTAL/$TOTAL)"
else
  echo " ❌ ${FAIL}/${TOTAL} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
