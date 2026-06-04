#!/usr/bin/env bash
# tests/test-director-mode.sh
# spec-20-01: hk-director 슬래시 커맨드 + sdd config director-mode 검증
#
# 10 케이스:
#   T01: sources/commands/hk-director.md 파일 존재 + frontmatter description 포함
#   T02: .claude/commands/hk-director.md 미러 존재 + sources 와 동일 내용
#   T03: sdd config director-mode (인수 없음) → directorMode: 포함 출력
#   T04: sdd config director-mode on → installed.json directorMode=true
#   T05: sdd config director-mode off → installed.json directorMode=false
#   T06: sdd config director-mode toggle (off→on) → true 로 반전
#   T07: sdd config director-mode toggle (on→off) → false 로 반전
#   T08: sdd status (directorMode=true) → Director Mode 행 포함
#   T09: sdd status (directorMode=false) → Director Mode 행 미포함
#   T10: sdd doctor → directorMode 관련 텍스트 포함

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-director-mode ==="

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

get_director_mode() {
  local fx="$1"
  jq -r '.directorMode // false' "$fx/.harness-kit/installed.json" 2>/dev/null || echo "false"
}

# ─────────────────────────────────────────────────────────
# T01: sources/commands/hk-director.md 파일 존재 + frontmatter description 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T01: sources/commands/hk-director.md 파일 존재 + frontmatter description 포함"
CMD_SRC="$ROOT/sources/commands/hk-director.md"
if [ -f "$CMD_SRC" ]; then
  if grep -q "^description:" "$CMD_SRC"; then
    ok "hk-director.md 존재 + description frontmatter 포함"
  else
    fail "hk-director.md 존재하지만 description frontmatter 없음"
  fi
else
  fail "sources/commands/hk-director.md 없음"
fi

# ─────────────────────────────────────────────────────────
# T02: .claude/commands/hk-director.md 미러 존재 + sources 와 동일 내용
# ─────────────────────────────────────────────────────────
echo ""
echo "T02: .claude/commands/hk-director.md 미러 존재 + sources 와 동일 내용"
CMD_MIRROR="$ROOT/.claude/commands/hk-director.md"
if [ -f "$CMD_MIRROR" ]; then
  if diff -q "$CMD_SRC" "$CMD_MIRROR" >/dev/null 2>&1; then
    ok ".claude/commands/hk-director.md 미러 parity 확인"
  else
    fail ".claude/commands/hk-director.md 미러 내용이 sources 와 다름"
  fi
else
  fail ".claude/commands/hk-director.md 미러 없음"
fi

# ─────────────────────────────────────────────────────────
# T03: sdd config director-mode (인수 없음) → directorMode: 포함 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T03: sdd config director-mode (인수 없음) → directorMode: 포함 출력"
F03=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F03")

OUT03=$(run_sdd "$F03" config director-mode 2>&1)
if echo "$OUT03" | grep -q "directorMode:"; then
  ok "directorMode: 포함 출력 확인"
else
  fail "directorMode: 포함 출력 누락 — 실제: $OUT03"
fi

# ─────────────────────────────────────────────────────────
# T04: sdd config director-mode on → installed.json directorMode=true
# ─────────────────────────────────────────────────────────
echo ""
echo "T04: sdd config director-mode on → installed.json directorMode=true"
F04=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F04")

run_sdd "$F04" config director-mode on >/dev/null
ACTUAL04=$(get_director_mode "$F04")
if [ "$ACTUAL04" = "true" ]; then
  ok "installed.json directorMode=true 갱신됨"
else
  fail "directorMode on 설정 실패 — 예상: true, 실제: $ACTUAL04"
fi

# ─────────────────────────────────────────────────────────
# T05: sdd config director-mode off → installed.json directorMode=false
# ─────────────────────────────────────────────────────────
echo ""
echo "T05: sdd config director-mode off → installed.json directorMode=false"
F05=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F05")

run_sdd "$F05" config director-mode on >/dev/null
run_sdd "$F05" config director-mode off >/dev/null
ACTUAL05=$(get_director_mode "$F05")
if [ "$ACTUAL05" = "false" ]; then
  ok "installed.json directorMode=false 갱신됨"
else
  fail "directorMode off 설정 실패 — 예상: false, 실제: $ACTUAL05"
fi

# ─────────────────────────────────────────────────────────
# T06: sdd config director-mode toggle (off→on) → true 로 반전
# ─────────────────────────────────────────────────────────
echo ""
echo "T06: sdd config director-mode toggle (off→on) → true 로 반전"
F06=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F06")

# 기본값이 false(off) 이므로 toggle → true 가 되어야 함
run_sdd "$F06" config director-mode off >/dev/null
OUT06=$(run_sdd "$F06" config director-mode toggle 2>&1)
ACTUAL06=$(get_director_mode "$F06")
if [ "$ACTUAL06" = "true" ]; then
  ok "toggle: off → on 반전 확인"
else
  fail "toggle off→on 실패 — installed: $ACTUAL06, 출력: $OUT06"
fi

