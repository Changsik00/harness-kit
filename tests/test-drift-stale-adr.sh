#!/usr/bin/env bash
# tests/test-drift-stale-adr.sh
#
# Verifies _drift_stale_adr() in sources/bin/sdd:
#   1. Clean state (no fixture ADR) → no "stale ADR" line in drift section
#   2. Fixture ADR with missing path → "stale ADR: 1 (missing-path)" line
#   3. ADR-001 regression: clean state after fixture removal still PASS
#
# bash 3.2+ compatible.

set -euo pipefail

SDD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SDD_ROOT"

SDD_BIN=".harness-kit/bin/sdd"
FIXTURE="docs/decisions/ADR-999-stale-fixture.md"

# Ensure clean state on exit (even on test failure)
cleanup() { rm -f "$FIXTURE"; }
trap cleanup EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

echo "Test: _drift_stale_adr()"

# ─── Step 1: clean state ─────────────────────────────────────────
cleanup
output=$(HARNESS_DRIFT_FETCH=0 bash "$SDD_BIN" status 2>&1 || true)
if echo "$output" | grep -q "stale ADR"; then
  fail "clean state should not report stale ADR" "$output"
fi
pass "clean state: no stale ADR line"

# ─── Step 2: fixture with missing path ───────────────────────────
mkdir -p docs/decisions
cat > "$FIXTURE" <<'EOF'
---
id: ADR-999
type: decision
date: 2026-05-16
status: accepted
---
# ADR-999: Fixture for stale detection

## Context
Existing path: `sources/bin/sdd`
Missing path: `src/removed-module-fixture-spec-16-03.ts`

## Decision
This ADR exists only for the stale-detection unit test.
EOF

output=$(HARNESS_DRIFT_FETCH=0 bash "$SDD_BIN" status 2>&1 || true)
if ! echo "$output" | grep -q "stale ADR: 1 (missing-path)"; then
  fail "fixture should produce 'stale ADR: 1 (missing-path)' line" "$output"
fi
pass "fixture ADR (1 missing path) → stale ADR: 1 detected"

# ─── Step 3: regression after fixture removal ────────────────────
cleanup
output=$(HARNESS_DRIFT_FETCH=0 bash "$SDD_BIN" status 2>&1 || true)
if echo "$output" | grep -q "stale ADR"; then
  fail "ADR-001 regression — existing ADR paths should all be valid" "$output"
fi
pass "regression: ADR-001 paths all valid"

echo ""
echo "All tests passed."
