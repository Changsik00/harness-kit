#!/usr/bin/env bash
# tests/test-wiki-freshness.sh
#
# Verifies wiki freshness detection (spec-28-01) in `sdd doctor` / `sdd status`:
#   1. Unreflected ADR (not mentioned in wiki decisions/patterns) → "wiki 낡음" + ADR id
#   2. All ADRs reflected, little archive since last ingest → silent ("wiki 최신")
#   3. >=5 archived walkthroughs after last ingest date → warn
#   4. Archive on the same day as the last ingest is not counted
#   5. Missing wiki/archive/decisions → silent, doctor does not abort
#   6. `sdd status` 진단 surfaces the same line
#
# Uses throwaway git repos (real repo is never mutated). bash 3.2+ compatible.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

# new_fixture <name> → echoes dir. Minimal installed project with git.
new_fixture() {
  local d="$TMP_ROOT/$1"
  mkdir -p "$d/.harness-kit" "$d/docs/wiki" "$d/docs/decisions" "$d/archive/specs" "$d/backlog" "$d/specs"
  echo '{"kitVersion":"0.0.0"}' > "$d/.harness-kit/installed.json"
  echo '# Backlog Queue' > "$d/backlog/queue.md"
  (cd "$d" && git init -q && git config user.email t@t && git config user.name t)
  echo "$d"
}

