#!/usr/bin/env bash
# tests/test-status-backlog-residue.sh
#
# Verifies `sdd status` 🔍 진단 section surfaces completed-phase backlog
# residue (spec-27-03, reusing _backlog_completed_residue from spec-27-02):
#   1. Fixture completed phase with a lingering backlog/phase-NN.md → mentioned
#   2. After fixture removal, that phase id no longer appears
#
# bash 3.2+ compatible.

set -euo pipefail

SDD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SDD_ROOT"

SDD_BIN=".harness-kit/bin/sdd"
QUEUE="backlog/queue.md"
QUEUE_BACKUP="$(mktemp)"
RESIDUE_FIXTURE="backlog/phase-994.md"

cp "$QUEUE" "$QUEUE_BACKUP"

cleanup() {
  cp "$QUEUE_BACKUP" "$QUEUE"
  rm -f "$QUEUE_BACKUP" "$RESIDUE_FIXTURE"
}
trap cleanup EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

echo "Test: sdd status backlog residue diagnosis"

# ─── Step 1: fixture completed phase + lingering backlog file ─────
cat > "$RESIDUE_FIXTURE" <<'EOF'
# phase-994: Residue Fixture
EOF
awk '
  /<!-- sdd:done:end -->/ { print "- **phase-994** — 잔존 픽스처 — completed 2026-07-04" }
  { print }
' "$QUEUE_BACKUP" > "$QUEUE"

output=$(HARNESS_DRIFT_FETCH=0 bash "$SDD_BIN" status 2>&1 || true)
if ! echo "$output" | grep -q "phase-994" || ! echo "$output" | grep -q "잔존"; then
  fail "completed phase-994 residue should be mentioned in status diagnosis" "$output"
fi
pass "fixture residue phase-994 surfaced in sdd status"

# ─── Step 2: remove fixture → no longer mentioned ──────────────────
cp "$QUEUE_BACKUP" "$QUEUE"
rm -f "$RESIDUE_FIXTURE"

output=$(HARNESS_DRIFT_FETCH=0 bash "$SDD_BIN" status 2>&1 || true)
if echo "$output" | grep -q "phase-994"; then
  fail "phase-994 should not appear after fixture removal" "$output"
fi
pass "fixture removed → phase-994 no longer mentioned"

echo ""
echo "All tests passed."
