#!/usr/bin/env bash
# tests/test-decision-phase.sh
# spec-24-05: sdd decision list --phase — active phase 전 spec walkthrough 의
# '결정 기록 (auto)' 행을 spec 라벨과 함께 rollup. 결정 없는 spec 스킵, 0건 graceful,
# 기존 decision list(현재 spec) 불변. bash 3.2 호환.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-decision-phase ==="

CLEAN=()
cleanup() { local d; for d in "${CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done; }
trap cleanup EXIT

F=$(make_fixture); CLEAN+=("$F")
SDD="$F/.harness-kit/bin/sdd"
STATE="$F/.claude/state/current.json"
set_state() { local tmp; tmp=$(mktemp); jq "$1" "$STATE" > "$tmp" && mv "$tmp" "$STATE"; }
run() { ( cd "$F" && HARNESS_DRIFT_FETCH=0 "$SDD" "$@" 2>&1 ); }
wt_with_decision() {  # $1=dir $2=issue $3=choice $4=reason
  mkdir -p "$1"
  printf '## 📌 결정 기록 (auto)\n\n| 이슈 | 결정 | 근거 |\n|---|---|---|\n| %s | %s | %s |\n' "$2" "$3" "$4" > "$1/walkthrough.md"
}

# phase-99 에 spec 2개(결정 있음) + 1개(결정 없음)
set_state '.phase="phase-99"'
wt_with_decision "$F/specs/spec-99-01-a" "issA" "choiceA" "reasonA"
wt_with_decision "$F/specs/spec-99-02-b" "issB" "choiceB" "reasonB"
mkdir -p "$F/specs/spec-99-03-c"; printf '# wt (결정 없음)\n' > "$F/specs/spec-99-03-c/walkthrough.md"

# T1: --phase 가 두 spec 결정 모두 집계
OUT="$(run decision list --phase)"
if echo "$OUT" | grep -q "issA" && echo "$OUT" | grep -q "issB"; then ok "--phase 가 전 spec 결정 집계"; else fail "집계 누락: $OUT"; fi

# T2: 출처 spec 라벨 포함
if echo "$OUT" | grep -q "spec-99-01-a" && echo "$OUT" | grep -q "spec-99-02-b"; then ok "spec 라벨 포함"; else fail "라벨 없음: $OUT"; fi

# T3: 결정 없는 spec(c) 은 노출 안 함
echo "$OUT" | grep -q "spec-99-03-c" && fail "결정 없는 spec 이 노출됨" || ok "결정 없는 spec 스킵"

# T4: 기존 list(현재 spec) 불변 — active spec = a 면 issA 만
set_state '.spec="spec-99-01-a"'
OUT2="$(run decision list)"
if echo "$OUT2" | grep -q "issA" && ! echo "$OUT2" | grep -q "issB"; then ok "기존 decision list(현재 spec) 불변"; else fail "현재-spec list 오작동: $OUT2"; fi

# T5: 결정 0건 phase → graceful
set_state '.phase="phase-88"'
OUT3="$(run decision list --phase)"
echo "$OUT3" | grep -q "결정 로그 없음" && ok "0건 graceful" || fail "graceful 아님: $OUT3"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
