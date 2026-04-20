#!/usr/bin/env bash
set -euo pipefail

# test-staged-lint.sh
# spec-12-01: check-staged-lint.sh 훅 동작 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$ROOT/sources/hooks/check-staged-lint.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Staged Lint Hook Verification (spec-12-01)"
echo "═══════════════════════════════════════════"
echo ""

# 임시 git 저장소 생성 헬퍼
_make_repo() {
  local d; d="$(mktemp -d)"
  git -C "$d" init -q
  git -C "$d" checkout -b main 2>/dev/null || true
  git -C "$d" config user.email "test@local"
  git -C "$d" config user.name "test"
  echo "$d"
}

# ──────────────────────────────────────────────
# Check 1: staged 파일 없음 → silent skip (exit 0)
# ──────────────────────────────────────────────
echo "▶ Check 1: staged 파일 없음 → silent skip"
check

REPO1="$(_make_repo)"
trap 'rm -rf "$REPO1"' EXIT

output1="$(cd "$REPO1" && HARNESS_HOOK_MODE=warn bash "$HOOK" 2>&1)"
exit1=$?

if [ $exit1 -eq 0 ] && [ -z "$output1" ]; then
  pass "exit 0, 출력 없음"
else
  fail "exit=$exit1, output='$output1'"
fi

echo ""

# ──────────────────────────────────────────────
# Check 2: 타입 미감지 → skip (마커 파일 없음)
# ──────────────────────────────────────────────
echo "▶ Check 2: 타입 미감지 → skip"
check

REPO2="$(_make_repo)"
trap 'rm -rf "$REPO1" "$REPO2"' EXIT

# 마커 파일 없는 상태에서 파일 staged
echo "hello" > "$REPO2/readme.txt"
git -C "$REPO2" add readme.txt

output2="$(cd "$REPO2" && HARNESS_HOOK_MODE=warn bash "$HOOK" 2>&1)"
exit2=$?

if [ $exit2 -eq 0 ]; then
  pass "exit 0 (타입 미감지 시 skip)"
else
  fail "exit=$exit2"
fi

echo ""

# ──────────────────────────────────────────────
# Check 3: Node.js 타입 + eslint 없음 → 경고 후 exit 0
# ──────────────────────────────────────────────
echo "▶ Check 3: Node.js 타입 + eslint 없음 → 경고 후 exit 0"
check

REPO3="$(_make_repo)"
trap 'rm -rf "$REPO1" "$REPO2" "$REPO3"' EXIT

echo '{"name":"test"}' > "$REPO3/package.json"
echo 'const x = 1;' > "$REPO3/app.js"
git -C "$REPO3" add package.json app.js

# eslint 없는 PATH 사용
output3="$(cd "$REPO3" && PATH="/usr/bin:/bin" HARNESS_HOOK_MODE=warn bash "$HOOK" 2>&1)"
exit3=$?

if [ $exit3 -eq 0 ]; then
  pass "exit 0 (eslint 없어도 통과)"
else
  fail "exit=$exit3 (exit 0 이어야 함)"
fi

check
if echo "$output3" | grep -qi "eslint\|lint\|경고\|warn\|skip"; then
  pass "경고 메시지 출력됨"
else
  fail "경고 메시지 없음: '$output3'"
fi

echo ""

# ──────────────────────────────────────────────
# Check 4: Shell 타입 + shellcheck 있음 → shellcheck 실행
# ──────────────────────────────────────────────
echo "▶ Check 4: Shell 타입 + shellcheck 있음 → shellcheck 실행"

SHELLCHECK_BIN="$(command -v shellcheck 2>/dev/null || true)"
if [ -z "$SHELLCHECK_BIN" ]; then
  echo "  ⚠️  shellcheck 미설치 — Check 4 건너뜀"
else
  check

  REPO4="$(_make_repo)"
  trap 'rm -rf "$REPO1" "$REPO2" "$REPO3" "$REPO4"' EXIT

  # 유효한 shell 파일 staged
  printf '#!/usr/bin/env bash\necho "hello"\n' > "$REPO4/run.sh"
  git -C "$REPO4" add run.sh

  output4="$(cd "$REPO4" && HARNESS_HOOK_MODE=warn bash "$HOOK" 2>&1)"
  exit4=$?

  if [ $exit4 -eq 0 ]; then
    pass "shellcheck 실행 후 exit 0"
  else
    fail "exit=$exit4"
  fi
fi

echo ""

# ──────────────────────────────────────────────
# Check 5: Shell 타입 + shellcheck 없음 → 경고 후 exit 0
# ──────────────────────────────────────────────
echo "▶ Check 5: Shell 타입 + shellcheck 없음 → 경고 후 exit 0"
check

REPO5="$(_make_repo)"
trap 'rm -rf "$REPO1" "$REPO2" "$REPO3" "$REPO5"' EXIT

printf '#!/usr/bin/env bash\necho "hello"\n' > "$REPO5/run.sh"
git -C "$REPO5" add run.sh

# shellcheck 없는 PATH
output5="$(cd "$REPO5" && PATH="/usr/bin:/bin" HARNESS_HOOK_MODE=warn bash "$HOOK" 2>&1)"
exit5=$?

if [ $exit5 -eq 0 ]; then
  pass "exit 0 (shellcheck 없어도 통과)"
else
  fail "exit=$exit5"
fi

check
if echo "$output5" | grep -qi "shellcheck\|경고\|warn\|skip"; then
  pass "경고 메시지 출력됨"
else
  fail "경고 메시지 없음: '$output5'"
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
