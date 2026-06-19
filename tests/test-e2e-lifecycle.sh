#!/usr/bin/env bash
# tests/test-e2e-lifecycle.sh
# 격리 디렉토리에 harness-kit 를 실제 install 한 뒤 SDD 라이프사이클을
# 처음부터 끝까지(install → phase → spec → plan-accept 게이트 → ship 검증) 구동하는 e2e.
#
# 검증 핵심:
#   - plan→spec 통합: spec new 가 spec.md + task.md 만 생성 (plan.md 없음)
#   - spec.md 템플릿에 '롤백 계획' / 'Base 브랜치' 섹션 존재
#   - plan-accept 게이트: 승인 전 production 편집 차단(고친 메시지 = "spec.md / task.md")
#   - plan accept: spec+task 만 검증 (plan 없음) + placeholder 거부
#   - 설치된 커맨드 문서에 stale plan.md 지시 없음
#
# 외부 의존: 실제 install.sh 구동(네트워크 회피 = HARNESS_DRIFT_FETCH=0). bash 3.2 호환.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-e2e-lifecycle ==="

[ -f "$ROOT/install.sh" ] || { fail "install.sh 없음"; exit 1; }

T=$(mktemp -d)
cleanup() { [ -n "${T:-}" ] && [ -d "$T" ] && rm -rf "$T"; }
trap cleanup EXIT

SDD="$T/.harness-kit/bin/sdd"
HOOK="$T/.harness-kit/hooks/check-plan-accept.sh"
run() { ( cd "$T" && HARNESS_DRIFT_FETCH=0 "$SDD" "$@" ); }
# 이식 가능한 in-place 치환 (sed -i 비호환 회피)
subst() { local f="$1"; shift; local tmp; tmp=$(mktemp); sed "$1" "$f" > "$tmp" && mv "$tmp" "$f"; }

# 1. install
if HARNESS_DRIFT_FETCH=0 bash "$ROOT/install.sh" --yes "$T" >"$T/.install.log" 2>&1; then
  ok "install.sh 완료"
else
  fail "install 실패"; tail -20 "$T/.install.log"; echo "결과: PASS=$PASS FAIL=$FAIL"; exit 1
fi
[ -x "$SDD" ] && ok "sdd 설치/실행권한" || fail "sdd 없음"
git -C "$T" init -q
git -C "$T" config user.email e2e@t
git -C "$T" config user.name e2e
git -C "$T" add -A && git -C "$T" commit -qm init 2>/dev/null
ok "git init + 초기 커밋"

# 2. phase new
run phase new demo >"$T/.log" 2>&1 && ok "sdd phase new demo" || { fail "phase new"; cat "$T/.log"; }
ls "$T"/backlog/phase-*.md >/dev/null 2>&1 && ok "phase 파일 생성" || fail "phase 파일 없음"

# 3. spec new
run spec new widget >"$T/.log" 2>&1 && ok "sdd spec new widget" || { fail "spec new"; cat "$T/.log"; }
SPECDIR=$(ls -d "$T"/specs/*widget* 2>/dev/null | head -1)
[ -n "$SPECDIR" ] && ok "spec 디렉토리: $(basename "$SPECDIR")" || fail "spec 디렉토리 없음"

# 4. 통합 증명
[ -f "$SPECDIR/spec.md" ] && ok "spec.md 생성됨" || fail "spec.md 없음"
[ -f "$SPECDIR/task.md" ] && ok "task.md 생성됨" || fail "task.md 없음"
[ ! -f "$SPECDIR/plan.md" ] && ok "plan.md 미생성 (통합 증명)" || fail "plan.md 가 생성됨!"
grep -q "롤백 계획" "$SPECDIR/spec.md" && ok "spec.md '롤백 계획' 섹션 존재" || fail "롤백 섹션 없음"
grep -q "Base 브랜치" "$SPECDIR/spec.md" && ok "spec.md 'Base 브랜치' 행 존재" || fail "Base 행 없음"

# 5. plan-accept 게이트 (승인 전)
OUT=$( cd "$T" && CLAUDE_TOOL_INPUT_file_path="src/app.ts" HARNESS_HOOK_MODE=block HARNESS_HOOK_MODE_PLAN_ACCEPT=block bash "$HOOK" 2>&1 ); RC=$?
[ "$RC" -eq 2 ] && ok "승인 전 production 편집 차단 (exit 2)" || fail "차단 안됨 (rc=$RC)"
echo "$OUT" | grep -q "spec.md / task.md" && ok "차단 메시지='spec.md / task.md' (드리프트 수정 증명)" || fail "메시지 이상: $OUT"
echo "$OUT" | grep -q "plan.md" && fail "메시지에 plan.md 잔재" || ok "메시지에 plan.md 없음"
( cd "$T" && CLAUDE_TOOL_INPUT_file_path="$SPECDIR/spec.md" HARNESS_HOOK_MODE=block bash "$HOOK" >/dev/null 2>&1 ) \
  && ok "spec.md(.md) 편집은 승인 전에도 허용" || fail "안전경로 .md 막힘"

# 6. plan accept (placeholder 치환 후)
subst "$SPECDIR/spec.md" 's/<한글 제목>/위젯 데모/g; s/<한 줄 설명>/위젯 데모/g; s/<제목>/위젯 데모/g'
subst "$SPECDIR/task.md" 's/<한글 제목>/위젯 데모/g; s/<한 줄 설명>/위젯 데모/g; s/<제목>/위젯 데모/g'
printf '\n실제 내용 한 줄.\n' >> "$SPECDIR/spec.md"
run plan accept >"$T/.log" 2>&1 && ok "sdd plan accept 성공 (게이트: spec+task, plan 없음)" || { fail "plan accept 실패"; cat "$T/.log"; }
grep -qE '"planAccepted":[[:space:]]*true' "$T/.claude/state/current.json" && ok "planAccepted=true 기록" || fail "planAccepted 미기록"

# 7. 승인 후
( cd "$T" && CLAUDE_TOOL_INPUT_file_path="src/app.ts" HARNESS_HOOK_MODE=block bash "$HOOK" >/dev/null 2>&1 ) \
  && ok "accept 후 production 편집 허용" || fail "accept 후에도 막힘"

# 8. 설치된 커맨드 문서 stale 없음
grep -qE "plan.md 를 명시적으로 승인|plan.md 가 작성|<spec-dir>/plan.md" "$T/.claude/commands/hk-plan-accept.md" \
  && fail "hk-plan-accept.md stale plan.md 지시 잔재" || ok "hk-plan-accept.md stale 지시 제거됨"
grep -qE "✓ plan|plan ✓" "$T/.claude/commands/hk.md" && fail "hk.md 상태표 plan 잔재" || ok "hk.md 상태표 plan 제거됨"

# 9. ship --check
run ship --check >"$T/.log" 2>&1 || true
grep -qiE "walkthrough|pr_description" "$T/.log" && ok "ship 이 walkthrough/pr_description 검증" || fail "ship 검증 미동작: $(cat "$T/.log")"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
