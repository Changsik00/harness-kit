#!/usr/bin/env bash
# tests/test-sdd-base-branch.sh
# spec-8-002: sdd phase base branch 지원 단위 테스트

set -uo pipefail

PASS=0; FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$PROJECT_ROOT/sources/bin/sdd"
SDD_LIB_DIR="$PROJECT_ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$PROJECT_ROOT/sources/templates"

ok()   { echo "  ✅ PASS: $*"; ((PASS++)); }
fail() { echo "  ❌ FAIL: $*"; ((FAIL++)); }

# ─────────────────────────────────────────────────────────
# Fixture 설정 헬퍼
# ─────────────────────────────────────────────────────────
make_fixture() {
  local dir="$(mktemp -d)"
  mkdir -p "$dir/.claude/state"
  mkdir -p "$dir/backlog"
  mkdir -p "$dir/.harness-kit/bin/lib"
  mkdir -p "$dir/.harness-kit/agent/templates"

  cp "$SDD" "$dir/.harness-kit/bin/sdd"
  for f in "$SDD_LIB_DIR"/*.sh; do
    cp "$f" "$dir/.harness-kit/bin/lib/$(basename "$f")"
  done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do
    cp "$f" "$dir/.harness-kit/agent/templates/$(basename "$f")"
  done

  cat > "$dir/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": null,
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

  git -C "$dir" init -q
  git -C "$dir" config user.email "test@local"
  git -C "$dir" config user.name "test"
  git -C "$dir" commit --allow-empty -m "init" -q

  echo "$dir"
}

# ─────────────────────────────────────────────────────────
# Check 1: sdd phase new <slug> --base → baseBranch 저장
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: sdd phase new slug --base → state.json에 baseBranch 저장"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT

(cd "$F1" && bash .harness-kit/bin/sdd phase new work-model --base >/dev/null 2>&1)

phase_n=$(jq -r '.phase // ""' "$F1/.claude/state/current.json" 2>/dev/null)
expected_base="${phase_n}-work-model"
actual_base=$(jq -r '.baseBranch // ""' "$F1/.claude/state/current.json" 2>/dev/null)

if [ -n "$actual_base" ] && [ "$actual_base" = "$expected_base" ]; then
  ok "baseBranch = \"$actual_base\""
else
  fail "baseBranch expected=\"$expected_base\" got=\"$actual_base\""
fi

# ─────────────────────────────────────────────────────────
# Check 2: sdd phase new <slug> (no --base) → baseBranch = null
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: sdd phase new slug (no --base) → baseBranch = null"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

(cd "$F2" && bash .harness-kit/bin/sdd phase new simple-phase >/dev/null 2>&1)

base_raw=$(jq -r '.baseBranch' "$F2/.claude/state/current.json" 2>/dev/null)

if [ "$base_raw" = "null" ]; then
  ok "baseBranch = null (--base 없을 때 기본값)"
else
  fail "baseBranch expected=null got=\"$base_raw\""
fi

# ─────────────────────────────────────────────────────────
# Check 3: sdd status --json → baseBranch 키 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: sdd status --json → baseBranch 키 포함"

json_out=$(cd "$F1" && bash .harness-kit/bin/sdd status --json 2>/dev/null)

if echo "$json_out" | jq -e '.baseBranch != undefined' >/dev/null 2>&1 || echo "$json_out" | grep -q '"baseBranch"'; then
  ok "status --json 출력에 baseBranch 키 존재 (값: $(echo "$json_out" | jq -r '.baseBranch' 2>/dev/null))"
else
  fail "status --json 출력에 baseBranch 키 없음 — 출력: $json_out"
fi

# ─────────────────────────────────────────────────────────
# Check 4: sdd phase done → baseBranch = null
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: sdd phase done → baseBranch = null"

(cd "$F1" && bash .harness-kit/bin/sdd phase done >/dev/null 2>&1)

after_done=$(jq -r '.baseBranch' "$F1/.claude/state/current.json" 2>/dev/null)

if [ "$after_done" = "null" ]; then
  ok "phase done 후 baseBranch = null"
else
  fail "phase done 후 baseBranch expected=null got=\"$after_done\""
fi

# ─────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
