#!/usr/bin/env bash
# tests/test-turbo-hooks.sh
# spec-21-02: Turbo 모드 훅 분기 + post-commit-verify 검증
#
# 8 케이스:
#   T01: check-plan-accept — turbo 시 exit 0 (무조건 통과)
#   T02: check-plan-accept — governed + plan 미승인 + active spec → violation 출력
#   T03: check-scope — turbo 시 exit 0 (무조건 통과)
#   T04: check-scope — governed + plan 승인 + scope 이탈 → violation 출력
#   T05: post-commit-verify — governed 시 exit 0 (no-op)
#   T06: post-commit-verify — turbo + precheck 없음 → exit 0 (no-op)
#   T07: post-commit-verify — turbo + precheck PASS → exit 0, 통과 메시지
#   T08: post-commit-verify — turbo + precheck FAIL → revert 후 exit 0

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-turbo-hooks ==="

if [ ! -f "$LIB" ]; then
  fail "tests/lib/fixture.sh 없음"
  exit 1
fi

source "$LIB"

FIXTURES_TO_CLEAN=()
cleanup() {
  local d
  for d in "${FIXTURES_TO_CLEAN[@]:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
  done
}
trap cleanup EXIT

# 훅 실행 헬퍼 — cwd를 fixture 로 설정 후 hook 실행 (HARNESS_ROOT=fixture)
run_hook() {
  local fx="$1"
  local hook="$2"
  shift 2
  ( cd "$fx" && env "$@" bash "$fx/.harness-kit/hooks/${hook}.sh" 2>&1 )
}

# state 설정 헬퍼 — current.json 에 키 설정
set_state() {
  local fx="$1"
  local key="$2"
  local val="$3"
  local state="$fx/.claude/state/current.json"
  local tmp
  tmp=$(mktemp)
  jq --arg k "$key" --arg v "$val" '.[$k] = $v' "$state" > "$tmp"
  mv "$tmp" "$state"
}

# boolean state 설정
set_state_bool() {
  local fx="$1"
  local key="$2"
  local val="$3"  # true / false
  local state="$fx/.claude/state/current.json"
  local tmp
  tmp=$(mktemp)
  jq --arg k "$key" --argjson v "$val" '.[$k] = $v' "$state" > "$tmp"
  mv "$tmp" "$state"
}

# precheck 주입 헬퍼 — installed.json 에 precheck 배열 설정
set_precheck() {
  local fx="$1"
  local cmd="$2"
  local inst="$fx/.harness-kit/installed.json"
  local tmp
  tmp=$(mktemp)
  jq --arg c "$cmd" '.precheck = [$c]' "$inst" > "$tmp"
  mv "$tmp" "$inst"
}

# plan.md 생성 헬퍼 (scope 테스트용)
make_plan_with_scope() {
  local fx="$1"
  local spec="$2"
  local scoped_file="$3"
  mkdir -p "$fx/specs/$spec"
  cat > "$fx/specs/$spec/plan.md" <<PLAN
# Implementation Plan

## Proposed Changes

#### [MODIFY] \`$scoped_file\`
test scope
PLAN
}

# ─────────────────────────────────────────────────────────
# T01: check-plan-accept — turbo 시 exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "T01: check-plan-accept — turbo 시 exit 0"
FX=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX")

# turbo 모드 설정, planAccepted=false, active spec
set_state "$FX" mode "turbo"
with_in_flight_phase "$FX" "phase-99" "spec-99-01-test"
set_state_bool "$FX" planAccepted false

out=$(run_hook "$FX" check-plan-accept \
  "TOOL_INPUT_file_path=src/app.ts" 2>&1) || true
if echo "$out" | grep -q "hook:warn\|hook:block"; then
  fail "T01: turbo 모드에서 violation 발생 — got: $out"
else
  ok "T01: turbo 모드 — check-plan-accept 무조건 통과"
fi

# ─────────────────────────────────────────────────────────
# T02: check-plan-accept — governed + plan 미승인 + active spec → violation
# ─────────────────────────────────────────────────────────
echo ""
echo "T02: check-plan-accept — governed + plan 미승인 → violation"
FX2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX2")

set_state "$FX2" mode "governed"
with_in_flight_phase "$FX2" "phase-99" "spec-99-01-test"
set_state_bool "$FX2" planAccepted false

out2=$(run_hook "$FX2" check-plan-accept \
  "TOOL_INPUT_file_path=src/app.ts" 2>&1) || true
if echo "$out2" | grep -q "hook:warn\|hook:block"; then
  ok "T02: governed + plan 미승인 → violation 출력"
else
  fail "T02: governed + plan 미승인인데 violation 없음 — got: $out2"
fi

# ─────────────────────────────────────────────────────────
# T03: check-scope — turbo 시 exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "T03: check-scope — turbo 시 exit 0"
FX3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX3")

