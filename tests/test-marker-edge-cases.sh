#!/usr/bin/env bash
set -euo pipefail

# test-marker-edge-cases.sh
# spec-14-05: phase-14 회고에서 발견된 marker 헬퍼 엣지 케이스
#
# A: 다중 마커 쌍에서 sdd_marker_append 멱등 (M1)
# B: 마커 부재 파일 호출 시 stderr + rc=1 (M2)
# C: sdd_marker_grep 정확 토큰 매칭 (m1)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMON_SH="$ROOT/sources/bin/lib/common.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

count_line() {
  awk -v target="$1" 'BEGIN { c=0 } $0 == target { c++ } END { print c }' "$2"
}

count_in_section() {
  # marker(name) 영역 내부에서 정확 매치 라인 카운트
  local file="$1" name="$2" target="$3"
  awk -v s="<!-- sdd:${name}:start -->" -v e="<!-- sdd:${name}:end -->" -v t="$target" '
    BEGIN { in_s=0; c=0 }
    $0 == s { in_s=1; next }
    $0 == e { in_s=0; next }
    in_s && $0 == t { c++ }
    END { print c }
  ' "$file"
}

# 의존: die 가 common.sh 안에서 호출됨 (소싱 시 정의 필요)
die() { echo "ERR: $*" >&2; return 1; }
warn() { echo "WARN: $*" >&2; }
# shellcheck source=/dev/null
source "$COMMON_SH"

echo "═══════════════════════════════════════════"
echo " marker edge cases (spec-14-05)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# A: 다중 마커 쌍에서 멱등
# ─────────────────────────────────────────────────────────

echo "▶ A: 다중 마커 쌍 (test:start ~ end 2 쌍)"

A_DIR="$(mktemp -d)"
trap 'rm -rf "$A_DIR"' EXIT

cat > "$A_DIR/multi.md" <<'EOF'
# Test
<!-- sdd:test:start -->
existing-line
<!-- sdd:test:end -->

text in between

<!-- sdd:test:start -->
<!-- sdd:test:end -->
EOF

# A-1: 같은 라인을 두 번 호출 — 각 영역마다 1줄씩 (총 2줄)
sdd_marker_append "$A_DIR/multi.md" "test" "duplicate-line" >/dev/null 2>&1 || true
sdd_marker_append "$A_DIR/multi.md" "test" "duplicate-line" >/dev/null 2>&1 || true
A1_TOTAL=$(count_line "duplicate-line" "$A_DIR/multi.md")
A1_TOTAL=$(echo "$A1_TOTAL" | tr -d '[:space:]')

check
# 의도: 2 영역 × 1줄 = 2 (영역마다 1번씩). 멱등 가드가 다중 쌍을 인식해야 함.
if [ "$A1_TOTAL" = "2" ]; then
  pass "A-1: 다중 마커 쌍 + 같은 라인 두 번 → 각 영역 1줄 (총 ${A1_TOTAL})"
else
  fail "A-1: 다중 마커 쌍 + 같은 라인 두 번 → 총 ${A1_TOTAL}줄 (expected 2)"
fi

# A-2: 다른 라인 — 정상 동작 회귀 점검
sdd_marker_append "$A_DIR/multi.md" "test" "another-line" >/dev/null 2>&1 || true
A2_DUP=$(count_line "duplicate-line" "$A_DIR/multi.md" | tr -d '[:space:]')
A2_NEW=$(count_line "another-line"   "$A_DIR/multi.md" | tr -d '[:space:]')

check
if [ "$A2_DUP" = "2" ] && [ "$A2_NEW" = "2" ]; then
  pass "A-2: 다른 라인 추가 — 각 영역 1줄씩 (회귀)"
else
  fail "A-2: dup=${A2_DUP} new=${A2_NEW} (expected 2, 2)"
fi

# A-3: 첫 영역에만 라인 있고 둘째 비어있을 때 같은 라인 호출
# → 둘째 영역에도 추가되어야 함 (각 영역마다 1줄 = 멱등성의 본질)
# 현재 awk 는 found 가 reset 안 되어 둘째 영역에 추가 안 됨 (회고 M1 의 정확한 케이스)
cat > "$A_DIR/asymmetric.md" <<'EOF'
# Test
<!-- sdd:test:start -->
target-line
<!-- sdd:test:end -->

<!-- sdd:test:start -->
<!-- sdd:test:end -->
EOF

