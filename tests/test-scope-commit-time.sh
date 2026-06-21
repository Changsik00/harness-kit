#!/usr/bin/env bash
set -uo pipefail

# test-scope-commit-time.sh
# spec-24-02: blast-radius scope 가드 커밋시점 정렬
#   - _scope.sh 순수 함수 (안전경로/패턴 추출/in-scope 판정)
#   - pre-commit.sh 커밋시점 scope 경고 (경고 모드 — exit 0 유지)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCOPE_LIB="$ROOT/sources/hooks/_scope.sh"
PRECOMMIT="$ROOT/sources/hooks/pre-commit.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

echo "═══════════════════════════════════════════════════════"
echo " test-scope-commit-time (spec-24-02)"
echo "═══════════════════════════════════════════════════════"

_make_repo() {
  local d; d="$(mktemp -d)"; CLEANUP+=("$d")
  git -C "$d" init -q
  git -C "$d" checkout -b main 2>/dev/null || true
  git -C "$d" config user.email "test@local"
  git -C "$d" config user.name "test"
  echo "$d"
}

# 활성 spec + spec.md(Proposed Changes scope = a.sh) 주입
# 사용법: _inject <repo> <spec>
_inject() {
  local repo="$1" spec="$2"
  mkdir -p "$repo/.claude/state" "$repo/.harness-kit/hooks" "$repo/specs/$spec"
  printf '{"planAccepted":true,"spec":"%s"}' "$spec" > "$repo/.claude/state/current.json"
  cp "$SCOPE_LIB" "$repo/.harness-kit/hooks/" 2>/dev/null || true
  cp "$PRECOMMIT" "$repo/.harness-kit/hooks/pre-commit.sh"
  chmod +x "$repo/.harness-kit/hooks/"*.sh 2>/dev/null || true
  cat > "$repo/specs/$spec/spec.md" <<'EOF'
# spec test
## Proposed Changes
#### [MODIFY] `a.sh`
EOF
}

# 공용 plan 파일 (함수 단위 테스트용)
PLAN_DIR="$(mktemp -d)"; CLEANUP+=("$PLAN_DIR")
cat > "$PLAN_DIR/spec.md" <<'EOF'
## Proposed Changes
#### [MODIFY] `a.sh`
#### [NEW] `lib/util.sh`
EOF
PLAN="$PLAN_DIR/spec.md"

# ─────────────────────────────────────────────────────────
# Test 1: _scope.sh 존재
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 1: sources/hooks/_scope.sh 존재"
if [ -f "$SCOPE_LIB" ]; then
  ok "Test 1: _scope.sh 존재"
else
  fail "Test 1: _scope.sh 없음 ($SCOPE_LIB)"
fi

# ─────────────────────────────────────────────────────────
# Test 2: scope_path_in_scope — scope 패턴 매칭 → in-scope(0)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 2: scope_path_in_scope 'a.sh' → in-scope (0)"
( source "$SCOPE_LIB" >/dev/null 2>&1 && scope_path_in_scope "a.sh" "$PLAN" )
if [ $? -eq 0 ]; then
  ok "Test 2: scope 내 파일 → 0"
else
  fail "Test 2: scope 내 파일인데 0 아님"
fi

# ─────────────────────────────────────────────────────────
# Test 3: scope_path_in_scope — scope 밖 → out-of-scope(1)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 3: scope_path_in_scope 'b.sh' → out-of-scope (1)"
( source "$SCOPE_LIB" >/dev/null 2>&1 && scope_path_in_scope "b.sh" "$PLAN" )
if [ $? -ne 0 ]; then
  ok "Test 3: scope 밖 파일 → non-zero"
else
  fail "Test 3: scope 밖 파일인데 0 (통과 처리됨)"
fi

# ─────────────────────────────────────────────────────────
# Test 4: scope_is_safe_path — 안전경로 판정
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 4: scope_is_safe_path (README.md 안전 / x.sh 비안전)"
_t4=0
( source "$SCOPE_LIB" >/dev/null 2>&1 && scope_is_safe_path "README.md" ) || _t4=1
( source "$SCOPE_LIB" >/dev/null 2>&1 && scope_is_safe_path "x.sh" ) && _t4=1
if [ "$_t4" -eq 0 ]; then
  ok "Test 4: 안전경로 판정 정확"
else
  fail "Test 4: 안전경로 판정 오류"
fi

# ─────────────────────────────────────────────────────────
# Test 5: pre-commit — scope 밖 staged → stderr 경고 + exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 5: pre-commit scope 밖 파일 staged → 경고 + exit 0(미차단)"
REPO5="$(_make_repo)"
_inject "$REPO5" "spec-24-02-scope-commit-time"
echo "echo out" > "$REPO5/b.sh"
git -C "$REPO5" add b.sh
err5="$(HARNESS_ROOT="$REPO5" bash "$REPO5/.harness-kit/hooks/pre-commit.sh" 2>&1 1>/dev/null)"
rc5=$?
if [ "$rc5" -eq 0 ] && echo "$err5" | grep -qi "scope"; then
  ok "Test 5: scope 밖 → 경고 출력 + exit 0"
else
  fail "Test 5: 경고($(echo "$err5" | grep -ic scope)) 또는 exit($rc5) 기대 불일치"
fi

# ─────────────────────────────────────────────────────────
# Test 6: pre-commit — scope 내 staged → 경고 없음 + exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 6: pre-commit scope 내 파일 staged → 무경고 + exit 0"
REPO6="$(_make_repo)"
_inject "$REPO6" "spec-24-02-scope-commit-time"
echo "echo in" > "$REPO6/a.sh"
git -C "$REPO6" add a.sh
err6="$(HARNESS_ROOT="$REPO6" bash "$REPO6/.harness-kit/hooks/pre-commit.sh" 2>&1 1>/dev/null)"
rc6=$?
if [ "$rc6" -eq 0 ] && ! echo "$err6" | grep -qi "scope"; then
  ok "Test 6: scope 내 → 무경고 + exit 0"
else
  fail "Test 6: 무경고/exit0 기대 불일치 (rc=$rc6)"
fi

# ─────────────────────────────────────────────────────────
# Test 7: spec.md 없음 → scope 검사 no-op + exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 7: spec.md 부재 → scope no-op + exit 0"
REPO7="$(_make_repo)"
_inject "$REPO7" "spec-no-plan"
rm -f "$REPO7/specs/spec-no-plan/spec.md"
echo "echo x" > "$REPO7/b.sh"
git -C "$REPO7" add b.sh
err7="$(HARNESS_ROOT="$REPO7" bash "$REPO7/.harness-kit/hooks/pre-commit.sh" 2>&1 1>/dev/null)"
rc7=$?
if [ "$rc7" -eq 0 ] && ! echo "$err7" | grep -qi "scope"; then
  ok "Test 7: spec.md 부재 → no-op + exit 0"
else
  fail "Test 7: no-op 기대 불일치 (rc=$rc7)"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
