#!/usr/bin/env bash
# tests/test-adr-index.sh
#
# Verifies `sdd adr-index` (spec-27-01):
#   1. README.md missing → `adr-index --check` exits 1
#   2. `adr-index` generates docs/decisions/README.md with fixture ADR row
#   3. Re-run is idempotent (no diff)
#   4. `adr-index --check` exits 0 when in sync
#   5. Frontmatter drift (type changed, index stale) → `--check` exits 1
#   6. Regenerate → `--check` exits 0 again
#
# bash 3.2+ compatible.

set -euo pipefail

SDD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SDD_ROOT"

SDD_BIN=".harness-kit/bin/sdd"
README="docs/decisions/README.md"
README_BACKUP=""
FIXTURE="docs/decisions/ADR-995-fixture-a.md"

had_readme=0
if [ -f "$README" ]; then
  had_readme=1
  README_BACKUP="$(mktemp)"
  cp "$README" "$README_BACKUP"
fi

cleanup() {
  rm -f "$FIXTURE"
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

echo "Test: sdd adr-index"

# ─── Step 1: README missing → --check fails ──────────────────────
rm -f "$README"
set +e
bash "$SDD_BIN" adr-index --check >/tmp/adr-index-check-1.out 2>&1
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  fail "--check should fail when README.md is missing" "$(cat /tmp/adr-index-check-1.out)"
fi
pass "missing README.md → --check exits non-zero"

# ─── Step 2: generate with fixture ADR ────────────────────────────
cat > "$FIXTURE" <<'EOF'
---
id: ADR-995
type: decision
date: 2026-07-01
status: accepted
---

# ADR-995: Fixture A Title
EOF

output=$(bash "$SDD_BIN" adr-index 2>&1) || fail "adr-index should exit 0" "$output"
[ -f "$README" ] || fail "adr-index did not create $README" "$output"

if ! grep -q "ADR-995" "$README" || ! grep -q "Fixture A Title" "$README" \
   || ! grep -q "decision" "$README" || ! grep -q "2026-07-01" "$README"; then
  fail "generated README.md missing fixture row fields" "$(cat "$README")"
fi
pass "adr-index generates README.md with fixture row"

# ─── Step 3: idempotent re-run ────────────────────────────────────
before=$(cat "$README")
bash "$SDD_BIN" adr-index >/dev/null 2>&1
after=$(cat "$README")
if [ "$before" != "$after" ]; then
  fail "re-running adr-index should not change README.md" "diff detected"
fi
pass "adr-index re-run is idempotent"

# ─── Step 4: --check passes when in sync ──────────────────────────
if ! bash "$SDD_BIN" adr-index --check >/tmp/adr-index-check-2.out 2>&1; then
  fail "--check should pass when README.md is in sync" "$(cat /tmp/adr-index-check-2.out)"
fi
pass "--check exits 0 when in sync"

# ─── Step 5: drift after frontmatter edit ─────────────────────────
sed -i.bak 's/^type: decision/type: convention/' "$FIXTURE" && rm -f "$FIXTURE.bak"
set +e
bash "$SDD_BIN" adr-index --check >/tmp/adr-index-check-3.out 2>&1
rc=$?
set -e
if [ "$rc" -eq 0 ]; then
  fail "--check should detect drift after frontmatter edit" "$(cat /tmp/adr-index-check-3.out)"
fi
pass "--check detects drift after frontmatter edit"

# ─── Step 6: regenerate resolves drift ────────────────────────────
bash "$SDD_BIN" adr-index >/dev/null 2>&1
if ! bash "$SDD_BIN" adr-index --check >/tmp/adr-index-check-4.out 2>&1; then
  fail "--check should pass after regenerating" "$(cat /tmp/adr-index-check-4.out)"
fi
if ! grep -q "convention" "$README"; then
  fail "regenerated README.md should reflect updated type" "$(cat "$README")"
fi
pass "regenerate resolves drift"

echo ""
echo "All tests passed."
