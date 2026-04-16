#!/usr/bin/env bash
# tests/test-sdd-spec-completeness.sh
# sdd status 산출물 완성도 체크리스트 단위 테스트 (TDD Red 단계)
# 검증: active spec 단계별 산출물 표시 (Planning / Executing / Ship-ready)

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
# Check 1: Planning 단계 (spec.md + plan.md만 존재)
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: Planning 단계 — spec.md + plan.md 만 존재 → Planning 표시"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT

cat > "$F1/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-1",
  "spec": "spec-1-001-test",
  "planAccepted": true,
  "lastTestPass": null
}
EOF

mkdir -p "$F1/specs/spec-1-001-test"
echo "# spec-1-001-test" > "$F1/specs/spec-1-001-test/spec.md"
echo "# plan"            > "$F1/specs/spec-1-001-test/plan.md"

git -C "$F1" add -A
git -C "$F1" commit -m "setup" -q

status_out1=$(cd "$F1" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out1" | grep -q "Planning"; then
  ok "spec.md + plan.md 존재 → Planning 단계 표시됨"
else
  fail "spec.md + plan.md 존재 → Planning 표시 없음 — 출력: $status_out1"
fi

# ─────────────────────────────────────────────────────────
# Check 2: Executing 단계 (+task.md 추가)
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: Executing 단계 — task.md 추가 → Executing 표시"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

cat > "$F2/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-1",
  "spec": "spec-1-001-test",
  "planAccepted": true,
  "lastTestPass": null
}
EOF

mkdir -p "$F2/specs/spec-1-001-test"
echo "# spec-1-001-test" > "$F2/specs/spec-1-001-test/spec.md"
echo "# plan"            > "$F2/specs/spec-1-001-test/plan.md"
echo "# task"            > "$F2/specs/spec-1-001-test/task.md"

git -C "$F2" add -A
git -C "$F2" commit -m "setup" -q

status_out2=$(cd "$F2" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out2" | grep -q "Executing"; then
  ok "spec.md + plan.md + task.md 존재 → Executing 단계 표시됨"
else
  fail "spec.md + plan.md + task.md 존재 → Executing 표시 없음 — 출력: $status_out2"
fi

# ─────────────────────────────────────────────────────────
# Check 3: Ship-ready 단계 (+walkthrough.md + pr_description.md 추가)
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: Ship-ready 단계 — walkthrough.md + pr_description.md 추가 → Ship-ready 표시"

F3="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3'" EXIT

cat > "$F3/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-1",
  "spec": "spec-1-001-test",
  "planAccepted": true,
  "lastTestPass": null
}
EOF

mkdir -p "$F3/specs/spec-1-001-test"
echo "# spec-1-001-test"  > "$F3/specs/spec-1-001-test/spec.md"
echo "# plan"             > "$F3/specs/spec-1-001-test/plan.md"
echo "# task"             > "$F3/specs/spec-1-001-test/task.md"
echo "# walkthrough"      > "$F3/specs/spec-1-001-test/walkthrough.md"
echo "# pr_description"   > "$F3/specs/spec-1-001-test/pr_description.md"

git -C "$F3" add -A
git -C "$F3" commit -m "setup" -q

status_out3=$(cd "$F3" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out3" | grep -q "Ship-ready"; then
  ok "모든 산출물 존재 → Ship-ready 단계 표시됨"
else
  fail "모든 산출물 존재 → Ship-ready 표시 없음 — 출력: $status_out3"
fi

# ─────────────────────────────────────────────────────────
# Check 4: active spec 없음 → 산출물 라인 미출력
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: active spec 없음 → Artifacts / 산출물 라인 미출력"

F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4'" EXIT

cat > "$F4/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-1",
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

git -C "$F4" add -A
git -C "$F4" commit -m "setup" -q

status_out4=$(cd "$F4" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out4" | grep -qiE "Artifacts|산출물"; then
  fail "spec=null → Artifacts / 산출물 라인이 출력됨 (출력되면 안 됨) — 출력: $status_out4"
else
  ok "spec=null → Artifacts / 산출물 라인 미출력 확인됨"
fi

# ─────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
