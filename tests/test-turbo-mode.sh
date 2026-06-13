#!/usr/bin/env bash
# tests/test-turbo-mode.sh
# spec-21-05: Turbo 모드 end-to-end 통합 테스트
#
# 4 시나리오:
#   S1 (happy path):    sdd mode turbo → check-plan-accept exit 0 (차단 없음)
#   S2 (auto-revert):   turbo + intent.test FAIL → post-commit-verify revert
#   S3 (governed 복귀): sdd mode governed → check-plan-accept 다시 차단
#   S4 (회귀):          governed 기본 상태 → check-plan-accept 차단

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-turbo-mode (integration) ==="

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

# state 설정 헬퍼
set_state() {
  local fx="$1" key="$2" val="$3"
  local state="$fx/.claude/state/current.json"
  local tmp
  tmp=$(mktemp)
  jq --arg k "$key" --arg v "$val" '.[$k] = $v' "$state" > "$tmp"
  mv "$tmp" "$state"
}

set_state_bool() {
  local fx="$1" key="$2" val="$3"
  local state="$fx/.claude/state/current.json"
  local tmp
  tmp=$(mktemp)
  jq --arg k "$key" --argjson v "$val" '.[$k] = $v' "$state" > "$tmp"
  mv "$tmp" "$state"
}

# sdd CLI 실행 헬퍼 — fixture 루트에서 실행
run_sdd() {
  local fx="$1"; shift
  ( cd "$fx" && bash "$fx/.harness-kit/bin/sdd" "$@" 2>&1 )
}

# hook 실행 헬퍼
run_hook() {
  local fx="$1" hook="$2"; shift 2
  ( cd "$fx" && env "$@" bash "$fx/.harness-kit/hooks/${hook}.sh" 2>&1 )
}

# ─────────────────────────────────────────────────────────
# S1: happy path — sdd mode turbo → check-plan-accept 무차단
# ─────────────────────────────────────────────────────────
echo ""
echo "S1: sdd mode turbo 활성화 → check-plan-accept 통과"
FX1=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX1")

# in-flight spec, planAccepted=false 로 governed 기본 상태 준비
with_in_flight_phase "$FX1" "phase-99" "spec-99-01-test"
set_state_bool "$FX1" planAccepted false

# check: governed 상태에서는 차단
pre=$(run_hook "$FX1" check-plan-accept "TOOL_INPUT_file_path=src/app.ts" 2>&1) || true
if ! echo "$pre" | grep -q "hook:warn\|hook:block"; then
  fail "S1 전제: governed 상태에서 check-plan-accept 차단 안 됨 (fixture 이상)"
  FIXTURES_TO_CLEAN+=()  # keep going
fi

# sdd mode turbo 활성화
run_sdd "$FX1" mode turbo >/dev/null 2>&1

# check: turbo → 통과
out1=$(run_hook "$FX1" check-plan-accept "TOOL_INPUT_file_path=src/app.ts" 2>&1) || true
if echo "$out1" | grep -q "hook:warn\|hook:block"; then
  fail "S1: turbo 모드인데 check-plan-accept 차단 — got: $out1"
else
  ok "S1: sdd mode turbo → check-plan-accept 무차단"
fi

# ─────────────────────────────────────────────────────────
# S2: auto-revert — turbo + intent.test FAIL → revert 수행
# ─────────────────────────────────────────────────────────
echo ""
echo "S2: turbo + intent.test FAIL → post-commit-verify revert"
FX2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX2")

# turbo 모드 활성화
run_sdd "$FX2" mode turbo >/dev/null 2>&1

# intent.yaml 에 실패하는 test 설정
mkdir -p "$FX2/.claude/state"
printf 'goal: test auto-revert\ntest: false\n' > "$FX2/.claude/state/intent.yaml"

# 더미 커밋 생성 (10분 이내)
printf 'change' > "$FX2/buggy.txt"
git -C "$FX2" add buggy.txt
git -C "$FX2" commit -m "feat: introduce bug" -q

commit_before=$(git -C "$FX2" log --oneline | wc -l | tr -d ' ')

# post-commit-verify 실행
out2=""
exit2=0
out2=$( cd "$FX2" && bash "$FX2/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ) || exit2=$?
commit_after=$(git -C "$FX2" log --oneline | wc -l | tr -d ' ')

if [ "$exit2" -eq 0 ] && [ "$commit_after" -gt "$commit_before" ]; then
  ok "S2: intent.test FAIL → revert commit 생성 (before=$commit_before after=$commit_after)"
else
  fail "S2: 기대 exit 0 + revert commit. 실제: exit=$exit2 before=$commit_before after=$commit_after out=$out2"
fi

# ─────────────────────────────────────────────────────────
# S3: governed 복귀 — sdd mode governed → check-plan-accept 다시 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "S3: sdd mode turbo → governed 복귀 → check-plan-accept 차단"
FX3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX3")

with_in_flight_phase "$FX3" "phase-99" "spec-99-01-test"
set_state_bool "$FX3" planAccepted false

# turbo 활성화
run_sdd "$FX3" mode turbo >/dev/null 2>&1
# check: 통과 확인
check_turbo=$(run_hook "$FX3" check-plan-accept "TOOL_INPUT_file_path=src/app.ts" 2>&1) || true
if echo "$check_turbo" | grep -q "hook:warn\|hook:block"; then
  fail "S3 전제: turbo에서 check-plan-accept 차단 (fixture 이상)"
fi

# governed 복귀
run_sdd "$FX3" mode governed >/dev/null 2>&1
# check: 차단 확인
out3=$(run_hook "$FX3" check-plan-accept "TOOL_INPUT_file_path=src/app.ts" 2>&1) || true
if echo "$out3" | grep -q "hook:warn\|hook:block"; then
  ok "S3: governed 복귀 → check-plan-accept 차단 재활성화"
else
  fail "S3: governed 복귀 후 check-plan-accept 차단 안 됨 — got: $out3"
fi

# ─────────────────────────────────────────────────────────
# S4: 회귀 — governed 기본 상태 → check-plan-accept + check-scope 정상 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "S4: governed 기본 → check-plan-accept/check-scope 정상 차단 (회귀)"
FX4=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX4")

with_in_flight_phase "$FX4" "phase-99" "spec-99-01-test"
set_state_bool "$FX4" planAccepted false
# mode 미설정 — governed 기본값

# check-plan-accept 차단
out4a=$(run_hook "$FX4" check-plan-accept "TOOL_INPUT_file_path=src/app.ts" 2>&1) || true
if echo "$out4a" | grep -q "hook:warn\|hook:block"; then
  ok "S4-a: governed 기본 → check-plan-accept 차단"
else
  fail "S4-a: governed 기본인데 check-plan-accept 차단 안 됨 — got: $out4a"
fi

# check-scope 차단: planAccepted=true + 스코프 이탈
set_state_bool "$FX4" planAccepted true
mkdir -p "$FX4/specs/spec-99-01-test"
cat > "$FX4/specs/spec-99-01-test/spec.md" <<'SPEC'
# spec

## Proposed Changes

#### [MODIFY] `src/allowed.ts`
test
SPEC

out4b=$(run_hook "$FX4" check-scope "TOOL_INPUT_file_path=other/not-in-plan.ts" 2>&1) || true
if echo "$out4b" | grep -q "hook:warn\|hook:block"; then
  ok "S4-b: governed 기본 → check-scope 이탈 차단"
else
  fail "S4-b: governed 기본인데 check-scope 차단 안 됨 — got: $out4b"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "=== 결과: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
