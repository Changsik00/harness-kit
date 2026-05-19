#!/usr/bin/env bash
# tests/test-sdd-precheck-config.sh
# spec-18-01: sdd config precheck list/add/remove 검증
#
# T1: precheck add → installed.json 배열에 항목 추가됨
# T2: precheck add 중복 → warn + skip (배열 변화 없음)
# T3: precheck list → 번호와 명령 출력
# T4: precheck remove 1 → 해당 항목 제거됨
# T5: precheck remove 범위 초과 → 오류 메시지 출력
# T6: precheck add + 활성 task.md에 마커 있을 때 → 마커 구간 갱신됨
# T7: precheck add + task.md 마커 없을 때 → warn + 명령은 성공

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-sdd-precheck-config ==="

[ -f "$LIB" ] || { echo "❌ tests/lib/fixture.sh 없음"; exit 1; }
[ -f "$SDD" ] || { echo "❌ sources/bin/sdd 없음"; exit 1; }

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

get_precheck_count() {
  local fx="$1"
  jq '.precheck // [] | length' "$fx/.harness-kit/installed.json" 2>/dev/null || echo "0"
}

get_precheck_item() {
  local fx="$1" idx="$2"
  jq -r --argjson i "$idx" '.precheck // [] | .[$i] // ""' "$fx/.harness-kit/installed.json" 2>/dev/null || echo ""
}

# ─────────────────────────────────────────────────────────
# T1: precheck add → installed.json 배열에 항목 추가됨
# ─────────────────────────────────────────────────────────
echo ""
echo "T1: precheck add → installed.json 배열에 항목 추가됨"
F1=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F1")

run_sdd "$F1" config precheck add "npm run lint" >/dev/null
COUNT1=$(get_precheck_count "$F1")
ITEM1=$(get_precheck_item "$F1" 0)
if [ "$COUNT1" = "1" ] && [ "$ITEM1" = "npm run lint" ]; then
  ok "installed.json precheck[0] = 'npm run lint'"
else
  fail "add 실패 — count=$COUNT1, item=$ITEM1"
fi

# ─────────────────────────────────────────────────────────
# T2: precheck add 중복 → warn + skip (배열 변화 없음)
# ─────────────────────────────────────────────────────────
echo ""
echo "T2: precheck add 중복 → warn + skip"
F2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F2")

run_sdd "$F2" config precheck add "npm run lint" >/dev/null
OUT2=$(run_sdd "$F2" config precheck add "npm run lint" 2>&1)
COUNT2=$(get_precheck_count "$F2")
if [ "$COUNT2" = "1" ] && echo "$OUT2" | grep -qi "중복\|already\|skip"; then
  ok "중복 add: 배열 변화 없음 + 경고 출력"
else
  fail "중복 add 처리 실패 — count=$COUNT2, 출력: $OUT2"
fi

# ─────────────────────────────────────────────────────────
# T3: precheck list → 번호와 명령 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T3: precheck list → 번호와 명령 출력"
F3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F3")

run_sdd "$F3" config precheck add "npm run lint" >/dev/null
run_sdd "$F3" config precheck add "npm run typecheck" >/dev/null
OUT3=$(run_sdd "$F3" config precheck list)
if echo "$OUT3" | grep -q "npm run lint" && echo "$OUT3" | grep -q "npm run typecheck"; then
  ok "list: 두 명령 모두 출력됨"
else
  fail "list 출력 실패 — 실제: $OUT3"
fi

# 빈 상태 목록
F3B=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F3B")
OUT3B=$(run_sdd "$F3B" config precheck list)
if echo "$OUT3B" | grep -qi "없음\|empty\|0"; then
  ok "list: 비어있으면 '없음' 출력"
else
  fail "빈 list 출력 실패 — 실제: $OUT3B"
fi

# ─────────────────────────────────────────────────────────
# T4: precheck remove 1 → 해당 항목 제거됨
# ─────────────────────────────────────────────────────────
echo ""
echo "T4: precheck remove 1 → 해당 항목 제거됨"
F4=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F4")

run_sdd "$F4" config precheck add "npm run lint" >/dev/null
run_sdd "$F4" config precheck add "npm run typecheck" >/dev/null
run_sdd "$F4" config precheck remove 1 >/dev/null
COUNT4=$(get_precheck_count "$F4")
ITEM4=$(get_precheck_item "$F4" 0)
if [ "$COUNT4" = "1" ] && [ "$ITEM4" = "npm run typecheck" ]; then
  ok "remove 1: 첫 항목 제거됨, 나머지 유지"
else
  fail "remove 실패 — count=$COUNT4, 남은 item=$ITEM4"
fi

# ─────────────────────────────────────────────────────────
# T5: precheck remove 범위 초과 → 오류 메시지 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T5: precheck remove 범위 초과 → 오류 출력"
F5=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F5")

run_sdd "$F5" config precheck add "npm run lint" >/dev/null
OUT5=$(run_sdd "$F5" config precheck remove 99 2>&1 || true)
COUNT5=$(get_precheck_count "$F5")
if echo "$OUT5" | grep -qi "범위\|out.*range\|invalid\|오류\|error" && [ "$COUNT5" = "1" ]; then
  ok "범위 초과: 오류 출력 + 배열 변화 없음"
else
  fail "범위 초과 처리 실패 — count=$COUNT5, 출력: $OUT5"
fi

# ─────────────────────────────────────────────────────────
# T6: precheck add + 활성 task.md에 마커 있을 때 → 마커 구간 갱신됨
# ─────────────────────────────────────────────────────────
echo ""
echo "T6: precheck add + task.md 마커 있을 때 → 마커 구간 갱신됨"
F6=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F6")

with_in_flight_phase "$F6" "phase-01" "spec-01-01-foo"
TASK_FILE="$F6/specs/spec-01-01-foo/task.md"
cat > "$TASK_FILE" <<'TASKEOF'
# Task List: spec-01-01

## Pre-check

<!-- sdd:precheck:start -->
<!-- precheck 미설정 -->
<!-- sdd:precheck:end -->

## Task N: Ship
TASKEOF

run_sdd "$F6" config precheck add "npm run lint" >/dev/null
TASK_CONTENT=$(cat "$TASK_FILE")
if echo "$TASK_CONTENT" | grep -q "npm run lint"; then
  ok "task.md 마커 구간에 'npm run lint' 삽입됨"
else
  fail "task.md 마커 갱신 실패 — task.md 내용:\n$TASK_CONTENT"
fi

# ─────────────────────────────────────────────────────────
# T7: precheck add + task.md 마커 없을 때 → warn + 명령은 성공
# ─────────────────────────────────────────────────────────
echo ""
echo "T7: precheck add + task.md 마커 없을 때 → warn + 성공"
F7=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F7")

with_in_flight_phase "$F7" "phase-01" "spec-01-01-bar"
TASK_FILE7="$F7/specs/spec-01-01-bar/task.md"
cat > "$TASK_FILE7" <<'TASKEOF'
# Task List: spec-01-01

## Task N: Ship
- [ ] push
TASKEOF

OUT7=$(run_sdd "$F7" config precheck add "npm run lint" 2>&1)
COUNT7=$(get_precheck_count "$F7")
if [ "$COUNT7" = "1" ] && echo "$OUT7" | grep -qi "warn\|마커\|없음\|skip"; then
  ok "마커 없음: warn 출력 + installed.json 갱신 성공"
else
  fail "마커 없음 처리 실패 — count=$COUNT7, 출력: $OUT7"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
