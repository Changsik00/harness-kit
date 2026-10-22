#!/usr/bin/env bash
# tests/test-doctor-wikilink-adr.sh
#
# phase-28 phase-FF wikilink-adr-prefix: `sdd doctor` W-2 must resolve
# [[ADR-NNN]] / [[RCA-NNN]] to slugged files (ADR-NNN-slug.md) and still
# flag truly missing targets.
#   1. [[ADR-001]] with docs/decisions/ADR-001-slug.md → no orphan
#   2. [[ADR-999]] with no such file → counted as orphan
#   3. [[RCA-001]] with docs/rca/RCA-001-slug.md → no orphan
#   4. Exact filename [[ADR-001-slug]] still resolves
#   5. [[spec-NN-NN]] resolves to archive/specs/spec-NN-NN-<slug>/ (and specs/)
#   6. [[spec-99-99]] with no such dir is still orphan
#   7. [[...]] inside inline code (`[[ADR-NNN]]` examples) is ignored
#
# Throwaway fixtures. bash 3.2+ compatible.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

new_fixture() { # <name> <wiki-body>
  local d="$TMP_ROOT/$1"
  mkdir -p "$d/.harness-kit" "$d/docs/wiki" "$d/docs/decisions" "$d/docs/rca" "$d/backlog" "$d/specs"
  echo '{"kitVersion":"0.0.0"}' > "$d/.harness-kit/installed.json"
  echo '# Backlog Queue' > "$d/backlog/queue.md"
  echo '# adr' > "$d/docs/decisions/ADR-001-slug.md"
  echo '# rca' > "$d/docs/rca/RCA-001-slug.md"
  mkdir -p "$d/archive/specs/spec-15-05-dedupe-lists" "$d/archive/specs/spec-x-some-fix"
  printf -- '---\nkind: synthesis\n---\n%s\n' "$2" > "$d/docs/wiki/decisions.md"
  (cd "$d" && git init -q && git config user.email t@t && git config user.name t && git add -A && git commit -q -m init)
  echo "$d"
}
run_doctor() { (cd "$1" && bash "$SDD" doctor 2>&1 || true); }

echo "Test: doctor wikilink ADR/RCA prefix"

F1="$(new_fixture c1 '[[ADR-001]]')"
out=$(run_doctor "$F1")
echo "$out" | grep -q "고아 wikilink 감지" && fail "[[ADR-001]] must resolve to ADR-001-slug.md" "$out"
echo "$out" | grep -q "고아 링크 없음" || fail "should report no orphan" "$out"
pass "case 1: [[ADR-NNN]] resolves via slug prefix"

F2="$(new_fixture c2 '[[ADR-999]]')"
out=$(run_doctor "$F2")
echo "$out" | grep -q "1개 고아 wikilink 감지" || fail "[[ADR-999]] must still be orphan" "$out"
pass "case 2: truly missing ADR still orphan"

F3="$(new_fixture c3 '[[RCA-001]]')"
out=$(run_doctor "$F3")
echo "$out" | grep -q "고아 wikilink 감지" && fail "[[RCA-001]] must resolve" "$out"
pass "case 3: [[RCA-NNN]] resolves via slug prefix"

F4="$(new_fixture c4 '[[ADR-001-slug]]')"
out=$(run_doctor "$F4")
echo "$out" | grep -q "고아 wikilink 감지" && fail "exact filename must resolve" "$out"
pass "case 4: exact filename still resolves"

F5="$(new_fixture c5 '[[spec-15-05]] [[spec-x-some-fix]]')"
out=$(run_doctor "$F5")
echo "$out" | grep -q "고아 wikilink 감지" && fail "[[spec-NN-NN]] / exact spec-x dir must resolve to archive/specs" "$out"
pass "case 5: spec refs resolve to archive/specs"

F6="$(new_fixture c6 '[[spec-99-99]]')"
out=$(run_doctor "$F6")
echo "$out" | grep -q "1개 고아 wikilink 감지" || fail "[[spec-99-99]] must still be orphan" "$out"
pass "case 6: missing spec ref still orphan"

F7="$(new_fixture c7 'example: `[[ADR-NNN]]` and `[[wiki/page-name]]`')"
out=$(run_doctor "$F7")
echo "$out" | grep -q "고아 wikilink 감지" && fail "links inside inline code must be ignored" "$out"
pass "case 7: inline-code examples ignored"

echo "PASS"
