#!/usr/bin/env bash
# tests/test-sdd-base-branch.sh
# spec-8-002: sdd phase base branch 지원 단위 테스트

set -uo pipefail

PASS=0; FAIL=0
SDD="$(cd "$(dirname "$0")/.." && pwd)/scripts/harness/bin/sdd"

ok()   { echo "  ✅ PASS: $*"; ((PASS++)); }
fail() { echo "  ❌ FAIL: $*"; ((FAIL++)); }

# ─────────────────────────────────────────────────────────
# Fixture 설정
# ─────────────────────────────────────────────────────────
FIXTURE_DIR="$(mktemp -d)"
cleanup() { rm -rf "$FIXTURE_DIR"; }
trap cleanup EXIT

mkdir -p "$FIXTURE_DIR/.claude/state"
mkdir -p "$FIXTURE_DIR/backlog"
mkdir -p "$FIXTURE_DIR/scripts/harness/bin"
mkdir -p "$FIXTURE_DIR/scripts/harness/lib"

# sdd 바이너리 심링크
ln -s "$SDD" "$FIXTURE_DIR/scripts/harness/bin/sdd"

# lib 심링크
SDD_LIB_DIR="$(dirname "$SDD")/lib"
ln -s "$SDD_LIB_DIR" "$FIXTURE_DIR/scripts/harness/lib/common.sh" 2>/dev/null || true
for f in "$SDD_LIB_DIR"/*.sh; do
  ln -s "$f" "$FIXTURE_DIR/scripts/harness/lib/$(basename "$f")" 2>/dev/null || true
done

# templates 심링크
SDD_TEMPLATES_DIR="$(cd "$(dirname "$SDD")/../.." && pwd)/agent/templates"
mkdir -p "$FIXTURE_DIR/agent/templates"
for f in "$SDD_TEMPLATES_DIR"/*.md; do
  ln -s "$f" "$FIXTURE_DIR/agent/templates/$(basename "$f")" 2>/dev/null || true
done

# 초기 state.json
cat > "$FIXTURE_DIR/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": null,
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

# git init (sdd_find_root 동작을 위해)
git -C "$FIXTURE_DIR" init -q
git -C "$FIXTURE_DIR" commit --allow-empty -m "init" -q

# ─────────────────────────────────────────────────────────
# Check 1: sdd phase new <slug> --base → baseBranch 저장
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: sdd phase new slug --base → state.json에 baseBranch 저장"
(cd "$FIXTURE_DIR" && bash scripts/harness/bin/sdd phase new work-model --base >/dev/null 2>&1)

phase_n=$(cat "$FIXTURE_DIR/.claude/state/current.json" | grep '"phase"' | grep -o 'phase-[0-9]*' | head -1)
expected_base="${phase_n}-work-model"
actual_base=$(cat "$FIXTURE_DIR/.claude/state/current.json" | grep '"baseBranch"' | sed 's/.*"baseBranch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

if [ "$actual_base" = "$expected_base" ]; then
  ok "baseBranch = \"$actual_base\""
else
  fail "baseBranch expected=\"$expected_base\" got=\"$actual_base\""
fi

# ─────────────────────────────────────────────────────────
# Check 2: sdd phase new <slug> (no --base) → baseBranch = null
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: sdd phase new slug (no --base) → baseBranch = null"

# 새 fixture 사용
FIXTURE2="$(mktemp -d)"
cleanup2() { rm -rf "$FIXTURE2"; }
trap "cleanup; cleanup2" EXIT

mkdir -p "$FIXTURE2/.claude/state"
mkdir -p "$FIXTURE2/backlog"
mkdir -p "$FIXTURE2/scripts/harness/bin"
mkdir -p "$FIXTURE2/scripts/harness/lib"
mkdir -p "$FIXTURE2/agent/templates"

ln -s "$SDD" "$FIXTURE2/scripts/harness/bin/sdd"
for f in "$SDD_LIB_DIR"/*.sh; do
  ln -s "$f" "$FIXTURE2/scripts/harness/lib/$(basename "$f")" 2>/dev/null || true
done
for f in "$SDD_TEMPLATES_DIR"/*.md; do
  ln -s "$f" "$FIXTURE2/agent/templates/$(basename "$f")" 2>/dev/null || true
done

cat > "$FIXTURE2/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": null,
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

git -C "$FIXTURE2" init -q
git -C "$FIXTURE2" commit --allow-empty -m "init" -q

(cd "$FIXTURE2" && bash scripts/harness/bin/sdd phase new simple-phase >/dev/null 2>&1)

base_raw=$(cat "$FIXTURE2/.claude/state/current.json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('baseBranch','KEY_MISSING'))" 2>/dev/null || echo "KEY_MISSING")

if [ "$base_raw" = "null" ] || [ "$base_raw" = "KEY_MISSING" ]; then
  ok "baseBranch = null (--base 없을 때 기본값)"
else
  fail "baseBranch expected=null got=\"$base_raw\""
fi

# ─────────────────────────────────────────────────────────
# Check 3: sdd status --json → baseBranch 키 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: sdd status --json → baseBranch 키 포함"

json_out=$(cd "$FIXTURE_DIR" && bash scripts/harness/bin/sdd status --json 2>/dev/null)

if echo "$json_out" | grep -q '"baseBranch"'; then
  ok "status --json 출력에 baseBranch 키 존재"
else
  fail "status --json 출력에 baseBranch 키 없음 — 출력: $json_out"
fi

# ─────────────────────────────────────────────────────────
# Check 4: sdd phase done → baseBranch = null
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: sdd phase done → baseBranch = null"

# Fixture1 의 active phase done 처리
(cd "$FIXTURE_DIR" && bash scripts/harness/bin/sdd phase done >/dev/null 2>&1)

after_done=$(python3 -c "import sys,json; d=json.load(open('$FIXTURE_DIR/.claude/state/current.json')); print(d.get('baseBranch','KEY_MISSING'))" 2>/dev/null || echo "KEY_MISSING")

if [ "$after_done" = "null" ] || [ "$after_done" = "KEY_MISSING" ]; then
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