sdd_marker_append "$A_DIR/asymmetric.md" "test" "target-line" >/dev/null 2>&1 || true
A3_FIRST=$(count_in_section "$A_DIR/asymmetric.md" "test" "target-line" | tr -d '[:space:]')
# 둘째 영역만 카운트 — 단순화: total - first_section_count
A3_TOTAL=$(count_line "target-line" "$A_DIR/asymmetric.md" | tr -d '[:space:]')

check
# Expected: 두 영역 각각 1줄 = total 2 (아니, count_in_section 이 모든 영역 합계라 ≥2)
# 본 awk 의 count_in_section 은 모든 in_section 영역의 합 → 2 가 expected
if [ "$A3_TOTAL" = "2" ]; then
  pass "A-3: 첫 영역만 라인 있을 때 둘째 영역에도 추가 (각 영역 1줄)"
else
  fail "A-3: 비대칭 영역 — total=${A3_TOTAL}줄 (expected 2 — 둘째 영역 누락)"
fi

echo ""

# ─────────────────────────────────────────────────────────
# B: 마커 부재 파일 호출 시 stderr + rc=1
# ─────────────────────────────────────────────────────────

echo "▶ B: 마커 부재 파일 호출"

B_DIR="$(mktemp -d)"
trap 'rm -rf "$A_DIR" "$B_DIR"' EXIT

cat > "$B_DIR/no-markers.md" <<'EOF'
# 마커 없는 파일

본문 내용만 있음.
EOF

set +e
B_STDERR=$(sdd_marker_append "$B_DIR/no-markers.md" "test" "should-not-be-added" 2>&1 1>/dev/null)
B_RC=$?
set -e

check
if [ "$B_RC" -eq 1 ]; then
  pass "B-1: 마커 부재 파일 호출 → rc=1"
else
  fail "B-1: 마커 부재 파일 호출 → rc=${B_RC} (expected 1)"
fi

check
B_LINE_COUNT=$(count_line "should-not-be-added" "$B_DIR/no-markers.md" | tr -d '[:space:]')
if [ "$B_LINE_COUNT" = "0" ]; then
  pass "B-2: 마커 부재 파일에 line 미추가"
else
  fail "B-2: 마커 부재 파일에 line ${B_LINE_COUNT} 줄 추가됨"
fi

check
if echo "$B_STDERR" | grep -qiE "마커|marker" ; then
  pass "B-3: stderr 에 마커 부재 메시지"
else
  fail "B-3: stderr 메시지 없음 또는 부적절: $B_STDERR"
fi

echo ""

# ─────────────────────────────────────────────────────────
# C: sdd_marker_grep 정확 토큰 매칭
# ─────────────────────────────────────────────────────────

echo "▶ C: sdd_marker_grep 정확 토큰 매칭"

C_DIR="$(mktemp -d)"
trap 'rm -rf "$A_DIR" "$B_DIR" "$C_DIR"' EXIT

# 마커 안에 spec-14-011 만 있고, 본문에 spec-14-01 텍스트가 있는 케이스
cat > "$C_DIR/phase.md" <<'EOF'
# phase-14

본문 — `spec-14-01` 이라는 텍스트가 있음.

<!-- sdd:specs:start -->
| `spec-14-011` | longer-id | P1 | Active | `specs/spec-14-011-longer-id/` |
<!-- sdd:specs:end -->
EOF

# C-1: 백틱 포함 needle "`spec-14-01`" → 마커 안엔 `spec-14-011` 만 → false
set +e
sdd_marker_grep "$C_DIR/phase.md" "specs" "\`spec-14-01\`"
C1_RC=$?
set -e

check
if [ "$C1_RC" -eq 1 ]; then
  pass "C-1: needle '\`spec-14-01\`' (백틱 포함) → 부분 일치 회피, false (rc=1)"
else
  fail "C-1: 부분 일치 발생 — rc=${C1_RC} (expected 1, false positive)"
fi

# C-2: needle "`spec-14-011`" → 마커 안 매치 → true
set +e
sdd_marker_grep "$C_DIR/phase.md" "specs" "\`spec-14-011\`"
C2_RC=$?
set -e

check
if [ "$C2_RC" -eq 0 ]; then
  pass "C-2: needle '\`spec-14-011\`' → 정확 매치, true (rc=0)"
else
  fail "C-2: 정확 매치 안됨 — rc=${C2_RC} (expected 0)"
fi

echo ""
echo "═══════════════════════════════════════════"
if [ "$FAIL" -eq 0 ]; then
  echo " ✅ ALL ${TOTAL} CHECKS PASSED"
else
  echo " ❌ FAIL: ${FAIL}/${TOTAL}"
  exit 1
fi
