#!/usr/bin/env bash
# tests/test-phase16-integration.sh
#
# phase-16 (Reliability Layer 강화) 의 통합 시나리오 3 개 자동 검증:
#   1. Knowledge Type closure — docs/rca + docs/decisions 의 type 값이 정규 어휘 (5 closure) 안
#   2. Stale ADR detection — fixture (missing path 참조 ADR) 주입 → drift 섹션에 stale 1 라인
#   3. Reliability layer slogan — README + version.json + .harness-kit/agent/constitution.md 3 곳 hit
#
# 명명 규약: tests/test-phase{N}-integration.sh — 후속 phase 도 동일 패턴.
# fixture 격리: ADR-999-phase16-integration-fixture (spec-16-03 의 ADR-999-fixture 와 다른 slug).
# bash 3.2+ 호환.

set -euo pipefail

SDD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SDD_ROOT"

FIXTURE_ADR="docs/decisions/ADR-999-phase16-integration-fixture.md"

cleanup() { rm -f "$FIXTURE_ADR"; }
trap cleanup EXIT

pass() { printf "  ✓ %s\n" "$1"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    detail: $2"; exit 1; }

echo "Test: phase-16 integration (3 scenarios)"

# ─── Scenario 1: Knowledge Type closure ──────────────────────────
# docs/rca + docs/decisions 의 type 값이 정규 어휘 5 (decision / invariant / failure-pattern / convention / tradeoff) 안
allowed="decision invariant failure-pattern convention tradeoff"
types_found=$(grep -rh "^type:" docs/rca docs/decisions 2>/dev/null | sort -u | sed 's/^type:[[:space:]]*//')
[ -z "$types_found" ] && fail "Scenario 1: docs/rca + docs/decisions 에 type 어휘 사용 산출물 없음" "(empty)"
while IFS= read -r t; do
  [ -z "$t" ] && continue
  echo "$allowed" | grep -qw "$t" \
    || fail "Scenario 1: out-of-closure type '$t'" "found types: $types_found"
done <<EOF
$types_found
EOF
pass "Scenario 1: Knowledge Type closure (모든 type 정규 어휘 안)"

# ─── Scenario 2: Stale ADR detection (fixture) ───────────────────
cat > "$FIXTURE_ADR" <<'EOF'
---
type: decision
status: accepted
---
# ADR-999: phase-16 integration fixture
Reference: `src/removed-module-phase16-integration.ts`
EOF

output=$(HARNESS_DRIFT_FETCH=0 bash .harness-kit/bin/sdd status 2>&1)
cleanup

echo "$output" | grep -q "stale ADR: 1 (missing-path)" \
  || fail "Scenario 2: fixture should produce 'stale ADR: 1 (missing-path)' line" "$output"
pass "Scenario 2: Stale ADR detection (fixture → drift 라인)"

# ─── Scenario 3: Reliability layer slogan 3 곳 hit ──────────────
hits=$(grep -l "reliability layer" README.md version.json .harness-kit/agent/constitution.md 2>/dev/null | wc -l | tr -d ' ')
[ "$hits" -eq 3 ] || fail "Scenario 3: expected 3 hits, got $hits" \
  "$(grep -l 'reliability layer' README.md version.json .harness-kit/agent/constitution.md 2>/dev/null || echo '(none)')"
pass "Scenario 3: 'reliability layer' 키워드 3 곳 hit"

echo ""
echo "All 3 scenarios passed."
