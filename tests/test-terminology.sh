#!/usr/bin/env bash
set -uo pipefail

# test-terminology.sh
# spec-x-auto-mode-ux: "칸N" 용어를 "검증 N단계"로 개명한 뒤 운영/정규 문서에
# 칸[0-9] 잔재가 없는지 + /hk-auto 커맨드가 존재하는지 봉인.
# (완료 backlog phase-25.md·immutable walkthrough 는 역사 기록이라 검사 제외.)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0; FAIL=0
ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

echo "=== test-terminology (spec-x-auto-mode-ux) ==="

# 개명 대상 운영/정규 문서
FILES="
README.md
CHANGELOG.md
sources/commands/hk-refute.md
.claude/commands/hk-refute.md
sources/hooks/check-test-trust.sh
.harness-kit/hooks/check-test-trust.sh
sources/hooks/pre-commit.sh
.harness-kit/hooks/pre-commit.sh
sources/governance/agent.md
.harness-kit/agent/agent.md
docs/decisions/ADR-009-governance-by-reliability-and-blast-radius.md
"

# 1) 칸[0-9] 잔재 0건
leak=0
for rel in $FILES; do
  f="$ROOT/$rel"
  [ -f "$f" ] || continue
  if grep -nE '칸[0-9]' "$f" >/dev/null 2>&1; then
    fail "칸N 잔재: $rel → $(grep -cE '칸[0-9]' "$f")건"
    leak=1
  fi
done
[ "$leak" -eq 0 ] && ok "운영/정규 문서에 칸[0-9] 잔재 없음 (검증 N단계 개명 완료)"

# 2) /hk-auto 커맨드 존재 + 미러
[ -f "$ROOT/sources/commands/hk-auto.md" ] && ok "sources/commands/hk-auto.md 존재" || fail "hk-auto.md 미존재"
[ -f "$ROOT/.claude/commands/hk-auto.md" ] && ok ".claude/commands/hk-auto.md 미러 존재" || fail "hk-auto.md 미러 없음"

echo ""
echo "=== 결과: PASS=$PASS FAIL=$FAIL ==="
[ "$FAIL" -eq 0 ]
