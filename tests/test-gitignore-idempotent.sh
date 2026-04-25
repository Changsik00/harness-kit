#!/usr/bin/env bash
set -euo pipefail

# test-gitignore-idempotent.sh
# spec-14-03: install.sh .gitignore 처리 라인별 멱등화 검증
#
# 검증 시나리오:
#   D-1~D-4: 첫 install 후 4 라인 (헤더 + 3 항목) 각각 정확히 1 회
#   D-5~D-8: 재install (동일 옵션) 후 4 라인 각각 정확히 1 회
#   E:        헤더만 수동 삭제 후 재install → 헤더 복원 + 라인 중복 없음
#   F:        사용자가 미리 .harness-kit/ 적은 후 첫 install → 그 라인 1 회 + 헤더
#   G:        .harness-backup-*/ 만 지운 후 재install → 보강 + 다른 라인 변화 없음
#   H:        --gitignore → --no-gitignore 토글 → .harness-kit/ 부재 + !.harness-kit/ 1 회

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

count_line() {
  # 정확 매치 라인 수 (매치 0 이어도 grep -c 가 "0" 출력 — || true 로 set -e 회피만)
  local pat
  pat="^$(echo "$1" | sed 's/[]\/$*.^[]/\\&/g')\$"
  grep -cE "$pat" "$2" 2>/dev/null || true
}

make_fixture() {
  local d
  d="$(mktemp -d)"
  git -C "$d" init -q
  git -C "$d" checkout -b main 2>/dev/null || true
  git -C "$d" config user.email "test@local"
  git -C "$d" config user.name "test"
  echo "$d"
}

assert_count() {
  local label="$1" line="$2" file="$3" expected="$4"
  check
  local actual; actual=$(count_line "$line" "$file")
  actual=$(echo "$actual" | tr -d '[:space:]')
  if [ "$actual" = "$expected" ]; then
    pass "$label: '$line' = ${expected}회"
  else
    fail "$label: '$line' = ${actual}회 (expected ${expected})"
  fi
}

echo "═══════════════════════════════════════════"
echo " gitignore line-level idempotency (spec-14-03)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# Scenario D-1~D-4: 첫 install 후 4 라인 각각 1 회
# ─────────────────────────────────────────────────────────

echo "▶ D-1~4: 첫 install 후 4 라인 각각 정확히 1 회"
FIX_D="$(make_fixture)"
trap 'rm -rf "$FIX_D"' EXIT
bash "$INSTALL" --yes "$FIX_D" > /dev/null 2>&1

assert_count "D-1" "# harness-kit"     "$FIX_D/.gitignore" 1
assert_count "D-2" ".harness-kit/"     "$FIX_D/.gitignore" 1
assert_count "D-3" ".harness-backup-*/" "$FIX_D/.gitignore" 1
assert_count "D-4" ".claude/state/"    "$FIX_D/.gitignore" 1

echo ""
echo "▶ D-5~8: 재install (동일 옵션) 후 4 라인 각각 정확히 1 회"
bash "$INSTALL" --yes "$FIX_D" > /dev/null 2>&1

assert_count "D-5" "# harness-kit"     "$FIX_D/.gitignore" 1
assert_count "D-6" ".harness-kit/"     "$FIX_D/.gitignore" 1
assert_count "D-7" ".harness-backup-*/" "$FIX_D/.gitignore" 1
assert_count "D-8" ".claude/state/"    "$FIX_D/.gitignore" 1

echo ""

# ─────────────────────────────────────────────────────────
# Scenario E: 헤더만 수동 삭제 후 재install
# ─────────────────────────────────────────────────────────

echo "▶ E: 헤더만 수동 삭제 후 재install — 헤더 복원, 라인 중복 없음"
FIX_E="$(make_fixture)"
trap 'rm -rf "$FIX_D" "$FIX_E"' EXIT
bash "$INSTALL" --yes "$FIX_E" > /dev/null 2>&1

