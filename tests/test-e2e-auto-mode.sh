#!/usr/bin/env bash
set -uo pipefail

# test-e2e-auto-mode.sh
# spec-25-03: auto 안전장치 통합 e2e (phase-24 carry-over C1, 성공기준 #3).
# 실제 install fixture 에서 auto 사이클의 *기계적* 조각을 순서대로 구동·측정:
#   ① mode=auto 설정 + settings 패치   ② askquestion hook 차단(auto)/통과(governed)
#   ③ 결정 로그 누적(decision add → list / list --phase)
#   ④ 칸0 test-trust 경고             ⑤ 정지규칙 ② check-irreversible 감지
# 측정 한계: bash e2e 는 기계적 보장만 증명 — 에이전트의 *기본값 선택 행동* 은 #181 영역(미측정).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/lib/fixture.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEAN=()
trap 'for d in "${CLEAN[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

echo "═══════════════════════════════════════════════════════"
echo " test-e2e-auto-mode (spec-25-03)"
echo "═══════════════════════════════════════════════════════"

F=$(make_fixture); CLEAN+=("$F")
SDD="$F/.harness-kit/bin/sdd"
STATE="$F/.claude/state/current.json"
SETTINGS="$F/.claude/settings.json"
run() { ( cd "$F" && HARNESS_DRIFT_FETCH=0 "$SDD" "$@" 2>&1 ); }
set_state() { local t; t=$(mktemp); jq "$1" "$STATE" > "$t" && mv "$t" "$STATE"; }

# ① mode=auto 설정 + settings 패치 -------------------------------------------
run mode auto >/dev/null 2>&1
if [ "$(jq -r '.mode' "$STATE")" = "auto" ]; then ok "① mode=auto 설정됨"; else fail "① mode 미설정"; fi
# settings ask 에서 git push 제거됨
if ! jq -e '.permissions.ask // [] | index("Bash(git push)")' "$SETTINGS" >/dev/null 2>&1; then
  ok "① settings 패치 — git push ask 제거 (auto 무인 push)"
else
  fail "① settings ask 에 git push 잔존"
fi

# ② askquestion hook: auto 차단 / governed 통과 ------------------------------
AQ="$F/.harness-kit/hooks/check-askquestion-auto.sh"
_run_aq() { ( cd "$F" && bash "$AQ" 2>&1 1>/dev/null ); }
set_state '.mode="auto"'
out=$(_run_aq); rc=$?
if [ "$rc" -eq 2 ] && echo "$out" | grep -q "decision add"; then ok "② auto: askquestion 차단(exit 2)+리다이렉트"; else fail "② auto 차단 실패 (rc=$rc)"; fi
set_state '.mode="governed"'
out=$(_run_aq); rc=$?
if [ "$rc" -eq 0 ]; then ok "② governed: askquestion 통과(exit 0)"; else fail "② governed 통과 실패 (rc=$rc)"; fi
set_state '.mode="auto"'

# ③ 결정 로그 누적 (0건이 '미사용'이었음 실증) -------------------------------
set_state '.phase="phase-99" | .spec="spec-99-01-demo"'
mkdir -p "$F/specs/spec-99-01-demo"
run decision add "방향 모호" "기본값 X 채택" "가역적, ADR-009" >/dev/null 2>&1
list=$(run decision list)
if echo "$list" | grep -q "기본값 X 채택"; then ok "③ decision add → list 누적"; else fail "③ decision list 누적 안 됨: $list"; fi
listp=$(run decision list --phase)
if echo "$listp" | grep -q "기본값 X 채택" && echo "$listp" | grep -q "spec-99-01-demo"; then
  ok "③ list --phase rollup (실데이터 — 0건은 미사용이었음)"
else
  fail "③ list --phase rollup 실패: $listp"
fi

# ④ 칸0 test-trust: 구현-무테스트 staged → 경고 ------------------------------
TT="$F/.harness-kit/hooks/check-test-trust.sh"
mkdir -p "$F/src"; echo 'echo impl' > "$F/src/feature.sh"; git -C "$F" add src/feature.sh
ttout=$( cd "$F" && HARNESS_GIT_HOOK_MODE=1 bash "$TT" 2>&1 1>/dev/null )
if echo "$ttout" | grep -q "test-trust:warn" && echo "$ttout" | grep -q "src/feature.sh"; then
  ok "④ 칸0: 구현-무테스트 커밋 경고"
else
  fail "④ 칸0 경고 실패: $ttout"
fi
git -C "$F" reset -q

# ⑤ 정지규칙 ②: 비가역 명령 감지 --------------------------------------------
IR="$F/.harness-kit/hooks/check-irreversible.sh"
irout=$( cd "$F" && CLAUDE_TOOL_INPUT_command="git push --force origin main" bash "$IR" 2>&1 1>/dev/null )
if echo "$irout" | grep -qE "hook:(warn|block)" && echo "$irout" | grep -q "force push"; then
  ok "⑤ 정지규칙 ②: 비가역(force push) 감지"
else
  fail "⑤ check-irreversible 미감지: $irout"
fi

echo ""
echo "─────────────────────────────────────────"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