# commit_at <dir> <iso-date> <msg>
commit_at() {
  (cd "$1" && git add -A && GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3" --allow-empty)
}

write_adr() { printf -- '---\nid: %s\ntype: decision\ndate: 2026-01-01\nstatus: accepted\n---\n# %s\n' "$2" "$2" > "$1/docs/decisions/$2-slug.md"; }

write_wiki() { # <dir> <ingest-date>
  printf -- '---\nkind: synthesis\n---\n# decisions\n[[ADR-001]]\n' > "$1/docs/wiki/decisions.md"
  printf -- '---\nkind: synthesis\n---\n# patterns\n' > "$1/docs/wiki/patterns.md"
  printf -- '---\nkind: catalog\n---\n# index\n' > "$1/docs/wiki/index.md"
  printf -- '---\nkind: catalog\n---\n# log\n\n### %s — 인제스트\n- **대상**: x\n' "$2" > "$1/docs/wiki/log.md"
}

add_archive() { # <dir> <n> <iso-date>
  local i
  for i in $(seq 1 "$2"); do
    mkdir -p "$1/archive/specs/spec-01-0$i-x"
    echo "wt $i" > "$1/archive/specs/spec-01-0$i-x/walkthrough.md"
  done
  commit_at "$1" "$3" "archive $2 specs"
}

run_doctor() { (cd "$1" && bash "$SDD" doctor 2>&1 || true); }
run_status() { (cd "$1" && bash "$SDD" status --no-drift 2>&1 || true); }

echo "Test: wiki freshness"

# ─── Case 1: unreflected ADR ───────────────────────────────────────
F1="$(new_fixture c1)"
write_adr "$F1" ADR-001; write_adr "$F1" ADR-002
write_wiki "$F1" 2026-01-10
commit_at "$F1" "2026-01-10T12:00:00" "init"
out=$(run_doctor "$F1")
echo "$out" | grep -q "wiki 낡음" || fail "unreflected ADR should warn" "$out"
echo "$out" | grep -q "ADR-002" || fail "warning should list ADR-002" "$out"
echo "$out" | grep -q "hk-wiki-ingest" || fail "warning should point to /hk-wiki-ingest" "$out"
pass "case 1: unreflected ADR warns with id and ingest hint"

# ─── Case 2: all reflected, quiet ──────────────────────────────────
F2="$(new_fixture c2)"
write_adr "$F2" ADR-001; write_adr "$F2" ADR-002
write_wiki "$F2" 2026-01-10
printf '[[ADR-002]]\n' >> "$F2/docs/wiki/patterns.md"
commit_at "$F2" "2026-01-10T12:00:00" "init"
add_archive "$F2" 4 "2026-02-01T12:00:00"
out=$(run_doctor "$F2")
echo "$out" | grep -q "wiki 낡음" && fail "reflected + <5 archive should be silent" "$out"
echo "$out" | grep -q "wiki 최신" || fail "should report 'wiki 최신'" "$out"
pass "case 2: fresh wiki is silent"

# ─── Case 3: >=5 archived after ingest ─────────────────────────────
F3="$(new_fixture c3)"
write_adr "$F3" ADR-001
write_wiki "$F3" 2026-01-10
commit_at "$F3" "2026-01-10T12:00:00" "init"
add_archive "$F3" 5 "2026-02-01T12:00:00"
out=$(run_doctor "$F3")
echo "$out" | grep -q "wiki 낡음" || fail "5 archived after ingest should warn" "$out"
pass "case 3: >=5 archived specs after last ingest warns"

# ─── Case 4: same-day archive not counted ──────────────────────────
F4="$(new_fixture c4)"
write_adr "$F4" ADR-001
write_wiki "$F4" 2026-01-10
commit_at "$F4" "2026-01-10T09:00:00" "init"
add_archive "$F4" 5 "2026-01-10T20:00:00"
out=$(run_doctor "$F4")
echo "$out" | grep -q "wiki 낡음" && fail "same-day archive must not count" "$out"
pass "case 4: same-day archive is not counted"

# ─── Case 5: missing pieces stay silent, doctor survives ───────────
F5="$(new_fixture c5)"
rm -rf "$F5/docs/wiki" "$F5/archive" "$F5/docs/decisions"
commit_at "$F5" "2026-01-10T12:00:00" "init"
out=$(run_doctor "$F5")
echo "$out" | grep -q "wiki 낡음" && fail "no wiki/archive/decisions must be silent" "$out"
echo "$out" | grep -q "wiki layer" || fail "doctor must still complete (wiki layer section)" "$out"
pass "case 5: missing wiki/archive/decisions stays silent"

# ─── Case 6: status 진단 ───────────────────────────────────────────
out=$(run_status "$F1")
echo "$out" | grep -q "wiki 낡음" || fail "status 진단 should surface freshness line" "$out"
pass "case 6: sdd status surfaces freshness line"

# ─── Case 7: 신호 A 는 wiki 전체에서 ADR 언급을 찾는다 (spec-30-02) ──
F7="$(new_fixture c7)"
write_adr "$F7" ADR-001; write_adr "$F7" ADR-002
write_wiki "$F7" 2026-01-10
mkdir -p "$F7/docs/wiki/components"
printf -- '---\nkind: synthesis\nsources: []\n---\n# hooks\n[[ADR-002]] 로 결정됨\n' > "$F7/docs/wiki/components/hooks.md"
commit_at "$F7" "2026-01-10T12:00:00" "init"
out=$(run_doctor "$F7")
echo "$out" | grep -q "미반영 ADR" && fail "ADR mentioned in a component page must count as reflected" "$out"
pass "case 7: ADR mentioned only in components/ is reflected"

# index.md 는 인벤토리라 여전히 제외
F8="$(new_fixture c8)"
write_adr "$F8" ADR-001; write_adr "$F8" ADR-002
write_wiki "$F8" 2026-01-10
printf '[[ADR-002]]\n' >> "$F8/docs/wiki/index.md"
commit_at "$F8" "2026-01-10T12:00:00" "init"
out=$(run_doctor "$F8")
echo "$out" | grep -q "ADR-002" || fail "index.md mention must not count as reflected" "$out"
echo "$out" | grep -q "wiki 낡음(보조)" || fail "freshness warning must be labelled as secondary signal" "$out"
pass "case 8: index.md excluded; warning labelled (보조)"

echo "PASS"
