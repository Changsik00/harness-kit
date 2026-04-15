#!/usr/bin/env bash
set -euo pipefail

# test-cleanup.sh
# spec-9-007: cleanup.sh — versioned migration runner 검증
#
# 검증 항목:
#   1) 범위 내 migration 실행: --from 0.3.0 --to 0.4.0 → 0.4.0.sh 의 파일 삭제
#   2) 범위 외 migration skip: --from 0.4.0 --to 0.5.0 → 아무것도 삭제 안 함
#   3) 동일 버전 (빈 범위): --from 0.4.0 --to 0.4.0 → 아무것도 안 함, exit 0
#   4) 존재하지 않는 파일 skip: migration 목록에 없는 파일 → 오류 없이 exit 0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLEANUP="$ROOT/cleanup.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Cleanup Migration Runner (spec-9-007)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# 전제조건: cleanup.sh 존재 확인
# ──────────────────────────────────────────────
if [ ! -f "$CLEANUP" ]; then
  echo "  ❌ cleanup.sh not found at $CLEANUP"
  echo ""
  echo "═══════════════════════════════════════════"
  echo " ❌ 1/1 CHECKS FAILED (missing cleanup.sh)"
  echo "═══════════════════════════════════════════"
  exit 1
fi

# ──────────────────────────────────────────────
# 시나리오 1: 범위 내 migration 실행
# --from 0.3.0 --to 0.4.0 → 0.4.0.sh 의 파일들이 삭제되어야 함
# ──────────────────────────────────────────────
echo "▶ 시나리오 1: 범위 내 migration (0.3.0 → 0.4.0)"

FIXTURE1="$(mktemp -d)"
trap 'rm -rf "$FIXTURE1"' EXIT

# 0.4.0.sh 가 삭제 대상으로 나열하는 파일들 중 일부 생성
mkdir -p "$FIXTURE1/.claude/commands"
touch "$FIXTURE1/.claude/commands/hk-spec-review.md"
touch "$FIXTURE1/.claude/commands/align.md"
touch "$FIXTURE1/.claude/commands/spec-new.md"
# 나머지는 생성하지 않아도 됨 (존재하지 않는 파일 skip 검증)

bash "$CLEANUP" --from 0.3.0 --to 0.4.0 --yes "$FIXTURE1" > /dev/null 2>&1

check
if [ ! -f "$FIXTURE1/.claude/commands/hk-spec-review.md" ]; then
  pass "hk-spec-review.md 삭제됨"
else
  fail "hk-spec-review.md 삭제 안 됨"
fi

check
if [ ! -f "$FIXTURE1/.claude/commands/align.md" ]; then
  pass "align.md 삭제됨"
else
  fail "align.md 삭제 안 됨"
fi

check
if [ ! -f "$FIXTURE1/.claude/commands/spec-new.md" ]; then
  pass "spec-new.md 삭제됨"
else
  fail "spec-new.md 삭제 안 됨"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 2: 범위 외 migration skip
# --from 0.4.0 --to 0.5.0 → 0.5.0.sh 없고, 0.4.0 은 0.4.0 이하이므로 skip
# ──────────────────────────────────────────────
echo "▶ 시나리오 2: 범위 외 migration skip (0.4.0 → 0.5.0)"

FIXTURE2="$(mktemp -d)"
trap 'rm -rf "$FIXTURE1" "$FIXTURE2"' EXIT

mkdir -p "$FIXTURE2/.claude/commands"
touch "$FIXTURE2/.claude/commands/hk-spec-review.md"
touch "$FIXTURE2/.claude/commands/align.md"

bash "$CLEANUP" --from 0.4.0 --to 0.5.0 --yes "$FIXTURE2" > /dev/null 2>&1

check
if [ -f "$FIXTURE2/.claude/commands/hk-spec-review.md" ]; then
  pass "hk-spec-review.md 유지됨 (범위 외이므로 삭제 안 함)"
else
  fail "hk-spec-review.md 가 삭제됨 (범위 외인데 삭제하면 안 됨)"
fi

check
if [ -f "$FIXTURE2/.claude/commands/align.md" ]; then
  pass "align.md 유지됨 (범위 외이므로 삭제 안 함)"
else
  fail "align.md 가 삭제됨 (범위 외인데 삭제하면 안 됨)"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 3: 동일 버전 (빈 범위)
# --from 0.4.0 --to 0.4.0 → 아무것도 안 함, exit 0
# ──────────────────────────────────────────────
echo "▶ 시나리오 3: 동일 버전 빈 범위 (0.4.0 → 0.4.0)"

FIXTURE3="$(mktemp -d)"
trap 'rm -rf "$FIXTURE1" "$FIXTURE2" "$FIXTURE3"' EXIT

mkdir -p "$FIXTURE3/.claude/commands"
touch "$FIXTURE3/.claude/commands/align.md"

exit_code=0
bash "$CLEANUP" --from 0.4.0 --to 0.4.0 --yes "$FIXTURE3" > /dev/null 2>&1 || exit_code=$?

check
if [ "$exit_code" -eq 0 ]; then
  pass "exit 0 (정상 종료)"
else
  fail "exit $exit_code (비정상 종료)"
fi

check
if [ -f "$FIXTURE3/.claude/commands/align.md" ]; then
  pass "align.md 유지됨 (빈 범위이므로 삭제 안 함)"
else
  fail "align.md 가 삭제됨 (빈 범위인데 삭제하면 안 됨)"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 4: 존재하지 않는 파일 skip
# migration 목록의 파일이 실제로 없어도 오류 없이 exit 0
# ──────────────────────────────────────────────
echo "▶ 시나리오 4: 존재하지 않는 파일 skip (오류 없이 진행)"

FIXTURE4="$(mktemp -d)"
trap 'rm -rf "$FIXTURE1" "$FIXTURE2" "$FIXTURE3" "$FIXTURE4"' EXIT

# .claude/commands/ 디렉토리 자체도 없는 상태
# 0.4.0.sh 에 나열된 파일이 하나도 없음

exit_code=0
bash "$CLEANUP" --from 0.3.0 --to 0.4.0 --yes "$FIXTURE4" > /dev/null 2>&1 || exit_code=$?

check
if [ "$exit_code" -eq 0 ]; then
  pass "exit 0 (파일 없어도 오류 없음)"
else
  fail "exit $exit_code (존재하지 않는 파일로 인해 오류 발생)"
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
