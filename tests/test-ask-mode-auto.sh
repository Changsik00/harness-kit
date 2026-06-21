#!/usr/bin/env bash
set -uo pipefail

# test-ask-mode-auto.sh
# spec-24-04: effective ux-mode resolver
#   sdd config ux-mode effective → mode=auto 면 text, 아니면 저장된 uxMode

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

FIXTURES_TO_CLEAN=()
trap 'for d in "${FIXTURES_TO_CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

_set_mode() { local t; t=$(mktemp); jq --arg v "$2" '.mode=$v' "$1/.claude/state/current.json" > "$t" && mv "$t" "$1/.claude/state/current.json"; }
_set_ux()   { local t; t=$(mktemp); jq --arg v "$2" '.uxMode=$v' "$1/.harness-kit/installed.json" > "$t" && mv "$t" "$1/.harness-kit/installed.json"; }
_sdd()      { local fx="$1"; shift; ( cd "$fx" && bash .harness-kit/bin/sdd "$@" ); }

echo "═══════════════════════════════════════════════════════"
echo " test-ask-mode-auto (spec-24-04)"
echo "═══════════════════════════════════════════════════════"

# E1: auto + uxMode=interactive → effective text
echo ""
FX1="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX1")
_set_mode "$FX1" auto; _set_ux "$FX1" interactive
out1="$(_sdd "$FX1" config ux-mode effective 2>/dev/null | tr -d '[:space:]')"
[ "$out1" = "text" ] && ok "E1: auto + interactive → text" || fail "E1: 기대 text, 실제 '$out1'"

# E2: auto + uxMode=text → effective text
FX2="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX2")
_set_mode "$FX2" auto; _set_ux "$FX2" text
out2="$(_sdd "$FX2" config ux-mode effective 2>/dev/null | tr -d '[:space:]')"
[ "$out2" = "text" ] && ok "E2: auto + text → text" || fail "E2: 기대 text, 실제 '$out2'"

# E3: governed + uxMode=interactive → effective interactive
FX3="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX3")
_set_mode "$FX3" governed; _set_ux "$FX3" interactive
out3="$(_sdd "$FX3" config ux-mode effective 2>/dev/null | tr -d '[:space:]')"
[ "$out3" = "interactive" ] && ok "E3: governed + interactive → interactive" || fail "E3: 기대 interactive, 실제 '$out3'"

# E4: governed + uxMode=text → effective text
FX4="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX4")
_set_mode "$FX4" governed; _set_ux "$FX4" text
out4="$(_sdd "$FX4" config ux-mode effective 2>/dev/null | tr -d '[:space:]')"
[ "$out4" = "text" ] && ok "E4: governed + text → text" || fail "E4: 기대 text, 실제 '$out4'"

# E5: 회귀 — 인자 없는 조회는 기존대로 "uxMode: <값>"
FX5="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX5")
_set_mode "$FX5" auto; _set_ux "$FX5" interactive
out5="$(_sdd "$FX5" config ux-mode 2>/dev/null)"
echo "$out5" | grep -q "uxMode: interactive" && ok "E5: 무인자 조회 회귀 (저장값 그대로)" || fail "E5: 무인자 조회 기대 'uxMode: interactive', 실제 '$out5'"

echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
