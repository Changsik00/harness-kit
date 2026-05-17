#!/usr/bin/env bash
# tests/test-sdd-marker-idempotent.sh
#
# Verifies marker manipulation idempotency in sources/bin/sdd:
#   1. cmd_spec_new — Backlog 행 존재 시 in-place update (append 아님)
#   2. cmd_spec_new — 결과 행이 Active 상태
#   3. queue_mark_done — phase_id normalize ('phase done 99' → '**phase-99**')
#
# bash 3.2+ 호환. fixture 격리 — trap cleanup.

set -euo pipefail

SDD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SDD_ROOT"
SDD_BIN="$SDD_ROOT/.harness-kit/bin/sdd"
STATE_JSON="$SDD_ROOT/.claude/state/current.json"

FIXTURE_PHASE_FILE="backlog/phase-99.md"
FIXTURE_SPEC_DIR=""  # captured during test, cleaned at exit

# state backup (restore on exit)
STATE_BACKUP=""
if [ -f "$STATE_JSON" ]; then
  STATE_BACKUP="$(cat "$STATE_JSON")"
fi

cleanup() {
  rm -f "$FIXTURE_PHASE_FILE"
  [ -n "$FIXTURE_SPEC_DIR" ] && [ -d "$FIXTURE_SPEC_DIR" ] && rm -rf "$FIXTURE_SPEC_DIR"
  # queue.md 의 fixture done entry 제거
  if [ -f backlog/queue.md ] && grep -q "phase-99" backlog/queue.md; then
    grep -v "phase-99" backlog/queue.md > backlog/queue.md.tmp && \
      mv backlog/queue.md.tmp backlog/queue.md
  fi
  # state restore
  if [ -n "$STATE_BACKUP" ]; then
    echo "$STATE_BACKUP" > "$STATE_JSON"
  fi
}
trap cleanup EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    detail: $2"; exit 1; }

echo "Test: sdd marker idempotency"

# ─── Setup ────────────────────────────────────────────────────────
cat > "$FIXTURE_PHASE_FILE" <<'EOF'
# phase-99: Marker Test Fixture

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | `phase-99` |
| **Base Branch** | 없음 |

## 🧩 작업 단위 (SPECs)

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-99-01 | marker-test | P0 | Backlog | (미생성) |
<!-- sdd:specs:end -->
EOF

# state switch to fixture phase
jq '.phase = "phase-99" | .spec = null | .planAccepted = false | .baseBranch = null' \
  "$STATE_JSON" > "$STATE_JSON.tmp" && mv "$STATE_JSON.tmp" "$STATE_JSON"

# ─── Test 1 + 2: spec new on existing Backlog → in-place update + Active ─
"$SDD_BIN" spec new marker-test >/dev/null 2>&1 || true

# capture spec dir for cleanup
FIXTURE_SPEC_DIR="$(ls -d specs/spec-99-01-* 2>/dev/null | head -1 || echo "")"

row_count=$(grep -cE '^\| .?spec-99-01' "$FIXTURE_PHASE_FILE" || echo "0")
if [ "$row_count" -ne 1 ]; then
  fail "spec new on Backlog row should update in-place (rows expected: 1, got: $row_count)" \
    "$(grep -E '^\| .?spec-99-01' "$FIXTURE_PHASE_FILE")"
fi
pass "Test 1 — spec new: in-place update of Backlog row (no append)"

if ! grep -qE 'spec-99-01.*Active' "$FIXTURE_PHASE_FILE"; then
  fail "spec-99-01 should be Active after spec new" \
    "$(grep spec-99-01 "$FIXTURE_PHASE_FILE")"
fi
pass "Test 2 — spec new: row status = Active"

# ─── Test 3: phase done normalize ─────────────────────────────────
# state.json phase 는 phase-99 — 'sdd phase done 99' 호출 (prefix 없이)
"$SDD_BIN" phase done 99 >/dev/null 2>&1 || true

if grep -qE "^- \*\*99\*\* " backlog/queue.md; then
  fail "phase done should produce '**phase-99**', not '**99**'" \
    "$(grep -E '\*\*(99|phase-99)\*\*' backlog/queue.md)"
fi
if ! grep -qE "^- \*\*phase-99\*\* " backlog/queue.md; then
  fail "phase done should produce '**phase-99**' entry" \
    "$(tail -5 backlog/queue.md)"
fi
pass "Test 3 — phase done: normalize 'phase done 99' → '**phase-99** — title'"

echo ""
echo "All tests passed."
