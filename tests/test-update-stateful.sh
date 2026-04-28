#!/usr/bin/env bash
# tests/test-update-stateful.sh
# spec-15-04: phase-15.md §통합 테스트 시나리오 5개를 stateful 회귀 테스트로 잠금.
#             tests/lib/fixture.sh 의 mixin 조합으로 "사용 중인 사용자" 환경 합성 후
#             update.sh 실행 → 사후 상태 검증.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/fixture.sh
source "$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }
skip() { echo "  ⏭  SKIP: $*"; }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

# md5 (macOS / Linux 자동 분기)
_md5() {
  if command -v md5 >/dev/null 2>&1; then
    md5 -q "$1"
  elif command -v md5sum >/dev/null 2>&1; then
    md5sum "$1" | awk '{print $1}'
  else
    echo "no-md5-available"
  fi
}

echo "═══════════════════════════════════════════════════════"
echo " test-update-stateful (spec-15-04) — 5 scenarios"
echo "═══════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────
# Scenario 1: in-flight phase 사용자 → state 6 필드 보존 (#82)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Scenario 1: in-flight phase preserves 6 state fields (#82)"
F1=$(make_fixture); CLEANUP+=("$F1")
with_in_flight_phase "$F1" "phase-08" "spec-08-03-stock-lock"

s1_before=$(jq -c '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}' \
            "$F1/.claude/state/current.json")

bash "$ROOT/update.sh" --yes "$F1" >/dev/null 2>&1

s1_after=$(jq -c '{phase, spec, branch, baseBranch, planAccepted, lastTestPass}' \
           "$F1/.claude/state/current.json")

[ "$s1_before" = "$s1_after" ] \
  && ok "S1: 6 state 필드 보존" \
  || fail "S1: 필드 손상 — before=$s1_before after=$s1_after"

s1_kit_ver=$(jq -r '.kitVersion' "$F1/.claude/state/current.json")
[ "$s1_kit_ver" = "$(cat "$ROOT/VERSION")" ] \
  && ok "S1: kitVersion 갱신 ($s1_kit_ver)" \
  || fail "S1: kitVersion=$s1_kit_ver"

[ -f "$F1/backlog/phase-08.md" ] \
  && ok "S1: backlog/phase-08.md 보존" \
  || fail "S1: phase-08.md 손실"

[ -d "$F1/specs/spec-08-03-stock-lock" ] && [ -f "$F1/specs/spec-08-03-stock-lock/spec.md" ] \
  && ok "S1: specs/spec-08-03-.../ 디렉토리 + spec.md 보존" \
  || fail "S1: spec 디렉토리 손상"

# ─────────────────────────────────────────────────────────
# Scenario 2: 사전 정의 phase → 본문 미변경 + activate 정상 (#84)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Scenario 2: pre-defined phases preserved + activate (#84)"
F2=$(make_fixture); CLEANUP+=("$F2")
with_pre_defined_phases "$F2" "phase-09" "phase-10" "phase-11"

s2_md5_before_09=$(_md5 "$F2/backlog/phase-09.md")
s2_md5_before_10=$(_md5 "$F2/backlog/phase-10.md")
s2_md5_before_11=$(_md5 "$F2/backlog/phase-11.md")

bash "$ROOT/update.sh" --yes "$F2" >/dev/null 2>&1

s2_md5_after_09=$(_md5 "$F2/backlog/phase-09.md")
s2_md5_after_10=$(_md5 "$F2/backlog/phase-10.md")
s2_md5_after_11=$(_md5 "$F2/backlog/phase-11.md")

if [ "$s2_md5_before_09" = "$s2_md5_after_09" ] \
   && [ "$s2_md5_before_10" = "$s2_md5_after_10" ] \
   && [ "$s2_md5_before_11" = "$s2_md5_after_11" ]; then
  ok "S2: 3개 phase 본문 모두 미변경 (md5 일치)"
else
  fail "S2: phase 본문 변경됨"
fi

# update 후 sdd phase activate phase-09 정상 동작
(cd "$F2" && bash .harness-kit/bin/sdd phase activate phase-09 >/dev/null 2>&1)
s2_state_phase=$(jq -r '.phase' "$F2/.claude/state/current.json")
if [ "$s2_state_phase" = "phase-09" ]; then
  ok "S2: update 후 sdd phase activate 정상 (state.phase=phase-09)"
else
  fail "S2: activate 실패 — state.phase=$s2_state_phase"
fi

# ─────────────────────────────────────────────────────────
# Scenario 3: customized fragment → 보존 또는 명시적 conflict (Pattern B)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Scenario 3: customized fragment (Pattern B)"
skip "정책 결정 후 spec-15-06 (user-hook-preserve) 에서 추가"

# ─────────────────────────────────────────────────────────
# Scenario 4: dirty queue icebox → 사용자 메모 + sdd 마커 보존 (Pattern B)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Scenario 4: dirty queue icebox preserved (Pattern B)"
F4=$(make_fixture); CLEANUP+=("$F4")
with_dirty_queue_icebox "$F4"

bash "$ROOT/update.sh" --yes "$F4" >/dev/null 2>&1

if grep -q "TEST_USER_ICEBOX_NOTE" "$F4/backlog/queue.md" 2>/dev/null; then
  ok "S4: 사용자 Icebox 메모 보존"
else
  fail "S4: Icebox 메모 손실"
fi

if grep -q "sdd:active:start" "$F4/backlog/queue.md" 2>/dev/null \
   && grep -q "sdd:active:end" "$F4/backlog/queue.md" 2>/dev/null \
   && grep -q "sdd:specx:start" "$F4/backlog/queue.md" 2>/dev/null \
   && grep -q "sdd:done:start" "$F4/backlog/queue.md" 2>/dev/null; then
  ok "S4: sdd 마커 4 영역 모두 보존"
else
  fail "S4: sdd 마커 손상"
fi

# ─────────────────────────────────────────────────────────
# Scenario 5: multi-install → 8 템플릿 + .gitignore 멱등 (#78, #83)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Scenario 5: multi-install idempotent (#78, #83)"
skip "implementation pending — Task 5"

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
