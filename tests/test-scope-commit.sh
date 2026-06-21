#!/usr/bin/env bash
# tests/test-scope-commit.sh
# spec-24-02: check-scope.sh commit 모드(HARNESS_GIT_HOOK_MODE=1) — staged diff 전체를
# active spec scope 와 대조, 범위 밖이면 경고(exit 0). mode 무관(turbo/auto 도 검사), .md 면제.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-scope-commit ==="

CLEAN=()
cleanup() { local d; for d in "${CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done; }
trap cleanup EXIT

F=$(make_fixture); CLEAN+=("$F")
HOOK="$F/.harness-kit/hooks/check-scope.sh"
STATE="$F/.claude/state/current.json"
set_state() { local tmp; tmp=$(mktemp); jq "$1" "$STATE" > "$tmp" && mv "$tmp" "$STATE"; }
run_scope() { ( cd "$F" && HARNESS_GIT_HOOK_MODE=1 bash "$HOOK" 2>&1 ); }

# active spec + scope 정의 (spec.md Proposed Changes)
SPEC="spec-99-01-demo"
mkdir -p "$F/specs/$SPEC" "$F/src" "$F/lib"
cat > "$F/specs/$SPEC/spec.md" <<'EOF'
# demo
## Proposed Changes
#### [MODIFY] `src/in-scope.sh`
EOF
set_state '.spec="spec-99-01-demo" | .planAccepted=true | .mode="governed"'

# T1: 범위 밖 staged → 경고 + exit 0 (비차단)
echo "x" > "$F/lib/out.sh"; git -C "$F" add lib/out.sh
OUT=$(run_scope); RC=$?
if [ "$RC" -eq 0 ] && echo "$OUT" | grep -q "lib/out.sh"; then ok "범위 밖 staged → 경고 + exit 0 (비차단)"; else fail "rc=$RC out='$OUT'"; fi
git -C "$F" reset -q

# T2: 범위 안만 staged → 경고 없음
echo "x" > "$F/src/in-scope.sh"; git -C "$F" add src/in-scope.sh
OUT=$(run_scope)
echo "$OUT" | grep -q "src/in-scope.sh" && fail "범위 안인데 경고됨: $OUT" || ok "범위 안 staged → 경고 없음"
git -C "$F" reset -q

# T3: mode=auto 에서도 범위 밖 경고 (mode 무관 — blast-radius 가드)
set_state '.mode="auto"'
git -C "$F" add lib/out.sh
OUT=$(run_scope)
echo "$OUT" | grep -q "lib/out.sh" && ok "auto 에서도 scope 경고 (mode 무관)" || fail "auto 무경고: $OUT"
git -C "$F" reset -q
set_state '.mode="governed"'

# T4: .md 는 면제
echo "x" > "$F/note.md"; git -C "$F" add note.md
OUT=$(run_scope)
echo "$OUT" | grep -q "note.md" && fail ".md 가 경고됨: $OUT" || ok ".md staged → 면제"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
