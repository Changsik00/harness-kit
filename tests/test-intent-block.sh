#!/usr/bin/env bash
# tests/test-intent-block.sh
# spec-21-03: sdd intent 커맨드 + post-commit-verify intent 연동
#
# 9 케이스:
#   T01: sdd intent "<goal>" → intent.yaml 에 goal 기록
#   T02: sdd intent "<goal>" --test "<cmd>" → goal + test 기록
#   T03: sdd intent "<goal>" --files "<a,b>" → goal + files 기록
#   T04: sdd intent show → 내용 출력 (goal/test/files)
#   T05: sdd intent show (intent 없음) → 안내 메시지
#   T06: sdd intent clear → intent.yaml 삭제
#   T07: sdd status → Active Intent 행 포함
#   T08: post-commit-verify — turbo + intent.test PASS → exit 0
#   T09: post-commit-verify — turbo + intent.test FAIL → revert

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-intent-block ==="

if [ ! -f "$LIB" ]; then
  fail "tests/lib/fixture.sh 없음"
  exit 1
fi
if [ ! -f "$SDD" ]; then
  fail "sources/bin/sdd 없음"
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

run_sdd() {
  local fx="$1"; shift
  ( cd "$fx" && HARNESS_DRIFT_FETCH=0 bash "$SDD" "$@" 2>&1 )
}

get_intent_field() {
  local fx="$1" field="$2"
  local intent="$fx/.claude/state/intent.yaml"
  [ -f "$intent" ] || { echo ""; return; }
  grep -E "^${field}:" "$intent" | sed "s/^${field}:[[:space:]]*//" | head -1
}

set_state() {
  local fx="$1" key="$2" val="$3"
  local state="$fx/.claude/state/current.json"
  local tmp; tmp=$(mktemp)
  jq --arg k "$key" --arg v "$val" '.[$k] = $v' "$state" > "$tmp"
  mv "$tmp" "$state"
}

set_precheck() {
  local fx="$1" cmd="$2"
  local inst="$fx/.harness-kit/installed.json"
  local tmp; tmp=$(mktemp)
  jq --arg c "$cmd" '.precheck = [$c]' "$inst" > "$tmp"
  mv "$tmp" "$inst"
}

# ─────────────────────────────────────────────────────────
# T01: sdd intent "<goal>" → intent.yaml goal 기록
# ─────────────────────────────────────────────────────────
echo ""
echo "T01: sdd intent \"목표\" → intent.yaml goal 기록"
FX1=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX1")

run_sdd "$FX1" intent "fix the turbo hook bypass" >/dev/null 2>&1 || true
goal1=$(get_intent_field "$FX1" goal)
if [ "$goal1" = "fix the turbo hook bypass" ]; then
  ok "T01: intent.yaml goal 기록됨"
else
  fail "T01: intent.yaml goal 기대='fix the turbo hook bypass', 실제='$goal1'"
fi

# ─────────────────────────────────────────────────────────
# T02: sdd intent "<goal>" --test "<cmd>" → goal + test 기록
# ─────────────────────────────────────────────────────────
echo ""
echo "T02: sdd intent \"목표\" --test \"cmd\" → goal + test 기록"
FX2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX2")

run_sdd "$FX2" intent "add new feature" --test "bash tests/run.sh" >/dev/null 2>&1 || true
goal2=$(get_intent_field "$FX2" goal)
test2=$(get_intent_field "$FX2" test)
if [ "$goal2" = "add new feature" ] && [ "$test2" = "bash tests/run.sh" ]; then
  ok "T02: intent.yaml goal + test 기록됨"
else
  fail "T02: goal='$goal2' test='$test2' (기대: 'add new feature' / 'bash tests/run.sh')"
fi

# ─────────────────────────────────────────────────────────
# T03: sdd intent "<goal>" --files "<a,b>" → goal + files 기록
# ─────────────────────────────────────────────────────────
echo ""
echo "T03: sdd intent \"목표\" --files \"a,b\" → goal + files 기록"
FX3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX3")

run_sdd "$FX3" intent "refactor hooks" --files "src/a.sh,src/b.sh" >/dev/null 2>&1 || true
goal3=$(get_intent_field "$FX3" goal)
files3=$(get_intent_field "$FX3" files)
if [ "$goal3" = "refactor hooks" ] && [ "$files3" = "src/a.sh,src/b.sh" ]; then
  ok "T03: intent.yaml goal + files 기록됨"
else
  fail "T03: goal='$goal3' files='$files3' (기대: 'refactor hooks' / 'src/a.sh,src/b.sh')"
fi

# ─────────────────────────────────────────────────────────
# T04: sdd intent show → 내용 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T04: sdd intent show → intent 내용 출력"
FX4=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX4")

