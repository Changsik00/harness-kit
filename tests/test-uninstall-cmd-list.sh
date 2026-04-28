#!/usr/bin/env bash
# tests/test-uninstall-cmd-list.sh
# spec-15-03: install 이 installed.json 에 installedCommands 기록 +
#            uninstall 이 그 목록(또는 fallback)으로 정확히 hk-* 제거 검증

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"
UNINSTALL="$ROOT/uninstall.sh"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

echo "=== test-uninstall-cmd-list (spec-15-03) ==="

# ─────────────────────────────────────────────────────────
# 시나리오 1: F1 — fresh install: installedCommands 존재 + ≥ 12 항목
# ─────────────────────────────────────────────────────────
echo ""
echo "Scenario 1: install → installed.json.installedCommands 검증"
F1=$(mktemp -d); CLEANUP+=("$F1")
bash "$INSTALL" --yes "$F1" >/dev/null 2>&1

if [ -f "$F1/.harness-kit/installed.json" ]; then
  ok "installed.json 존재"
else
  fail "installed.json 없음"
fi

has_key=$(jq 'has("installedCommands")' "$F1/.harness-kit/installed.json" 2>/dev/null)
if [ "$has_key" = "true" ]; then
  ok "installedCommands 키 존재"
else
  fail "installedCommands 키 부재"
fi

# 실제 sources/commands/ 의 hk-* 와 일치 (개수 비교)
expected=$(find "$ROOT/sources/commands" -maxdepth 1 -name 'hk-*.md' 2>/dev/null | wc -l | tr -d ' ')
actual=$(jq '.installedCommands | length' "$F1/.harness-kit/installed.json" 2>/dev/null || echo 0)
if [ "$expected" -gt 0 ] && [ "$actual" -eq "$expected" ]; then
  ok "installedCommands 개수 일치 (sources $expected = installed $actual)"
else
  fail "개수 불일치 (sources=$expected installed=$actual)"
fi

# ─────────────────────────────────────────────────────────
# 시나리오 2: F2 — install + 사용자 foo.md → uninstall:
#   hk-* 모두 제거됨 + 사용자 foo.md 보존
# ─────────────────────────────────────────────────────────
echo ""
echo "Scenario 2: uninstall — hk-* 제거 + 사용자 커맨드 보존"
F2=$(mktemp -d); CLEANUP+=("$F2")
bash "$INSTALL" --yes "$F2" >/dev/null 2>&1

# 사용자 추가 슬래시 커맨드 (hk- 접두사 없음)
echo "# user custom" > "$F2/.claude/commands/foo.md"

# uninstall 실행 (commands 디렉토리만 보고 검증)
bash "$UNINSTALL" --yes --keep-state "$F2" >/dev/null 2>&1

remaining_hk=$(find "$F2/.claude/commands" -maxdepth 1 -name 'hk-*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$remaining_hk" -eq 0 ]; then
  ok "hk-* 모두 제거됨"
else
  fail "hk-* 잔재 ${remaining_hk}개"
fi

if [ -f "$F2/.claude/commands/foo.md" ]; then
  ok "사용자 foo.md 보존"
else
  fail "사용자 foo.md 손실"
fi

# ─────────────────────────────────────────────────────────
# 시나리오 3: F3 — legacy installed.json (installedCommands 없음) → fallback
# ─────────────────────────────────────────────────────────
echo ""
echo "Scenario 3: legacy installed.json → uninstall fallback (hk-* glob)"
F3=$(mktemp -d); CLEANUP+=("$F3")
bash "$INSTALL" --yes "$F3" >/dev/null 2>&1

# installed.json 에서 installedCommands 키 제거 (legacy 환경 모사)
_tmp=$(mktemp)
jq 'del(.installedCommands)' "$F3/.harness-kit/installed.json" > "$_tmp"
mv "$_tmp" "$F3/.harness-kit/installed.json"

# 검증: 실제로 키 제거됨
has_key_after=$(jq 'has("installedCommands")' "$F3/.harness-kit/installed.json" 2>/dev/null)
[ "$has_key_after" = "false" ] && ok "legacy 모사: installedCommands 키 제거 확인" \
  || fail "legacy 모사 실패"

# uninstall 실행 → fallback 으로 hk-* 제거되어야
bash "$UNINSTALL" --yes --keep-state "$F3" >/dev/null 2>&1

# uninstall 은 .harness-kit 디렉토리 자체를 지우므로 commands 디렉토리만 검사
remaining_hk=$(find "$F3/.claude/commands" -maxdepth 1 -name 'hk-*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$remaining_hk" -eq 0 ]; then
  ok "fallback: hk-* 모두 제거됨"
else
  fail "fallback 미동작: hk-* 잔재 ${remaining_hk}개"
fi

# ─────────────────────────────────────────────────────────
# 시나리오 4: F5 — update 흐름: 최종 hk-* 가 정확히 명단대로
# ─────────────────────────────────────────────────────────
echo ""
echo "Scenario 4: update 흐름 — install → uninstall --keep-state → install"
F4=$(mktemp -d); CLEANUP+=("$F4")
bash "$INSTALL" --yes "$F4" >/dev/null 2>&1

# uninstall (state 유지)
bash "$UNINSTALL" --yes --keep-state "$F4" >/dev/null 2>&1

# 재 install
bash "$INSTALL" --yes "$F4" >/dev/null 2>&1

# 최종 hk-* 가 sources/commands 와 정확히 일치
expected=$(find "$ROOT/sources/commands" -maxdepth 1 -name 'hk-*.md' 2>/dev/null \
           | xargs -I{} basename {} .md | sort)
actual=$(find "$F4/.claude/commands" -maxdepth 1 -name 'hk-*.md' 2>/dev/null \
         | xargs -I{} basename {} .md | sort)

if [ "$expected" = "$actual" ]; then
  ok "update 흐름: hk-* 명단 정확히 일치"
else
  fail "update 흐름: 명단 불일치"
  echo "    expected:" $expected
  echo "    actual:  " $actual
fi

# 사용자 추가 커맨드가 update 흐름에서도 보존되는지 (간접 검증)
echo "# user custom" > "$F4/.claude/commands/baz.md"
bash "$UNINSTALL" --yes --keep-state "$F4" >/dev/null 2>&1
if [ -f "$F4/.claude/commands/baz.md" ]; then
  ok "update 흐름에서 사용자 커맨드 보존 (baz.md)"
else
  fail "update 흐름에서 사용자 커맨드 손실"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
