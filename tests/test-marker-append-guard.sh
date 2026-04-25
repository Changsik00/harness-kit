#!/usr/bin/env bash
set -euo pipefail

# test-marker-append-guard.sh
# spec-14-04: sdd_marker_append 멱등 가드 + spec_new grep 영역 한정 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"
SDD_LIB_DIR="$ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$ROOT/sources/templates"
COMMON_SH="$SDD_LIB_DIR/common.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

count_line() {
  # 정확 매치 라인 카운트 (정규식 메타 회피 — awk index/eq)
  awk -v target="$1" 'BEGIN { c=0 } $0 == target { c++ } END { print c }' "$2"
}

setup_sdd_fixture() {
  local d="$1"
  mkdir -p "$d/.claude/state" "$d/backlog" "$d/.harness-kit/bin/lib" "$d/.harness-kit/agent/templates"
  git -C "$d" init -q
  git -C "$d" checkout -b main 2>/dev/null || true
  git -C "$d" config user.email "test@local"
  git -C "$d" config user.name "test"
  cp "$SDD" "$d/.harness-kit/bin/sdd"
  for f in "$SDD_LIB_DIR"/*.sh; do cp "$f" "$d/.harness-kit/bin/lib/$(basename "$f")"; done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do cp "$f" "$d/.harness-kit/agent/templates/$(basename "$f")"; done
  cat > "$d/.harness-kit/installed.json" <<EOF
{ "kitVersion": "test", "installedAt": "2026-04-25T00:00:00Z" }
EOF
  cat > "$d/.claude/state/current.json" <<EOF
{ "phase": null, "spec": null, "branch": null, "planAccepted": false, "lastTestPass": null }
EOF
}

echo "═══════════════════════════════════════════"
echo " marker append guard + scoped grep (spec-14-04)"
echo "═══════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# A: sdd_marker_append 단위 테스트 (lib 직접 호출)
# ─────────────────────────────────────────────────────────

echo "▶ A: sdd_marker_append 단위 테스트"

A_DIR="$(mktemp -d)"
trap 'rm -rf "$A_DIR"' EXIT

# 픽스처 마커 파일
cat > "$A_DIR/markers.md" <<'EOF'
# Test
<!-- sdd:test:start -->
<!-- sdd:test:end -->
EOF

# common.sh 소스 (의존: die 만 사용 — die 가 정의 안 되어 있으면 fallback)
# shellcheck source=/dev/null
die() { echo "ERR: $*" >&2; return 1; }
# shellcheck source=/dev/null
source "$COMMON_SH"

# A-1: 같은 라인 두 번 → 1줄
check
sdd_marker_append "$A_DIR/markers.md" "test" "duplicate-line"
sdd_marker_append "$A_DIR/markers.md" "test" "duplicate-line"
A1_COUNT=$(count_line "duplicate-line" "$A_DIR/markers.md")
A1_COUNT=$(echo "$A1_COUNT" | tr -d '[:space:]')
if [ "$A1_COUNT" = "1" ]; then
  pass "A-1: 같은 라인 두 번 호출 → 1줄"
else
  fail "A-1: 같은 라인 두 번 호출 → ${A1_COUNT}줄 (expected 1)"
fi

# A-2: 다른 라인 두 번 → 두 라인 모두
check
sdd_marker_append "$A_DIR/markers.md" "test" "another-line"
A2_COUNT_ANOTHER=$(count_line "another-line" "$A_DIR/markers.md" | tr -d '[:space:]')
A2_COUNT_DUP=$(count_line "duplicate-line" "$A_DIR/markers.md" | tr -d '[:space:]')
if [ "$A2_COUNT_ANOTHER" = "1" ] && [ "$A2_COUNT_DUP" = "1" ]; then
  pass "A-2: 다른 라인 추가 — 둘 다 보존 (정상 동작 회귀)"
else
  fail "A-2: 다른 라인 추가 후 duplicate-line=$A2_COUNT_DUP another-line=$A2_COUNT_ANOTHER (expected 1, 1)"
fi

echo ""

# ─────────────────────────────────────────────────────────
# B: sdd specx done 두 번 → done 섹션 1줄
# ─────────────────────────────────────────────────────────

echo "▶ B: sdd specx done 두 번"

B_DIR="$(mktemp -d)"
trap 'rm -rf "$A_DIR" "$B_DIR"' EXIT
setup_sdd_fixture "$B_DIR"

# queue.md 픽스처 (specx 섹션에 등록 + done 섹션 비움)
cat > "$B_DIR/backlog/queue.md" <<'EOF'
# Backlog Queue

## 📦 진행 중 Phase
<!-- sdd:active:start -->
없음
<!-- sdd:active:end -->

## 📥 spec-x 대기
<!-- sdd:specx:start -->
- [ ] spec-x-test-slug — test-slug
<!-- sdd:specx:end -->

## 🧊 Icebox

## ✅ 완료
<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
EOF

# spec-x 디렉토리 (phase.md SPEC 표 update_row 가 phase.md 부재면 어떻게? — specx 는 phase 와 무관)
mkdir -p "$B_DIR/specs/spec-x-test-slug"

SDD_CMD="bash $B_DIR/.harness-kit/bin/sdd"

# specx done 두 번
(cd "$B_DIR" && $SDD_CMD specx done test-slug > /dev/null 2>&1 || true)
(cd "$B_DIR" && $SDD_CMD specx done test-slug > /dev/null 2>&1 || true)

check
B_COUNT=$(count_line "- [x] spec-x-test-slug (완료)" "$B_DIR/backlog/queue.md" | tr -d '[:space:]')
if [ "$B_COUNT" = "1" ]; then
  pass "B: sdd specx done 두 번 → done 섹션 1줄"
else
  fail "B: sdd specx done 두 번 → ${B_COUNT}줄 (expected 1)"
  echo "    done 영역:"
  awk '/sdd:done:start/,/sdd:done:end/' "$B_DIR/backlog/queue.md" | sed 's/^/      /'
fi

echo ""

# ─────────────────────────────────────────────────────────
# C: sdd phase done 두 번 → done 섹션 1줄
# ─────────────────────────────────────────────────────────

echo "▶ C: sdd phase done 두 번"

C_DIR="$(mktemp -d)"
trap 'rm -rf "$A_DIR" "$B_DIR" "$C_DIR"' EXIT
setup_sdd_fixture "$C_DIR"

cat > "$C_DIR/backlog/queue.md" <<'EOF'
# Backlog Queue

## 📦 진행 중 Phase
<!-- sdd:active:start -->
없음
<!-- sdd:active:end -->

## 📥 spec-x 대기
<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

## ✅ 완료
<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
EOF

# phase 생성 후 done 두 번
SDD_CMD_C="bash $C_DIR/.harness-kit/bin/sdd"
(cd "$C_DIR" && $SDD_CMD_C phase new my-phase > /dev/null 2>&1 || true)
(cd "$C_DIR" && $SDD_CMD_C phase done > /dev/null 2>&1 || true)
(cd "$C_DIR" && $SDD_CMD_C phase done phase-01 > /dev/null 2>&1 || true)

check
C_COUNT=$(grep -c '^- \*\*phase-01\*\*' "$C_DIR/backlog/queue.md" 2>/dev/null || true)
C_COUNT=$(echo "$C_COUNT" | tr -d '[:space:]')
if [ "$C_COUNT" = "1" ]; then
  pass "C: sdd phase done 두 번 → done 섹션 1줄"
else
  fail "C: sdd phase done 두 번 → ${C_COUNT}줄 (expected 1)"
  echo "    done 영역:"
  awk '/sdd:done:start/,/sdd:done:end/' "$C_DIR/backlog/queue.md" | sed 's/^/      /'
fi

echo ""

# ─────────────────────────────────────────────────────────
# D: phase-N.md 본문에 spec-N-NN 텍스트 + sdd spec new → 마커 안 행 1줄
# ─────────────────────────────────────────────────────────

echo "▶ D: phase 본문 텍스트 매치 회피 + spec_new 마커 추가"

D_DIR="$(mktemp -d)"
trap 'rm -rf "$A_DIR" "$B_DIR" "$C_DIR" "$D_DIR"' EXIT
setup_sdd_fixture "$D_DIR"

cat > "$D_DIR/backlog/queue.md" <<'EOF'
# Backlog Queue

## 📦 진행 중 Phase
<!-- sdd:active:start -->
- **phase-01** — 테스트 — 0 spec
<!-- sdd:active:end -->

## 📥 spec-x 대기
<!-- sdd:specx:start -->
없음
<!-- sdd:specx:end -->

## 🧊 Icebox

## ✅ 완료
<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
EOF

# phase-01.md 의 본문에 "spec-01-01" 이라는 텍스트가 있는 상태 (회귀 케이스)
cat > "$D_DIR/backlog/phase-01.md" <<'EOF'
# phase-01: 테스트

## 🧩 작업 단위

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->

### spec-01-01 — my-slug

본문 설명 — spec-01-01 텍스트가 마커 외부에 등장.
EOF

# state 의 active phase 설정
cat > "$D_DIR/.claude/state/current.json" <<'EOF'
{ "phase": "phase-01", "spec": null, "branch": null, "planAccepted": false, "lastTestPass": null }
EOF

# spec new
SDD_CMD_D="bash $D_DIR/.harness-kit/bin/sdd"
(cd "$D_DIR" && $SDD_CMD_D spec new my-slug > /dev/null 2>&1 || true)

# 마커 안에 spec-01-01 행이 정확히 1줄
check
D_IN_MARKER=$(awk '/sdd:specs:start/,/sdd:specs:end/' "$D_DIR/backlog/phase-01.md" | grep -cE '^\| `?spec-01-01`?' 2>/dev/null || true)
D_IN_MARKER=$(echo "$D_IN_MARKER" | tr -d '[:space:]')
if [ "$D_IN_MARKER" = "1" ]; then
  pass "D: 본문 매치 회피 — 마커 안 spec-01-01 행 정확히 1줄"
else
  fail "D: 마커 안 spec-01-01 행 = ${D_IN_MARKER}줄 (expected 1)"
  echo "    specs 마커 영역:"
  awk '/sdd:specs:start/,/sdd:specs:end/' "$D_DIR/backlog/phase-01.md" | sed 's/^/      /'
fi

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