# ─────────────────────────────────────────────────────────
# T07: sdd config director-mode toggle (on→off) → false 로 반전
# ─────────────────────────────────────────────────────────
echo ""
echo "T07: sdd config director-mode toggle (on→off) → false 로 반전"
F07=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F07")

run_sdd "$F07" config director-mode on >/dev/null
OUT07=$(run_sdd "$F07" config director-mode toggle 2>&1)
ACTUAL07=$(get_director_mode "$F07")
if [ "$ACTUAL07" = "false" ]; then
  ok "toggle: on → off 반전 확인"
else
  fail "toggle on→off 실패 — installed: $ACTUAL07, 출력: $OUT07"
fi

# ─────────────────────────────────────────────────────────
# T08: sdd status (directorMode=true) → Director Mode 행 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T08: sdd status (directorMode=true) → Director Mode 행 포함"
F08=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F08")

run_sdd "$F08" config director-mode on >/dev/null
OUT08=$(run_sdd "$F08" status --no-drift 2>&1)
if echo "$OUT08" | grep -q "Director Mode"; then
  ok "directorMode=true 시 status 에 Director Mode 행 포함"
else
  fail "directorMode=true 인데 Director Mode 행 누락 — 실제: $OUT08"
fi

# ─────────────────────────────────────────────────────────
# T09: sdd status (directorMode=false) → Director Mode 행 미포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T09: sdd status (directorMode=false) → Director Mode 행 미포함"
F09=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F09")

run_sdd "$F09" config director-mode off >/dev/null
OUT09=$(run_sdd "$F09" status --no-drift 2>&1)
if echo "$OUT09" | grep -q "Director Mode"; then
  fail "directorMode=false 인데 Director Mode 행이 출력됨 — 실제: $OUT09"
else
  ok "directorMode=false 시 status 에 Director Mode 행 미포함 확인"
fi

# ─────────────────────────────────────────────────────────
# T10: sdd doctor → directorMode 관련 텍스트 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T10: sdd doctor → directorMode 관련 텍스트 포함"
F10=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F10")

OUT10=$(run_sdd "$F10" doctor 2>&1)
if echo "$OUT10" | grep -q "directorMode"; then
  ok "sdd doctor 출력에 directorMode 관련 텍스트 포함"
else
  fail "sdd doctor 에 directorMode 텍스트 누락 — 실제: $OUT10"
fi

# ─────────────────────────────────────────────────────────
# T11: agent.md §6.6 에 director/worker/scout 역할 용어 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T11: agent.md §6.6 에 director/worker/scout 역할 용어 포함"
AGENT_SRC="$ROOT/sources/governance/agent.md"
for ROLE in director worker scout; do
  if grep -q "$ROLE" "$AGENT_SRC"; then
    ok "§6.6 역할 용어 확인: $ROLE"
  else
    fail "§6.6 역할 용어 누락: $ROLE (sources/governance/agent.md)"
  fi
done

# ─────────────────────────────────────────────────────────
# T12: sdd config models → director/worker/scout 매핑 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "T12: sdd config models → director/worker/scout 매핑 출력"
F12=$(make_fixture)
FIXTURES_TO_CLEAN+=("$F12")

OUT12=$(run_sdd "$F12" config models 2>&1)
for ROLE in director worker scout; do
  if echo "$OUT12" | grep -q "$ROLE"; then
    ok "config models 출력에 역할 포함: $ROLE"
  else
    fail "config models 출력에 역할 누락: $ROLE — 실제: $OUT12"
  fi
done

# ─────────────────────────────────────────────────────────
# T13: review 커맨드에 "페르소나 패널" 문구 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T13: review 커맨드에 페르소나 패널 문구 포함"
for CMD_FILE in \
  "$ROOT/sources/commands/hk-code-review.md" \
  "$ROOT/sources/commands/hk-spec-critique.md" \
  "$ROOT/sources/commands/hk-phase-review.md"; do
  FNAME="$(basename "$CMD_FILE")"
  if grep -q "페르소나 패널" "$CMD_FILE" 2>/dev/null; then
    ok "$FNAME 에 '페르소나 패널' 문구 포함"
  else
    fail "$FNAME 에 '페르소나 패널' 문구 누락"
  fi
done

# ─────────────────────────────────────────────────────────
# T14: .claude/ 미러 parity — hk-code-review / hk-spec-critique / hk-phase-review
# ─────────────────────────────────────────────────────────
echo ""
echo "T14: .claude/commands/ 미러 parity (review 커맨드 3종)"
for CMD_FILE in hk-code-review.md hk-spec-critique.md hk-phase-review.md; do
  SRC="$ROOT/sources/commands/$CMD_FILE"
  MIRROR="$ROOT/.claude/commands/$CMD_FILE"
  if [ -f "$MIRROR" ]; then
    if diff -q "$SRC" "$MIRROR" >/dev/null 2>&1; then
      ok ".claude/commands/$CMD_FILE 미러 parity 확인"
    else
      fail ".claude/commands/$CMD_FILE 미러 내용이 sources 와 다름"
    fi
  else
    fail ".claude/commands/$CMD_FILE 미러 없음"
  fi
done

# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
