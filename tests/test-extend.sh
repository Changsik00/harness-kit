#!/usr/bin/env bash
# tests/test-extend.sh
# spec-22-01-extend-serena: sdd extend serena 헬퍼 검증
#
# 외부 의존(uv/claude)은 PATH stub 으로 주입하여 격리한다.
#   - PATH=/usr/bin:/bin 로 제한 → 실제 uv/claude 가 잡히지 않음(머신 독립).
#   - claude stub: mcp add/get/remove/list 를 state/log 파일로 모사.
#   - uv stub: 존재만 하면 선행조건 통과.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB="$SCRIPT_DIR/lib/fixture.sh"
SDD="$ROOT/sources/bin/sdd"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-extend ==="

[ -f "$LIB" ] || { fail "tests/lib/fixture.sh 없음"; exit 1; }
[ -f "$SDD" ] || { fail "sources/bin/sdd 없음"; exit 1; }
source "$LIB"

CLEAN=()
cleanup() {
  local d
  for d in "${CLEAN[@]:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"
  done
}
trap cleanup EXIT

# claude/uv stub 디렉토리 생성. with_uv=true 면 uv 도 포함.
make_stub_bin() {
  local with_uv="$1"
  local d
  d=$(mktemp -d)
  cat > "$d/claude" <<'STUB'
#!/bin/bash
state="${MCP_STUB_STATE:-$0.state}"
log="${MCP_STUB_LOG:-$0.log}"
if [ "${1:-}" = "mcp" ]; then
  case "${2:-}" in
    add)    echo "add $*" >> "$log"; : > "$state"; echo "Added MCP server: serena"; exit 0 ;;
    get)    if [ -f "$state" ]; then echo "serena: registered"; exit 0; else echo "not found" >&2; exit 1; fi ;;
    remove) rm -f "$state"; echo "Removed: serena"; exit 0 ;;
    list)   if [ -f "$state" ]; then echo "serena: uvx ... - ✓ Connected"; else echo "(no servers)"; fi; exit 0 ;;
    *)      echo "unknown mcp sub: ${2:-}" >&2; exit 2 ;;
  esac
fi
exit 0
STUB
  chmod +x "$d/claude"
  if [ "$with_uv" = "true" ]; then
    printf '#!/bin/bash\nexit 0\n' > "$d/uv"
    chmod +x "$d/uv"
  fi
  echo "$d"
}

# sdd extend 실행 — PATH 를 stub + 코어 경로로 제한
run_extend() {
  local fx="$1" stub="$2"; shift 2
  ( cd "$fx" && PATH="$stub:/usr/bin:/bin" HARNESS_DRIFT_FETCH=0 \
      MCP_STUB_STATE="$stub/state" MCP_STUB_LOG="$stub/log" \
      bash "$SDD" extend "$@" 2>&1 )
}

get_ext_scope() {
  jq -r '.extensions.serena.scope // empty' "$1/.harness-kit/installed.json" 2>/dev/null || echo ""
}

# ─────────────────────────────────────────────────────────
# T1: 잘못된 스코프(project) → 거부 + 비정상 종료
# ─────────────────────────────────────────────────────────
echo ""
echo "T1: sdd extend serena --scope project → 거부"
F1=$(make_fixture); CLEAN+=("$F1")
S1=$(make_stub_bin true); CLEAN+=("$S1")
OUT1=$(run_extend "$F1" "$S1" serena --scope project --dry-run); RC1=$?
if [ "$RC1" -ne 0 ] && echo "$OUT1" | grep -qiE "project|local|user|허용|스코프|scope"; then
  ok "project 스코프 거부 + 사유 출력 (rc=$RC1)"
else
  fail "project 거부 실패 — rc=$RC1, 출력: $OUT1"
fi

# ─────────────────────────────────────────────────────────
# T2: 선행조건(uv) 부재 → graceful 종료(exit 0), 등록 시도 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "T2: uv 부재 → graceful 안내 후 종료"
F2=$(make_fixture); CLEAN+=("$F2")
S2=$(make_stub_bin false); CLEAN+=("$S2")   # uv 없음
OUT2=$(run_extend "$F2" "$S2" serena --scope local); RC2=$?
if [ "$RC2" -eq 0 ] && echo "$OUT2" | grep -qiE "uv"; then
  ADDED2=""; [ -f "$S2/log" ] && ADDED2=$(cat "$S2/log")
  if [ -z "$ADDED2" ]; then
    ok "uv 부재 시 graceful 종료 + 등록 시도 없음"
  else
    fail "uv 부재인데 등록 시도함 — log: $ADDED2"
  fi
else
  fail "graceful 처리 실패 — rc=$RC2, 출력: $OUT2"
fi

# ─────────────────────────────────────────────────────────
# T3: --dry-run → 구성될 커맨드 출력, 실제 등록/기록 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "T3: --dry-run → 커맨드 미리보기, 부작용 없음"
F3=$(make_fixture); CLEAN+=("$F3")
S3=$(make_stub_bin true); CLEAN+=("$S3")
OUT3=$(run_extend "$F3" "$S3" serena --scope local --dry-run); RC3=$?
LOG3=""; [ -f "$S3/log" ] && LOG3=$(cat "$S3/log")
SCOPE3=$(get_ext_scope "$F3")
if [ "$RC3" -eq 0 ] \
   && echo "$OUT3" | grep -q "claude mcp add serena" \
   && echo "$OUT3" | grep -qi "local" \
   && echo "$OUT3" | grep -qi "uvx" \
   && [ -z "$LOG3" ] && [ -z "$SCOPE3" ]; then
  ok "dry-run: 커맨드 출력 + 외부 호출/기록 없음"
else
  fail "dry-run 실패 — rc=$RC3, log='$LOG3', scope='$SCOPE3', 출력: $OUT3"
fi

# ─────────────────────────────────────────────────────────
# T4: 정상 설치(기본 스코프=local) → 등록 + installed.json 기록
# ─────────────────────────────────────────────────────────
echo ""
echo "T4: 정상 설치(기본 local) → 등록 + 기록"
F4=$(make_fixture); CLEAN+=("$F4")
S4=$(make_stub_bin true); CLEAN+=("$S4")
OUT4=$(run_extend "$F4" "$S4" serena); RC4=$?   # --scope 생략 → 기본 local
SCOPE4=$(get_ext_scope "$F4")
ADDS4=0; [ -f "$S4/log" ] && ADDS4=$(grep -c "^add " "$S4/log" 2>/dev/null || echo 0)
if [ "$RC4" -eq 0 ] && [ "$SCOPE4" = "local" ] && [ "$ADDS4" -eq 1 ]; then
  ok "정상 설치: 기본 local 등록(add 1회) + installed.json 기록"
else
  fail "설치 실패 — rc=$RC4, scope='$SCOPE4', adds=$ADDS4, 출력: $OUT4"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ]