set_state "$FX3" mode "turbo"
with_in_flight_phase "$FX3" "phase-99" "spec-99-01-test"
set_state_bool "$FX3" planAccepted true
make_plan_with_scope "$FX3" "spec-99-01-test" "src/allowed.ts"

out3=$(run_hook "$FX3" check-scope \
  "TOOL_INPUT_file_path=other/out-of-scope.ts" 2>&1) || true
if echo "$out3" | grep -q "hook:warn\|hook:block"; then
  fail "T03: turbo 모드에서 scope violation 발생 — got: $out3"
else
  ok "T03: turbo 모드 — check-scope 무조건 통과"
fi

# ─────────────────────────────────────────────────────────
# T04: check-scope — governed + plan 승인 + scope 이탈 → violation
# ─────────────────────────────────────────────────────────
echo ""
echo "T04: check-scope — governed + plan 승인 + scope 이탈 → violation"
FX4=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX4")

set_state "$FX4" mode "governed"
with_in_flight_phase "$FX4" "phase-99" "spec-99-01-test"
set_state_bool "$FX4" planAccepted true
make_plan_with_scope "$FX4" "spec-99-01-test" "src/allowed.ts"

out4=$(run_hook "$FX4" check-scope \
  "TOOL_INPUT_file_path=other/out-of-scope.ts" 2>&1) || true
if echo "$out4" | grep -q "hook:warn\|hook:block"; then
  ok "T04: governed + scope 이탈 → violation 출력"
else
  fail "T04: governed + scope 이탈인데 violation 없음 — got: $out4"
fi

# ─────────────────────────────────────────────────────────
# T05: post-commit-verify — governed 시 exit 0 (no-op)
# ─────────────────────────────────────────────────────────
echo ""
echo "T05: post-commit-verify — governed 시 exit 0"
FX5=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX5")

set_state "$FX5" mode "governed"
exit5=0
( cd "$FX5" && bash "$FX5/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ) || exit5=$?
if [ "$exit5" -eq 0 ]; then
  ok "T05: governed — post-commit-verify no-op (exit 0)"
else
  fail "T05: governed — post-commit-verify exit $exit5 (기대: 0)"
fi

# ─────────────────────────────────────────────────────────
# T06: post-commit-verify — turbo + precheck 없음 → exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "T06: post-commit-verify — turbo + precheck 없음 → exit 0"
FX6=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX6")

set_state "$FX6" mode "turbo"
# precheck 미설정 (installed.json 기본값 그대로)
exit6=0
( cd "$FX6" && bash "$FX6/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ) || exit6=$?
if [ "$exit6" -eq 0 ]; then
  ok "T06: turbo + precheck 없음 — no-op (exit 0)"
else
  fail "T06: turbo + precheck 없음인데 exit $exit6 (기대: 0)"
fi

# ─────────────────────────────────────────────────────────
# T07: post-commit-verify — turbo + precheck PASS → exit 0, 통과 메시지
# ─────────────────────────────────────────────────────────
echo ""
echo "T07: post-commit-verify — turbo + precheck PASS → exit 0"
FX7=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX7")

set_state "$FX7" mode "turbo"
set_precheck "$FX7" "true"  # always-pass precheck

# 최근 커밋 생성 (10분 이내)
echo "test" > "$FX7/test-verify-file.txt"
git -C "$FX7" add test-verify-file.txt
git -C "$FX7" commit -m "test: turbo verify" -q

out7=""
exit7=0
out7=$( cd "$FX7" && bash "$FX7/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ) || exit7=$?
if [ "$exit7" -eq 0 ] && echo "$out7" | grep -q "turbo:verify\|검증 통과"; then
  ok "T07: precheck PASS — exit 0 + 통과 메시지"
else
  fail "T07: precheck PASS 기대, exit=$exit7, out=$out7"
fi

# ─────────────────────────────────────────────────────────
# T08: post-commit-verify — turbo + precheck FAIL → revert 후 exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "T08: post-commit-verify — turbo + precheck FAIL → revert"
FX8=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX8")

set_state "$FX8" mode "turbo"
set_precheck "$FX8" "false"  # always-fail precheck

# 최근 커밋 생성 (10분 이내)
echo "buggy code" > "$FX8/buggy.txt"
git -C "$FX8" add buggy.txt
git -C "$FX8" commit -m "feat: introduce bug" -q

commit_before=$(git -C "$FX8" log --oneline | wc -l | tr -d ' ')

out8=""
exit8=0
out8=$( cd "$FX8" && bash "$FX8/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ) || exit8=$?
commit_after=$(git -C "$FX8" log --oneline | wc -l | tr -d ' ')

if [ "$exit8" -eq 0 ] && [ "$commit_after" -gt "$commit_before" ]; then
  ok "T08: precheck FAIL → revert commit 생성 + exit 0"
else
  fail "T08: 기대: exit 0 + revert commit. 실제: exit=$exit8, before=$commit_before after=$commit_after"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "=== 결과: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
