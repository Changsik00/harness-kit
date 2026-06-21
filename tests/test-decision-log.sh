#!/usr/bin/env bash
set -uo pipefail

# test-decision-log.sh
# spec-24-03: 결정 로그 — sdd decision add/list
#   active spec walkthrough 에 결정·근거 누적 (ADR-009 규약 2/4)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

FIXTURES_TO_CLEAN=()
trap 'for d in "${FIXTURES_TO_CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

_sdd() { local fx="$1"; shift; ( cd "$fx" && bash .harness-kit/bin/sdd "$@" ); }

echo "═══════════════════════════════════════════════════════"
echo " test-decision-log (spec-24-03)"
echo "═══════════════════════════════════════════════════════"

SPEC="spec-08-03-test"

# ── D1: decision add → walkthrough 에 행 추가 ──
echo ""
echo "▶ D1: sdd decision add → walkthrough 결정 로그 행 추가"
FX1="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX1")
with_in_flight_phase "$FX1" "phase-08" "$SPEC"
_sdd "$FX1" decision add "기본값 선택" "옵션 A" "흐름 우선" >/dev/null 2>&1
WT1="$FX1/specs/$SPEC/walkthrough.md"
if [ -f "$WT1" ] && grep -q "기본값 선택" "$WT1" && grep -q "옵션 A" "$WT1"; then
  ok "D1: walkthrough 에 결정 행 기록됨"
else
  fail "D1: 결정 행 미기록 ($WT1)"
fi

# ── D2: 헤더 멱등 — 두 번째 add 시 헤더 1개, 행 2개 ──
echo ""
echo "▶ D2: 헤더 멱등 (두 번째 add)"
_sdd "$FX1" decision add "두번째 이슈" "옵션 B" "근거2" >/dev/null 2>&1
hdr="$(grep -c '결정 기록 (auto)' "$WT1" 2>/dev/null || echo 0)"
rows="$(grep -c '^| .* | .* | .* |$' "$WT1" 2>/dev/null || echo 0)"
if [ "$hdr" = "1" ] && grep -q "두번째 이슈" "$WT1"; then
  ok "D2: 헤더 1개 유지 + 행 누적 (헤더=$hdr)"
else
  fail "D2: 헤더 멱등 실패 (헤더=$hdr, rows=$rows)"
fi

# ── D3: decision list → 기록된 결정 출력 ──
echo ""
echo "▶ D3: sdd decision list 출력"
out3="$(_sdd "$FX1" decision list 2>/dev/null)"
if echo "$out3" | grep -q "기본값 선택" && echo "$out3" | grep -q "두번째 이슈"; then
  ok "D3: list 가 누적 결정 출력"
else
  fail "D3: list 출력 누락 ($out3)"
fi

# ── D4: 활성 spec 없음 → graceful (non-zero, 크래시 없음) ──
echo ""
echo "▶ D4: 활성 spec 없음 → graceful 실패"
FX4="$(make_fixture)"; FIXTURES_TO_CLEAN+=("$FX4")
rc4=0
_sdd "$FX4" decision add "x" "y" "z" >/dev/null 2>&1 || rc4=$?
if [ "$rc4" -ne 0 ]; then
  ok "D4: 활성 spec 없으면 non-zero 종료 (graceful)"
else
  fail "D4: 활성 spec 없는데 성공 처리됨 (rc=$rc4)"
fi

echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
