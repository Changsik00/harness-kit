#!/usr/bin/env bash
# tests/test-doctor-docs-integrity.sh
#
# Verifies `sdd doctor` "docs 무결성" section (spec-27-02):
#   1. Duplicate ADR id → FAIL, id mentioned
#   2. ADR missing frontmatter (`---` not first line) → FAIL, file mentioned
#   3. ADR index drift (new ADR not yet indexed) → WARN
#   4. Completed phase still present under backlog/ → WARN, phase id mentioned
#   5. Clean state (no fixtures) → no FAIL for ADR checks
#
# bash 3.2+ compatible.

set -euo pipefail

SDD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SDD_ROOT"

SDD_BIN=".harness-kit/bin/sdd"
README="docs/decisions/README.md"
README_BACKUP=""
DUP_A="docs/decisions/ADR-993-dup-a.md"
DUP_B="docs/decisions/ADR-994-dup-b.md"
NO_FM="docs/decisions/ADR-992-no-frontmatter.md"
QUEUE="backlog/queue.md"
QUEUE_BACKUP="$(mktemp)"
RESIDUE_FIXTURE="backlog/phase-994.md"

had_readme=0
if [ -f "$README" ]; then
  had_readme=1
  README_BACKUP="$(mktemp)"
  cp "$README" "$README_BACKUP"
fi
cp "$QUEUE" "$QUEUE_BACKUP"

cleanup() {
  rm -f "$DUP_A" "$DUP_B" "$NO_FM" "$RESIDUE_FIXTURE"
  cp "$QUEUE_BACKUP" "$QUEUE"
  rm -f "$QUEUE_BACKUP"
  if [ "$had_readme" -eq 1 ]; then
    cp "$README_BACKUP" "$README"
    rm -f "$README_BACKUP"
  else
    rm -f "$README"
  fi
}
trap cleanup EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

echo "Test: sdd doctor docs-integrity"

# ─── Step 1: clean state → no ADR FAIL ─────────────────────────────
output=$(bash "$SDD_BIN" doctor 2>&1 || true)
if ! echo "$output" | grep -q "docs 무결성"; then
  fail "doctor should print 'docs 무결성' section" "$output"
fi
if echo "$output" | grep -qE "❌ ADR (id 중복|frontmatter 없음)"; then
  fail "clean state should not report ADR FAIL" "$output"
fi
pass "clean state: docs 무결성 section present, no ADR FAIL"

# ─── Step 2: duplicate ADR id → FAIL ───────────────────────────────
cat > "$DUP_A" <<'EOF'
---
id: ADR-990
type: decision
date: 2026-07-03
status: accepted
---

# ADR-990: Duplicate Fixture A
EOF
cat > "$DUP_B" <<'EOF'
---
id: ADR-990
type: decision
date: 2026-07-03
status: accepted
---

# ADR-990: Duplicate Fixture B
EOF

output=$(bash "$SDD_BIN" doctor 2>&1 || true)
rm -f "$DUP_A" "$DUP_B"
if ! echo "$output" | grep -q "ADR-990" || ! echo "$output" | grep -qE "❌.*ADR id 중복"; then
  fail "duplicate ADR id should be reported as FAIL" "$output"
fi
pass "duplicate ADR id → FAIL detected"

# ─── Step 3: ADR without frontmatter → FAIL ────────────────────────
cat > "$NO_FM" <<'EOF'
# ADR-992: No Frontmatter Fixture

This ADR intentionally lacks a leading frontmatter block.
EOF

output=$(bash "$SDD_BIN" doctor 2>&1 || true)
rm -f "$NO_FM"
if ! echo "$output" | grep -qE "❌.*ADR frontmatter 없음"; then
  fail "ADR missing frontmatter should be reported as FAIL" "$output"
fi
pass "ADR missing frontmatter → FAIL detected"

# ─── Step 4: ADR index drift (new ADR, index not regenerated) ─────
bash "$SDD_BIN" adr-index >/dev/null 2>&1  # sync first, so only the new ADR causes drift
cat > "$DUP_A" <<'EOF'
---
id: ADR-991
type: decision
date: 2026-07-03
status: accepted
---

# ADR-991: Drift Fixture
EOF

output=$(bash "$SDD_BIN" doctor 2>&1 || true)
rm -f "$DUP_A"
if ! echo "$output" | grep -qE "⚠️.*ADR 인덱스 drift"; then
  fail "unindexed new ADR should be reported as index drift WARN" "$output"
fi
pass "ADR index drift → WARN detected"

# ─── Step 5: completed phase residue under backlog/ → WARN ────────
cat > "$RESIDUE_FIXTURE" <<'EOF'
# phase-994: Residue Fixture
EOF
# insert into queue.md's done marker block
awk '
  /<!-- sdd:done:end -->/ { print "- **phase-994** — 잔존 픽스처 — completed 2026-07-03" }
  { print }
' "$QUEUE_BACKUP" > "$QUEUE"

output=$(bash "$SDD_BIN" doctor 2>&1 || true)
cp "$QUEUE_BACKUP" "$QUEUE"
rm -f "$RESIDUE_FIXTURE"
if ! echo "$output" | grep -q "phase-994" || ! echo "$output" | grep -qE "⚠️.*잔존"; then
  fail "completed phase-994 residue should be reported as WARN" "$output"
fi
pass "completed phase residue → WARN detected"

echo ""
echo "All tests passed."
