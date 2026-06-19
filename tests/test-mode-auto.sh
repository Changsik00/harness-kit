#!/usr/bin/env bash
# tests/test-mode-auto.sh
# spec-24-01: auto 모드 토대 — CLI 전환 / state / status 표시 / 훅 비차단 인식 / 잘못된 모드 거부.
# 격리 fixture(install)에서 검증. bash 3.2 호환.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-mode-auto ==="

CLEAN=()
cleanup() { local d; for d in "${CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done; }
trap cleanup EXIT

F=$(make_fixture); CLEAN+=("$F")
SDD="$F/.harness-kit/bin/sdd"
STATE="$F/.claude/state/current.json"
HOOK="$F/.harness-kit/hooks/check-plan-accept.sh"
modeval() { jq -r '.mode // "governed"' "$STATE" 2>/dev/null; }
set_state() { local tmp; tmp=$(mktemp); jq "$1" "$STATE" > "$tmp" && mv "$tmp" "$STATE"; }

# T1: sdd mode auto → state.mode=auto
( cd "$F" && HARNESS_DRIFT_FETCH=0 "$SDD" mode auto >/dev/null 2>&1 )
[ "$(modeval)" = "auto" ] && ok "sdd mode auto → state.mode=auto" || fail "state.mode=$(modeval) (auto 아님)"

# T2: sdd mode status → auto 표시
OUT=$( cd "$F" && "$SDD" mode status 2>&1 )
echo "$OUT" | grep -qi "auto" && ok "sdd mode status 가 auto 표시" || fail "mode status: $OUT"

# T3: sdd status 모드 행에 auto
OUT=$( cd "$F" && HARNESS_DRIFT_FETCH=0 "$SDD" status --no-drift 2>&1 )
echo "$OUT" | grep -qi "auto" && ok "sdd status 에 auto 표시" || fail "status 에 auto 없음"

# T4: auto + 활성 spec + planAccepted=false → check-plan-accept 비차단(exit 0)
set_state '.spec="spec-24-01-auto-mode-base" | .planAccepted=false | .mode="auto"'
( cd "$F" && CLAUDE_TOOL_INPUT_file_path="src/app.ts" HARNESS_HOOK_MODE=block bash "$HOOK" >/dev/null 2>&1 ) \
  && ok "auto: check-plan-accept 비차단 (exit 0)" || fail "auto 인데 production 편집 차단됨"

# T4b (control): governed + 같은 조건 → 차단(exit 2) — 테스트가 실제로 유효함을 보증
set_state '.mode="governed"'
( cd "$F" && CLAUDE_TOOL_INPUT_file_path="src/app.ts" HARNESS_HOOK_MODE=block bash "$HOOK" >/dev/null 2>&1 ) \
  && fail "governed 인데 차단 안됨 (control 실패)" || ok "control: governed 는 차단 (auto 게이트가 실제 효과)"

# T5: 잘못된 모드 거부
( cd "$F" && "$SDD" mode bogus >/dev/null 2>&1 ) && fail "bogus 모드 허용됨" || ok "잘못된 모드 거부"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