run_sdd "$FX4" intent "show test goal" --test "true" >/dev/null 2>&1 || true
out4=$(run_sdd "$FX4" intent show 2>&1)
if echo "$out4" | grep -q "show test goal"; then
  ok "T04: sdd intent show — goal 출력"
else
  fail "T04: sdd intent show 에 goal 없음 — got: $out4"
fi

# ─────────────────────────────────────────────────────────
# T05: sdd intent show (intent 없음) → 안내 메시지
# ─────────────────────────────────────────────────────────
echo ""
echo "T05: sdd intent show (intent 없음) → 안내 메시지"
FX5=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX5")

out5=$(run_sdd "$FX5" intent show 2>&1)
if echo "$out5" | grep -qiE "없음|no intent|not set|설정되지"; then
  ok "T05: intent 없을 때 안내 메시지 출력"
else
  fail "T05: 안내 메시지 없음 — got: $out5"
fi

# ─────────────────────────────────────────────────────────
# T06: sdd intent clear → intent.yaml 삭제
# ─────────────────────────────────────────────────────────
echo ""
echo "T06: sdd intent clear → intent.yaml 삭제"
FX6=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX6")

run_sdd "$FX6" intent "to be cleared" >/dev/null 2>&1 || true
run_sdd "$FX6" intent clear >/dev/null 2>&1 || true
if [ ! -f "$FX6/.claude/state/intent.yaml" ]; then
  ok "T06: sdd intent clear — intent.yaml 삭제됨"
else
  fail "T06: sdd intent clear 후에도 intent.yaml 존재"
fi

# ─────────────────────────────────────────────────────────
# T07: sdd status → Active Intent 행 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T07: sdd status → Active Intent 행 포함"
FX7=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX7")

run_sdd "$FX7" intent "status display test" >/dev/null 2>&1 || true
out7=$(run_sdd "$FX7" status 2>&1)
if echo "$out7" | grep -qi "active intent\|Active Intent"; then
  ok "T07: sdd status 에 Active Intent 행 있음"
else
  fail "T07: sdd status 에 Active Intent 행 없음 — got 일부: $(echo "$out7" | head -15)"
fi

# ─────────────────────────────────────────────────────────
# T08: post-commit-verify — turbo + intent.test PASS → exit 0
# ─────────────────────────────────────────────────────────
echo ""
echo "T08: post-commit-verify — turbo + intent.test PASS → exit 0"
FX8=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX8")

set_state "$FX8" mode "turbo"

# intent.yaml 직접 작성 (sources/bin/sdd 아직 미구현 대비)
mkdir -p "$FX8/.claude/state"
cat > "$FX8/.claude/state/intent.yaml" <<'YAML'
goal: test intent integration
test: true
YAML

# 최근 커밋 생성
echo "test" > "$FX8/test-file.txt"
git -C "$FX8" add test-file.txt
git -C "$FX8" commit -m "test: intent verify" -q

out8=""
exit8=0
out8=$( cd "$FX8" && bash "$FX8/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ) || exit8=$?
if [ "$exit8" -eq 0 ] && echo "$out8" | grep -q "turbo:verify\|검증 통과"; then
  ok "T08: intent.test PASS — exit 0 + 통과 메시지"
else
  fail "T08: intent.test PASS 기대, exit=$exit8, out=$out8"
fi

# ─────────────────────────────────────────────────────────
# T09: post-commit-verify — turbo + intent.test FAIL → revert
# ─────────────────────────────────────────────────────────
echo ""
echo "T09: post-commit-verify — turbo + intent.test FAIL → revert"
FX9=$(make_fixture)
FIXTURES_TO_CLEAN+=("$FX9")

set_state "$FX9" mode "turbo"

mkdir -p "$FX9/.claude/state"
cat > "$FX9/.claude/state/intent.yaml" <<'YAML'
goal: test auto revert
test: false
YAML

# 최근 커밋 생성
echo "buggy" > "$FX9/buggy.txt"
git -C "$FX9" add buggy.txt
git -C "$FX9" commit -m "feat: buggy commit" -q

before=$(git -C "$FX9" log --oneline | wc -l | tr -d ' ')

exit9=0
( cd "$FX9" && bash "$FX9/.harness-kit/hooks/post-commit-verify.sh" 2>&1 ) || exit9=$?
after=$(git -C "$FX9" log --oneline | wc -l | tr -d ' ')

if [ "$exit9" -eq 0 ] && [ "$after" -gt "$before" ]; then
  ok "T09: intent.test FAIL → revert commit 생성 + exit 0"
else
  fail "T09: 기대: exit 0 + revert commit. 실제: exit=$exit9, before=$before after=$after"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "=== 결과: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
