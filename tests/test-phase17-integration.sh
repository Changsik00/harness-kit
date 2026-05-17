#!/usr/bin/env bash
# tests/test-phase17-integration.sh
#
# phase-17 (운영 성숙도) 의 통합 시나리오 4 개 검증:
#   1. Marker 멱등성 — test-sdd-marker-idempotent.sh 위임
#   2. 워킹트리 cleanliness — SessionStart hook 실행 후 git status --porcelain 빈 출력
#   3. (skip) curl install end-to-end — fixture 환경 필요, 본 phase 범위 초과 (Icebox)
#   4. Governance/test grep — §6.4 마크 / ADR 가이드 / CHANGELOG 룰 + phase16 self-test
#
# 명명 규약: tests/test-phase{N}-integration.sh — spec-17-03 의 첫 자기 적용.
# bash 3.2+ 호환.

set -euo pipefail

SDD_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SDD_ROOT"

pass() { printf "  ✓ %s\n" "$1"; }
skip() { printf "  - %s (skip: %s)\n" "$1" "$2"; }
fail() { printf "  ✗ %s\n" "$1"; echo "    detail: $2"; exit 1; }

echo "Test: phase-17 integration (4 scenarios, 1 skip)"

# ─── Scenario 1: Marker idempotency (위임) ────────────────────────
if bash tests/test-sdd-marker-idempotent.sh >/dev/null 2>&1; then
  pass "Scenario 1: Marker 멱등성 (test-sdd-marker-idempotent 3/3 PASS)"
else
  fail "Scenario 1: test-sdd-marker-idempotent.sh 실패" "(rerun manually for details)"
fi

# ─── Scenario 2: 워킹트리 cleanliness ─────────────────────────────
# SessionStart hook 실행이 tracked 파일을 modify 하지 않음 (cache.json 분리의 핵심 약속).
# untracked 파일은 무시 (본 테스트 자신이 untracked 시점에 실행될 수 있음).
before=$(git diff --name-only)
bash .harness-kit/hooks/check-kit-version.sh >/dev/null 2>&1 || true
after=$(git diff --name-only)
[ "$before" = "$after" ] || fail "Scenario 2: SessionStart hook 이 tracked 파일을 modify" \
  "before: [$before] / after: [$after]"
# installed.json 이 캐시 필드를 갖지 않는지 직접 확인
has_cache=$(jq -r 'has("lastVersionCheck") or has("latestKnownVersion")' .harness-kit/installed.json 2>/dev/null || echo "true")
[ "$has_cache" = "false" ] || fail "Scenario 2: installed.json 에 cache 필드 잔재" "(spec-17-03/17-05 약속 위배)"
pass "Scenario 2: 워킹트리 cleanliness (hook 이 tracked 미수정 + installed.json cache 필드 없음)"

# ─── Scenario 3: curl install end-to-end (skip) ───────────────────
skip "Scenario 3: curl install end-to-end" "fixture 환경 필요 — Icebox"

# ─── Scenario 4: Governance/test grep ─────────────────────────────
# 4-a. §6.4 "Used in" 마크 (sources / mirror 양쪽)
hits=$(grep -Ec "ADR only|RCA only|\(shared\)" sources/governance/constitution.md .harness-kit/agent/constitution.md \
  | awk -F: '{s+=$2} END{print s+0}')
[ "$hits" -ge 10 ] || fail "Scenario 4a: §6.4 마크 hit ($hits) < 10" "(expected ≥5 per file × 2 files)"

# 4-b. ADR 템플릿 stale 가이드 (양쪽)
hits=$(grep -c "stale ADR 검사 대상" sources/templates/adr.md .harness-kit/agent/templates/adr.md \
  | awk -F: '{s+=$2} END{print s+0}')
[ "$hits" -ge 2 ] || fail "Scenario 4b: ADR 템플릿 stale 가이드 hit ($hits) < 2" "(expected 1 per file × 2)"

# 4-c. CLAUDE.md CHANGELOG draft 룰
grep -q "Phase ship 시 CHANGELOG draft" CLAUDE.md \
  || fail "Scenario 4c: CLAUDE.md CHANGELOG draft 룰 부재" ""

# 4-d. phase16-integration self-test
bash tests/test-phase16-integration.sh >/dev/null 2>&1 \
  || fail "Scenario 4d: tests/test-phase16-integration.sh 실패" "(rerun manually)"

pass "Scenario 4: Governance/test grep + phase16 self-test (4 sub-checks PASS)"

echo ""
echo "phase-17 integration: 3 passed / 1 skipped (curl install — Icebox)."
