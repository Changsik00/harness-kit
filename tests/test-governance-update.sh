#!/usr/bin/env bash
# tests/test-governance-update.sh
# spec-21-04: Turbo 거버넌스 문서 + /hk-turbo 슬래시 커맨드
#
# 6 케이스:
#   T01: .harness-kit/agent/constitution.md 에 "Mode D" 포함
#   T02: .harness-kit/agent/constitution.md 에 "sdd mode turbo" 포함
#   T03: .harness-kit/agent/agent.md 에 "Turbo" 행 포함
#   T04: .claude/commands/hk-turbo.md 존재
#   T05: sources/governance/constitution.md 에 Mode D 포함
#   T06: sources/commands/hk-turbo.md 존재

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-governance-update ==="

CONSTITUTION="$ROOT/.harness-kit/agent/constitution.md"
AGENT_MD="$ROOT/.harness-kit/agent/agent.md"
HK_TURBO_CMD="$ROOT/.claude/commands/hk-turbo.md"
SRC_CONSTITUTION="$ROOT/sources/governance/constitution.md"
SRC_HK_TURBO_CMD="$ROOT/sources/commands/hk-turbo.md"

# ─────────────────────────────────────────────────────────
# T01: constitution.md 에 "2.5 Mode D" 포함 (Turbo 섹션)
# ─────────────────────────────────────────────────────────
echo ""
echo "T01: constitution.md — 2.5 Mode D Turbo 섹션 포함"
if [ -f "$CONSTITUTION" ] && grep -q "2.5 Mode D" "$CONSTITUTION"; then
  ok "T01: constitution.md 에 '2.5 Mode D' 있음"
else
  fail "T01: constitution.md 에 '2.5 Mode D' 없음"
fi

# ─────────────────────────────────────────────────────────
# T02: constitution.md 에 "sdd mode turbo" 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T02: constitution.md — sdd mode turbo 언급"
if [ -f "$CONSTITUTION" ] && grep -q "sdd mode turbo" "$CONSTITUTION"; then
  ok "T02: constitution.md 에 'sdd mode turbo' 있음"
else
  fail "T02: constitution.md 에 'sdd mode turbo' 없음"
fi

# ─────────────────────────────────────────────────────────
# T03: agent.md §3.1 에 Turbo 행 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T03: agent.md — §3.1 Turbo 행 포함"
if [ -f "$AGENT_MD" ] && grep -q "Turbo" "$AGENT_MD"; then
  ok "T03: agent.md 에 Turbo 행 있음"
else
  fail "T03: agent.md 에 Turbo 행 없음"
fi

# ─────────────────────────────────────────────────────────
# T04: .claude/commands/hk-turbo.md 존재
# ─────────────────────────────────────────────────────────
echo ""
echo "T04: .claude/commands/hk-turbo.md 존재"
if [ -f "$HK_TURBO_CMD" ]; then
  ok "T04: hk-turbo.md 존재"
else
  fail "T04: hk-turbo.md 없음"
fi

# ─────────────────────────────────────────────────────────
# T05: sources/governance/constitution.md 에 "2.5 Mode D" 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "T05: sources/governance/constitution.md — 2.5 Mode D 미러링"
if [ -f "$SRC_CONSTITUTION" ] && grep -q "2.5 Mode D" "$SRC_CONSTITUTION"; then
  ok "T05: sources/governance/constitution.md 에 '2.5 Mode D' 있음"
else
  fail "T05: sources/governance/constitution.md 에 '2.5 Mode D' 없음"
fi

# ─────────────────────────────────────────────────────────
# T06: sources/commands/hk-turbo.md 존재
# ─────────────────────────────────────────────────────────
echo ""
echo "T06: sources/commands/hk-turbo.md 존재"
if [ -f "$SRC_HK_TURBO_CMD" ]; then
  ok "T06: sources/commands/hk-turbo.md 존재"
else
  fail "T06: sources/commands/hk-turbo.md 없음"
fi

# ─────────────────────────────────────────────────────────
echo ""
echo "=== 결과: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
