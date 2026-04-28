#!/usr/bin/env bash
# tests/test-sdd-spec-new-seq.sh
# spec-15-06: sdd spec_new() 가 archive/specs 의 seq 번호를 포함해 next seq 를 계산하는지 검증.
# phase_new() 의 archive/backlog 스캔과 동일한 패턴.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$ROOT/sources/bin/sdd"
SDD_LIB_DIR="$ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$ROOT/sources/templates"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

make_sdd_fixture() {
  local dir
  dir=$(mktemp -d)
  mkdir -p "$dir/.claude/state"
  mkdir -p "$dir/backlog"
  mkdir -p "$dir/specs"
  mkdir -p "$dir/archive/specs"
  mkdir -p "$dir/.harness-kit/bin/lib"
  mkdir -p "$dir/.harness-kit/agent/templates"

  cp "$SDD" "$dir/.harness-kit/bin/sdd"
  local f
  for f in "$SDD_LIB_DIR"/*.sh; do
    cp "$f" "$dir/.harness-kit/bin/lib/$(basename "$f")"
  done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do
    cp "$f" "$dir/.harness-kit/agent/templates/$(basename "$f")"
  done

  cat > "$dir/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.6.2",
  "stack": "generic",
  "phase": null,
  "spec": null,
  "branch": null,
  "baseBranch": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

  cp "$SDD_TEMPLATES_DIR/queue.md" "$dir/backlog/queue.md"
  git -C "$dir" init -q
  git -C "$dir" config user.email "t@l"
  git -C "$dir" config user.name "t"
  git -C "$dir" commit --allow-empty -m "init" -q 2>/dev/null

  echo "$dir"
}

write_phase_file() {
  local dir="$1" phase_id="$2"
  cat > "$dir/backlog/${phase_id}.md" <<EOF
# ${phase_id}: test fixture

<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
<!-- sdd:specs:end -->
EOF
}

echo "═══════════════════════════════════════════════════════"
echo " test-sdd-spec-new-seq (spec-15-06) — archive seq check"
echo "═══════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────
# Test 1: specs/ 에 01-03 있을 때 04 할당 (기본 동작)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 1: specs/ 에 01-03 있을 때 → 04 할당"
F1=$(make_sdd_fixture); CLEANUP+=("$F1")
write_phase_file "$F1" "phase-99"
(cd "$F1" && bash .harness-kit/bin/sdd phase activate phase-99 >/dev/null 2>&1)

mkdir -p "$F1/specs/spec-99-01-dummy"
mkdir -p "$F1/specs/spec-99-02-dummy"
mkdir -p "$F1/specs/spec-99-03-dummy"

(cd "$F1" && bash .harness-kit/bin/sdd spec new alpha >/dev/null 2>&1)
assigned=$(jq -r '.spec' "$F1/.claude/state/current.json" | sed 's/spec-99-//' | cut -d'-' -f1)
if [ "$assigned" = "04" ]; then
  ok "Test 1: 04 할당 (expected)"
else
  fail "Test 1: 예상 04, 실제 $assigned"
fi

# ─────────────────────────────────────────────────────────
# Test 2: archive/specs 에 01-05 있고 specs/ 비어있을 때 → 06 할당
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 2: archive/specs/ 에 01-05, specs/ 비어있을 때 → 06 할당"
F2=$(make_sdd_fixture); CLEANUP+=("$F2")
write_phase_file "$F2" "phase-88"
(cd "$F2" && bash .harness-kit/bin/sdd phase activate phase-88 >/dev/null 2>&1)

mkdir -p "$F2/archive/specs/spec-88-01-old"
mkdir -p "$F2/archive/specs/spec-88-02-old"
mkdir -p "$F2/archive/specs/spec-88-03-old"
mkdir -p "$F2/archive/specs/spec-88-04-old"
mkdir -p "$F2/archive/specs/spec-88-05-old"

(cd "$F2" && bash .harness-kit/bin/sdd spec new beta >/dev/null 2>&1)
assigned2=$(jq -r '.spec' "$F2/.claude/state/current.json" | sed 's/spec-88-//' | cut -d'-' -f1)
if [ "$assigned2" = "06" ]; then
  ok "Test 2: 06 할당 (archive 포함 스캔)"
else
  fail "Test 2: 예상 06, 실제 $assigned2 — archive/specs 미스캔 버그"
fi

# ─────────────────────────────────────────────────────────
# Test 3: specs/ 에 01-03, archive/specs 에 04-06 → 07 할당
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 3: specs/에 01-03, archive/에 04-06 → 07 할당"
F3=$(make_sdd_fixture); CLEANUP+=("$F3")
write_phase_file "$F3" "phase-77"
(cd "$F3" && bash .harness-kit/bin/sdd phase activate phase-77 >/dev/null 2>&1)

mkdir -p "$F3/specs/spec-77-01-active"
mkdir -p "$F3/specs/spec-77-02-active"
mkdir -p "$F3/specs/spec-77-03-active"
mkdir -p "$F3/archive/specs/spec-77-04-archived"
mkdir -p "$F3/archive/specs/spec-77-05-archived"
mkdir -p "$F3/archive/specs/spec-77-06-archived"

(cd "$F3" && bash .harness-kit/bin/sdd spec new gamma >/dev/null 2>&1)
assigned3=$(jq -r '.spec' "$F3/.claude/state/current.json" | sed 's/spec-77-//' | cut -d'-' -f1)
if [ "$assigned3" = "07" ]; then
  ok "Test 3: 07 할당 (specs + archive 합산)"
else
  fail "Test 3: 예상 07, 실제 $assigned3"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