# 헤더만 수동 삭제 (라인은 보존)
sed -i.tmp '/^# harness-kit$/d' "$FIX_E/.gitignore"
rm -f "$FIX_E/.gitignore.tmp"

# 재install
bash "$INSTALL" --yes "$FIX_E" > /dev/null 2>&1

assert_count "E-1" "# harness-kit"     "$FIX_E/.gitignore" 1
assert_count "E-2" ".harness-kit/"     "$FIX_E/.gitignore" 1
assert_count "E-3" ".harness-backup-*/" "$FIX_E/.gitignore" 1
assert_count "E-4" ".claude/state/"    "$FIX_E/.gitignore" 1

echo ""

# ─────────────────────────────────────────────────────────
# Scenario F: 사용자가 미리 .harness-kit/ 적은 후 첫 install
# ─────────────────────────────────────────────────────────

echo "▶ F: 사용자 사전 라인 + 첫 install — 라인 중복 없음"
FIX_F="$(make_fixture)"
trap 'rm -rf "$FIX_D" "$FIX_E" "$FIX_F"' EXIT

# 사용자가 미리 .harness-kit/ 적어둠 (헤더 없이)
echo ".harness-kit/" > "$FIX_F/.gitignore"

# 첫 install
bash "$INSTALL" --yes "$FIX_F" > /dev/null 2>&1

assert_count "F-1" "# harness-kit"     "$FIX_F/.gitignore" 1
assert_count "F-2" ".harness-kit/"     "$FIX_F/.gitignore" 1
assert_count "F-3" ".harness-backup-*/" "$FIX_F/.gitignore" 1
assert_count "F-4" ".claude/state/"    "$FIX_F/.gitignore" 1

echo ""

# ─────────────────────────────────────────────────────────
# Scenario G: 라인 일부 누락 후 재install
# ─────────────────────────────────────────────────────────

echo "▶ G: .harness-backup-*/ 만 수동 삭제 후 재install — 보강"
FIX_G="$(make_fixture)"
trap 'rm -rf "$FIX_D" "$FIX_E" "$FIX_F" "$FIX_G"' EXIT
bash "$INSTALL" --yes "$FIX_G" > /dev/null 2>&1

# .harness-backup-*/ 만 삭제
sed -i.tmp '/^\.harness-backup-\*\/$/d' "$FIX_G/.gitignore"
rm -f "$FIX_G/.gitignore.tmp"

# 재install
bash "$INSTALL" --yes "$FIX_G" > /dev/null 2>&1

assert_count "G-1" "# harness-kit"     "$FIX_G/.gitignore" 1
assert_count "G-2" ".harness-kit/"     "$FIX_G/.gitignore" 1
assert_count "G-3" ".harness-backup-*/" "$FIX_G/.gitignore" 1
assert_count "G-4" ".claude/state/"    "$FIX_G/.gitignore" 1

echo ""

# ─────────────────────────────────────────────────────────
# Scenario H: --gitignore → --no-gitignore 토글
# ─────────────────────────────────────────────────────────

echo "▶ H: --gitignore → --no-gitignore 토글"
FIX_H="$(make_fixture)"
trap 'rm -rf "$FIX_D" "$FIX_E" "$FIX_F" "$FIX_G" "$FIX_H"' EXIT
bash "$INSTALL" --yes "$FIX_H" > /dev/null 2>&1
bash "$INSTALL" --yes --no-gitignore "$FIX_H" > /dev/null 2>&1

assert_count "H-1" ".harness-kit/"   "$FIX_H/.gitignore" 0
assert_count "H-2" "!.harness-kit/"  "$FIX_H/.gitignore" 1

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
  echo " ✅ ALL ${TOTAL} CHECKS PASSED"
else
  echo " ❌ FAIL: ${FAIL}/${TOTAL}"
  exit 1
fi
