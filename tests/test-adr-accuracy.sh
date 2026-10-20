#!/usr/bin/env bash
# tests/test-adr-accuracy.sh
#
# phase-29 doctor-accuracy: ADR 검사기 정확도 회귀 테스트 (throwaway fixture).
#   1. frontmatter 없는 ADR 본문의 `id:`/`type:` 줄은 인덱스에 쓰이지 않는다 (_adr_field 경계)
#   2. frontmatter 값의 인라인 주석(`type: decision   # ...`)은 값에서 제외된다
#   3. doctor: type 이 폐쇄 어휘 밖이면 경고
#   4. doctor: 어휘 안(주석 포함 템플릿 형태 포함)이면 침묵
#
# bash 3.2+ compatible.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    output: $2"; exit 1; }

new_fixture() {
  local d="$TMP_ROOT/$1"
  mkdir -p "$d/.harness-kit" "$d/docs/decisions" "$d/backlog" "$d/specs"
  echo '{"kitVersion":"0.0.0"}' > "$d/.harness-kit/installed.json"
  echo '# Backlog Queue' > "$d/backlog/queue.md"
  (cd "$d" && git init -q && git config user.email t@t && git config user.name t)
  echo "$d"
}
run_sdd() { local d="$1"; shift; (cd "$d" && bash "$SDD" "$@" 2>&1 || true); }

echo "Test: ADR checker accuracy"

# ─── Case 1: no frontmatter → body lines must not leak into index ─
F1="$(new_fixture c1)"
printf '# ADR-777: no frontmatter\n\n본문 예시:\nid: ADR-999\ntype: tradeoff\n' > "$F1/docs/decisions/ADR-777-nofm.md"
run_sdd "$F1" adr-index >/dev/null
idx=$(cat "$F1/docs/decisions/README.md")
echo "$idx" | grep -q "ADR-999" && fail "body 'id:' line must not become the ADR id" "$idx"
echo "$idx" | grep -q "tradeoff" && fail "body 'type:' line must not become the type" "$idx"
echo "$idx" | grep -q "ADR-777-nofm" || fail "row should fall back to the file basename" "$idx"
pass "case 1: body lines outside frontmatter are ignored"

# ─── Case 2: inline comment stripped from value ───────────────────
F2="$(new_fixture c2)"
printf -- '---\nid: ADR-001\ntype: decision    # decision | invariant | convention | tradeoff\ndate: 2026-01-01\nstatus: proposed  # proposed | accepted\n---\n# ADR-001: t\n' > "$F2/docs/decisions/ADR-001-t.md"
run_sdd "$F2" adr-index >/dev/null
row=$(grep "ADR-001" "$F2/docs/decisions/README.md" | head -1)
echo "$row" | grep -q "#" && fail "inline comment must be stripped from index row" "$row"
echo "$row" | grep -q "| decision | proposed |" || fail "row should carry clean type/status" "$row"
pass "case 2: inline comments stripped from field values"

# ─── Case 3: out-of-closure type warns ────────────────────────────
F3="$(new_fixture c3)"
printf -- '---\nid: ADR-001\ntype: weird\ndate: 2026-01-01\nstatus: accepted\n---\n# ADR-001: t\n' > "$F3/docs/decisions/ADR-001-t.md"
out=$(run_sdd "$F3" doctor)
echo "$out" | grep -q "type 어휘 밖" || fail "out-of-closure type should warn" "$out"
echo "$out" | grep -q "ADR-001" || fail "warning should name the ADR" "$out"
pass "case 3: out-of-closure type warns"

# ─── Case 4: valid type (incl. template comment form) is silent ───
F4="$(new_fixture c4)"
printf -- '---\nid: ADR-001\ntype: decision    # decision | invariant | convention | tradeoff\ndate: 2026-01-01\nstatus: proposed  # proposed | accepted\n---\n# ADR-001: t\n' > "$F4/docs/decisions/ADR-001-t.md"
printf -- '---\nid: ADR-002\ntype: tradeoff\ndate: 2026-01-01\nstatus: accepted\n---\n# ADR-002: u\n' > "$F4/docs/decisions/ADR-002-u.md"
out=$(run_sdd "$F4" doctor)
echo "$out" | grep -q "type 어휘 밖" && fail "valid types must be silent" "$out"
echo "$out" | grep -q "ADR type 어휘 정상" || fail "should report closure OK" "$out"
pass "case 4: valid type silent"

echo "PASS"
