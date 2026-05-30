#!/usr/bin/env bash
# tests/test-sdd-spec-new-drift-warn.sh
# spec-x-harness-footguns: spec/specx new 시 미커밋 install drift
#   (.harness-kit/·.claude/) 가 감지되면 비차단 경고를 출력해
#   브랜치 생성 시 PR scope 오염을 예방한다.
set -uo pipefail

PASS=0; FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$PROJECT_ROOT/sources/bin/sdd"
SDD_LIB_DIR="$PROJECT_ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$PROJECT_ROOT/sources/templates"

ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

make_fixture() {
  local dir; dir="$(mktemp -d)"
  mkdir -p "$dir/.claude/state" "$dir/backlog" "$dir/specs"
  mkdir -p "$dir/.harness-kit/bin/lib" "$dir/.harness-kit/agent/templates" "$dir/.harness-kit/hooks"
  cp "$SDD" "$dir/.harness-kit/bin/sdd"
  local f
  for f in "$SDD_LIB_DIR"/*.sh; do cp "$f" "$dir/.harness-kit/bin/lib/$(basename "$f")"; done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do cp "$f" "$dir/.harness-kit/agent/templates/$(basename "$f")"; done
  cat > "$dir/.claude/state/current.json" <<'EOF'
{ "kitVersion":"0.0.0","stack":"generic","phase":null,"spec":null,"planAccepted":false,"lastTestPass":null,"baseBranch":null }
EOF
  cp "$SDD_TEMPLATES_DIR/queue.md" "$dir/backlog/queue.md"
  git -C "$dir" init -q
  git -C "$dir" config user.email "test@local"
  git -C "$dir" config user.name "test"
  git -C "$dir" add -A
  git -C "$dir" commit -m "init" -q
  echo "$dir"
}

echo "═══════════════════════════════════════════════════════"
echo " test-sdd-spec-new-drift-warn (spec-x-harness-footguns)"
echo "═══════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────
# Check 1: 미커밋 install drift 존재 → specx new 가 경고 + 비차단 + 생성
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Check 1: 미커밋 .harness-kit/ 변경 있을 때 specx new → 경고 + rc=0 + 생성"
F1="$(make_fixture)"
# init 커밋 이후 untracked install 파일 생성 (drift 모사)
echo "# drift" > "$F1/.harness-kit/hooks/dirty-hook.sh"

out1=$(cd "$F1" && bash .harness-kit/bin/sdd specx new foo 2>&1)
rc1=$?

if [ "$rc1" -eq 0 ]; then
  ok "Check 1a: specx new rc=0 (비차단)"
else
  fail "Check 1a: specx new rc=$rc1 (비차단이어야 함) — out=$out1"
fi

if echo "$out1" | grep -qiE '미커밋 install'; then
  ok "Check 1b: install drift 경고 출력됨"
else
  fail "Check 1b: install drift 경고 미출력 — out=$out1"
fi

if [ -d "$F1/specs/spec-x-foo" ]; then
  ok "Check 1c: spec-x-foo 디렉토리 생성됨"
else
  fail "Check 1c: spec-x-foo 디렉토리 미생성"
fi
rm -rf "$F1"

# ─────────────────────────────────────────────────────────
# Check 2: clean 상태 → 경고 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Check 2: clean 워킹트리에서 specx new → install drift 경고 없음"
F2="$(make_fixture)"
out2=$(cd "$F2" && bash .harness-kit/bin/sdd specx new bar 2>&1)

if echo "$out2" | grep -qiE '미커밋 install'; then
  fail "Check 2: clean 상태인데 경고 출력 — out=$out2"
else
  ok "Check 2: clean 상태 경고 없음"
fi
rm -rf "$F2"

echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
