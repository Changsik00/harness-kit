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
VALID_FIXTURE="docs/decisions/ADR-998-valid-paths-fixture.md"
GLOB_FIXTURE="docs/decisions/ADR-997-glob-fixture.md"

# Ensure clean state on exit (even on test failure)
cleanup() { rm -f "$FIXTURE"; }
cleanup_valid() { rm -f "$VALID_FIXTURE"; }
cleanup_glob() { rm -f "$GLOB_FIXTURE"; }
trap 'cleanup; cleanup_valid; cleanup_glob' EXIT

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

# ─── Step 3: regression with self-contained valid-paths fixture ──
# Self-contained: a fixture ADR whose backtick paths all exist → no stale line.
# Does NOT depend on ADR-001 body (W3 — spec-17-04).
cleanup
cat > "$VALID_FIXTURE" <<'EOF'
---
id: ADR-998
type: decision
date: 2026-05-17
status: accepted
---
# ADR-998: Fixture for regression — all paths valid

## Context
Existing paths only: `sources/bin/sdd`, `README.md`, `version.json`.

## Decision
This ADR exists only for the regression test (Step 3) — all backtick paths MUST exist.
EOF

output=$(HARNESS_DRIFT_FETCH=0 bash "$SDD_BIN" status 2>&1 || true)
cleanup_valid
if echo "$output" | grep -q "stale ADR"; then
  fail "regression: fixture with all-valid paths should produce no stale line" "$output"
fi
pass "regression: ADR-998 (all-valid-paths fixture) → no stale line"

# ─── Step 4: glob patterns must not be treated as missing files ───
# Illustrative glob tokens in ADR prose (e.g. `docs/wiki/*.md`) are patterns,
# not literal files — they must NOT trip the stale detector.
cat > "$GLOB_FIXTURE" <<'EOF'
---
id: ADR-997
type: convention
date: 2026-06-14
status: accepted
---
# ADR-997: Fixture for glob false-positive regression

## Context
These are glob patterns, not literal files: `docs/wiki/*.md`, `docs/decisions/ADR-*.md`, `docs/rca/RCA-*.md`.

## Decision
This ADR exists only for the glob-exclusion unit test — no stale line expected.
EOF

output=$(HARNESS_DRIFT_FETCH=0 bash "$SDD_BIN" status 2>&1 || true)
cleanup_glob
if echo "$output" | grep -q "stale ADR"; then
  fail "glob patterns should not be reported as stale" "$output"
fi
pass "glob fixture: ADR-997 (glob-only paths) → no stale line"

echo ""
echo "All tests passed."
