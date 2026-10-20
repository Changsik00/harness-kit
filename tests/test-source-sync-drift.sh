#!/usr/bin/env bash
# tests/test-source-sync-drift.sh
#
# Verifies source↔copy drift detection (spec-28-02) in `sdd doctor` / `sdd status`:
#   1. Differing file → "원본↔사본 drift" + file name
#   2. All identical → silent ("원본↔사본 일치")
#   3. Source file missing in copy counts as drift
#   4. Copy-only file is ignored
#   5. No sources/ (downstream) → silent, doctor survives
#   6. `sdd status` 진단 surfaces the line
#
# Uses throwaway fixtures. bash 3.2+ compatible.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

# new_fixture <name> → kit-repo-like dir where every source file has an identical copy.
new_fixture() {
  local d="$TMP_ROOT/$1"
  mkdir -p "$d/.harness-kit/bin" "$d/.harness-kit/hooks" "$d/.harness-kit/agent/templates" "$d/.claude/commands" \
           "$d/sources/bin" "$d/sources/hooks" "$d/sources/governance" "$d/sources/templates" "$d/sources/commands" \
           "$d/backlog" "$d/specs"
  echo '{"kitVersion":"0.0.0"}' > "$d/.harness-kit/installed.json"
  echo '# Backlog Queue' > "$d/backlog/queue.md"
  echo 'sdd' > "$d/sources/bin/sdd";            cp "$d/sources/bin/sdd" "$d/.harness-kit/bin/sdd"
  echo 'lib' > "$d/sources/hooks/_lib.sh";      cp "$d/sources/hooks/_lib.sh" "$d/.harness-kit/hooks/_lib.sh"
  echo 'const' > "$d/sources/governance/constitution.md"; cp "$d/sources/governance/constitution.md" "$d/.harness-kit/agent/constitution.md"
  echo 'spec' > "$d/sources/templates/spec.md"; cp "$d/sources/templates/spec.md" "$d/.harness-kit/agent/templates/spec.md"
  echo 'align' > "$d/sources/commands/hk-align.md"; cp "$d/sources/commands/hk-align.md" "$d/.claude/commands/hk-align.md"
  (cd "$d" && git init -q && git config user.email t@t && git config user.name t && git add -A && git commit -q -m init)
  echo "$d"
}

run_doctor() { (cd "$1" && bash "$SDD" doctor 2>&1 || true); }
run_status() { (cd "$1" && bash "$SDD" status --no-drift 2>&1 || true); }

echo "Test: source↔copy drift"

# ─── Case 1: differing file ────────────────────────────────────────
F1="$(new_fixture c1)"
echo 'changed' >> "$F1/.harness-kit/hooks/_lib.sh"
out=$(run_doctor "$F1")
echo "$out" | grep -q "원본↔사본 drift" || fail "differing file should warn" "$out"
echo "$out" | grep -q "_lib.sh" || fail "warning should list _lib.sh" "$out"
pass "case 1: differing file warns with name"

# ─── Case 2: identical ─────────────────────────────────────────────
F2="$(new_fixture c2)"
out=$(run_doctor "$F2")
echo "$out" | grep -q "원본↔사본 drift" && fail "identical must be silent" "$out"
echo "$out" | grep -q "원본↔사본 일치" || fail "should report 원본↔사본 일치" "$out"
pass "case 2: identical is silent"

# ─── Case 3: missing in copy ───────────────────────────────────────
F3="$(new_fixture c3)"
echo 'new' > "$F3/sources/commands/hk-new.md"
out=$(run_doctor "$F3")
echo "$out" | grep -q "hk-new.md" || fail "source file absent in copy should be drift" "$out"
pass "case 3: missing copy counts as drift"

# ─── Case 4: copy-only ignored ─────────────────────────────────────
F4="$(new_fixture c4)"
echo 'x' > "$F4/.harness-kit/hooks/extra.sh"
out=$(run_doctor "$F4")
echo "$out" | grep -q "원본↔사본 drift" && fail "copy-only file must be ignored" "$out"
pass "case 4: copy-only file ignored"

# ─── Case 5: downstream (no sources/) ──────────────────────────────
F5="$(new_fixture c5)"
rm -rf "$F5/sources"
out=$(run_doctor "$F5")
echo "$out" | grep -q "원본↔사본" && fail "downstream must be silent" "$out"
echo "$out" | grep -q "wiki layer" || fail "doctor must still complete" "$out"
pass "case 5: downstream stays silent"

# ─── Case 6: status 진단 ───────────────────────────────────────────
out=$(run_status "$F1")
echo "$out" | grep -q "원본↔사본 drift" || fail "status 진단 should surface drift line" "$out"
pass "case 6: sdd status surfaces drift line"

echo "PASS"
