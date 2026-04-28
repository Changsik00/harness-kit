#!/usr/bin/env bash
# tests/test-fixture-lib.sh
# spec-15-02: tests/lib/fixture.sh 의 make_fixture + 5 mixin 검증

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

# ─────────────────────────────────────────────────────────
# 사전 — lib 존재 확인 (Red 단계에서는 fail)
# ─────────────────────────────────────────────────────────
echo "=== test-fixture-lib ==="
if [ ! -f "$LIB" ]; then
  fail "tests/lib/fixture.sh 가 존재하지 않음 — spec-15-02 미구현"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  결과: PASS=$PASS  FAIL=$FAIL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi

# shellcheck source=lib/fixture.sh
source "$LIB"

FIXTURES_TO_CLEAN=()
cleanup() {
  local d
  for d in "${FIXTURES_TO_CLEAN[@]:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
  done
}
trap cleanup EXIT

# ─────────────────────────────────────────────────────────
# Check 그룹 1: make_fixture (3 checks)
# ─────────────────────────────────────────────────────────
echo ""
echo "Group 1: make_fixture"

F1=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F1")

[ -d "$F1" ]                                  && ok "디렉토리 존재"   || fail "디렉토리 없음: $F1"
[ -d "$F1/.harness-kit" ]                     && ok ".harness-kit/ 존재" || fail ".harness-kit/ 없음"
[ -f "$F1/.claude/state/current.json" ]       && ok "state.json 존재"     || fail "state.json 없음"

# ─────────────────────────────────────────────────────────
# Check 그룹 2: with_in_flight_phase (4 checks)
# ─────────────────────────────────────────────────────────
echo ""
echo "Group 2: with_in_flight_phase"

F2=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F2")
with_in_flight_phase "$F2" "phase-08" "spec-08-03-stock-lock"

phase=$(jq -r '.phase' "$F2/.claude/state/current.json")
spec=$(jq -r '.spec'  "$F2/.claude/state/current.json")
[ "$phase" = "phase-08" ]                      && ok "state.phase=phase-08"                  || fail "state.phase=$phase"
[ "$spec"  = "spec-08-03-stock-lock" ]         && ok "state.spec 일치"                        || fail "state.spec=$spec"
[ -f "$F2/backlog/phase-08.md" ]               && ok "phase-08.md 생성"                       || fail "phase-08.md 없음"
[ -d "$F2/specs/spec-08-03-stock-lock" ]       && ok "specs/ 디렉토리 생성"                   || fail "spec 디렉토리 없음"

# ─────────────────────────────────────────────────────────
# Check 그룹 3: with_pre_defined_phases (3 checks)
# ─────────────────────────────────────────────────────────
echo ""
echo "Group 3: with_pre_defined_phases"

F3=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F3")
with_pre_defined_phases "$F3" "phase-09" "phase-10" "phase-11"

[ -f "$F3/backlog/phase-09.md" ] && [ -f "$F3/backlog/phase-10.md" ] && [ -f "$F3/backlog/phase-11.md" ] \
  && ok "3개 phase 파일 모두 생성" || fail "phase 파일 일부 누락"
grep -q "사전 정의" "$F3/backlog/phase-09.md" \
  && ok "phase 본문에 식별 마커 포함" || fail "마커 부재"
# 가변 인자 — 단일 인자도 동작
F3b=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F3b")
with_pre_defined_phases "$F3b" "phase-99"
[ -f "$F3b/backlog/phase-99.md" ] && ok "단일 인자 가변 호출 정상" || fail "단일 인자 처리 실패"

# ─────────────────────────────────────────────────────────
# Check 그룹 4: with_customized_fragment (2 checks)
# ─────────────────────────────────────────────────────────
echo ""
echo "Group 4: with_customized_fragment"

F4=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F4")
fragment_before=$(wc -l < "$F4/.harness-kit/CLAUDE.fragment.md")
with_customized_fragment "$F4"

grep -q "TEST_USER_FRAGMENT" "$F4/.harness-kit/CLAUDE.fragment.md" \
  && ok "TEST_USER_FRAGMENT 마커 존재" || fail "마커 부재"
fragment_after=$(wc -l < "$F4/.harness-kit/CLAUDE.fragment.md")
[ "$fragment_after" -gt "$fragment_before" ] \
  && ok "기존 본문 보존 (라인 수 증가)" || fail "라인 수 비정상"

# ─────────────────────────────────────────────────────────
# Check 그룹 5: with_dirty_queue_icebox (2 checks)
# ─────────────────────────────────────────────────────────
echo ""
echo "Group 5: with_dirty_queue_icebox"

F5=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F5")
with_dirty_queue_icebox "$F5"

grep -q "TEST_USER_ICEBOX_NOTE" "$F5/backlog/queue.md" \
  && ok "Icebox 마커 존재" || fail "Icebox 마커 부재"
# sdd:active:start 마커가 손상되지 않았는지
grep -q "sdd:active:start" "$F5/backlog/queue.md" && grep -q "sdd:active:end" "$F5/backlog/queue.md" \
  && ok "sdd 마커 영역 손상 없음" || fail "sdd 마커 손상"

# ─────────────────────────────────────────────────────────
# Check 그룹 6: with_user_hook (2 checks)
# ─────────────────────────────────────────────────────────
echo ""
echo "Group 6: with_user_hook"

F6=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F6")
hooks_before=$(jq '.hooks | keys | length' "$F6/.claude/settings.json")
with_user_hook "$F6"

has_user_hook=$(jq 'has("hooks") and (.hooks | has("UserAddedHook"))' "$F6/.claude/settings.json")
[ "$has_user_hook" = "true" ] \
  && ok "UserAddedHook 키 존재" || fail "UserAddedHook 부재"
hooks_after=$(jq '.hooks | keys | length' "$F6/.claude/settings.json")
[ "$hooks_after" -gt "$hooks_before" ] \
  && ok "기존 hooks 보존 (키 수 증가)" || fail "기존 hooks 손상"

# ─────────────────────────────────────────────────────────
# Check 그룹 7: 조합 (2 checks)
# ─────────────────────────────────────────────────────────
echo ""
echo "Group 7: 조합 — in_flight + dirty_queue + user_hook"

F7=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F7")
with_in_flight_phase     "$F7" "phase-08" "spec-08-03-combo"
with_dirty_queue_icebox  "$F7"
with_user_hook           "$F7"

phase=$(jq -r '.phase' "$F7/.claude/state/current.json")
icebox_ok=0; grep -q "TEST_USER_ICEBOX_NOTE" "$F7/backlog/queue.md" && icebox_ok=1
hook_ok=$(jq -r '.hooks | has("UserAddedHook")' "$F7/.claude/settings.json")
[ "$phase" = "phase-08" ] && [ $icebox_ok -eq 1 ] && [ "$hook_ok" = "true" ] \
  && ok "3 mixin 동시 적용 모두 정상" || fail "조합 실패: phase=$phase icebox=$icebox_ok hook=$hook_ok"
# 조합 후에도 phase.md / spec 디렉토리 정상
[ -f "$F7/backlog/phase-08.md" ] && [ -d "$F7/specs/spec-08-03-combo" ] \
  && ok "조합 후 in_flight 산출물 보존" || fail "in_flight 산출물 손상"

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
