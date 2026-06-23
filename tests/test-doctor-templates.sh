#!/usr/bin/env bash
set -uo pipefail

# test-doctor-templates.sh
# spec-x-doctor-template-sync (#204): 루트 doctor.sh 의 필수 템플릿 목록이
# 실제 sources/templates/*.md 와 정확히 일치하는지 검증. 양방향 drift(유령·누락) 봉인.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-doctor-templates (#204) ==="

# doctor.sh 의 '[3/7]' 필수 템플릿 for-loop 에서 .md 이름 추출
doctor_list() {
  grep -E 'for f in .*queue\.md' "$ROOT/doctor.sh" | head -1 \
    | sed -E 's/.*for f in //; s/;.*//' \
    | tr ' ' '\n' | grep -E '\.md$' | sort
}
# 실제 템플릿 파일 집합
actual_list() {
  ls "$ROOT/sources/templates/"*.md 2>/dev/null | xargs -n1 basename | sort
}

DOC="$(doctor_list)"
ACT="$(actual_list)"

# T1: plan.md 는 목록에 없어야 함 (유령 제거 — #204 핵심)
if echo "$DOC" | grep -qx "plan.md"; then
  fail "T1: doctor.sh 가 폐기된 plan.md 를 여전히 필수 체크 (오탐 원인)"
else
  ok "T1: plan.md 미체크 (유령 제거)"
fi

# T2: phase-ship.md 는 목록에 있어야 함 (실재 템플릿 누락 보강)
if echo "$DOC" | grep -qx "phase-ship.md"; then
  ok "T2: phase-ship.md 체크 (누락 보강)"
else
  fail "T2: 실재 템플릿 phase-ship.md 가 doctor.sh 목록에 누락"
fi

# T3: 목록 집합 == 실제 템플릿 집합 (양방향 정합 — 재드리프트 봉인)
if [ "$DOC" = "$ACT" ]; then
  ok "T3: doctor.sh 목록 == sources/templates/*.md (정합)"
else
  fail "T3: 목록 불일치
    doctor.sh 만: $(comm -23 <(echo "$DOC") <(echo "$ACT") | tr '\n' ' ')
    실제 만:      $(comm -13 <(echo "$DOC") <(echo "$ACT") | tr '\n' ' ')"
fi

echo ""
echo "=== 결과: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
