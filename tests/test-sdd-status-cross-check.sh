#!/usr/bin/env bash
# tests/test-sdd-status-cross-check.sh
# sdd status 자기 진단 기능 단위 테스트 (TDD Red 단계)
# 검증: 브랜치 패턴 → work mode 추론, phase.md/state.json 불일치 경고, plan.md 누락 경고

set -uo pipefail

PASS=0; FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$PROJECT_ROOT/sources/bin/sdd"
SDD_LIB_DIR="$PROJECT_ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$PROJECT_ROOT/sources/templates"

ok()   { echo "  ✅ PASS: $*"; ((PASS++)); }
fail() { echo "  ❌ FAIL: $*"; ((FAIL++)); }

# ─────────────────────────────────────────────────────────
# Fixture 설정 헬퍼
# ─────────────────────────────────────────────────────────
make_fixture() {
  local dir="$(mktemp -d)"
  mkdir -p "$dir/.claude/state"
  mkdir -p "$dir/backlog"
  mkdir -p "$dir/.harness-kit/bin/lib"
  mkdir -p "$dir/.harness-kit/agent/templates"

  cp "$SDD" "$dir/.harness-kit/bin/sdd"
  for f in "$SDD_LIB_DIR"/*.sh; do
    cp "$f" "$dir/.harness-kit/bin/lib/$(basename "$f")"
  done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do
    cp "$f" "$dir/.harness-kit/agent/templates/$(basename "$f")"
  done

  cat > "$dir/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": null,
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

  git -C "$dir" init -q
  git -C "$dir" config user.email "test@local"
  git -C "$dir" config user.name "test"
  git -C "$dir" commit --allow-empty -m "init" -q

  echo "$dir"
}

# ─────────────────────────────────────────────────────────
# Check 1: 브랜치 패턴 → work mode 추론
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: 브랜치 패턴 → work mode 추론"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT

# spec-{phaseN}-{seq}-{slug} 브랜치 → SDD-P 출력 확인
git -C "$F1" checkout -b "spec-10-01-test-slug" -q 2>/dev/null

status_out1=$(cd "$F1" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out1" | grep -q "SDD-P"; then
  ok "spec-10-01-test-slug 브랜치 → SDD-P work mode 추론됨"
else
  fail "spec-10-01-test-slug 브랜치 → SDD-P 없음 — 출력: $status_out1"
fi

# phase base 브랜치 → phase base 출력 확인
git -C "$F1" checkout -b "phase-10-slug" -q 2>/dev/null

status_out1b=$(cd "$F1" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out1b" | grep -qi "phase base"; then
  ok "phase-10-slug 브랜치 → phase base work mode 추론됨"
else
  fail "phase-10-slug 브랜치 → phase base 없음 — 출력: $status_out1b"
fi

# spec-x-{slug} 브랜치 → SDD-x 출력 확인
git -C "$F1" checkout -b "spec-x-fix" -q 2>/dev/null

status_out1c=$(cd "$F1" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out1c" | grep -q "SDD-x"; then
  ok "spec-x-fix 브랜치 → SDD-x work mode 추론됨"
else
  fail "spec-x-fix 브랜치 → SDD-x 없음 — 출력: $status_out1c"
fi

# main 브랜치 → work mode 관련 내용 출력 확인
git -C "$F1" checkout main -q 2>/dev/null

status_out1d=$(cd "$F1" && bash .harness-kit/bin/sdd status 2>&1)

# main 브랜치에서는 SDD-P/SDD-x/phase base 가 아닌 적절한 상태 표시 (예: main, no spec branch 등)
if echo "$status_out1d" | grep -qiE "main|no.*(spec|branch)|branch.*main"; then
  ok "main 브랜치 → work mode 관련 출력 있음"
else
  fail "main 브랜치 → work mode 관련 출력 없음 — 출력: $status_out1d"
fi

# ─────────────────────────────────────────────────────────
# Check 2: phase.md Done + git 머지됨 → 경고 + 행동 제안
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: phase.md Done + git 머지됨 → 경고 + 행동 제안"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

# state.json: phase=phase-1, spec=null
cat > "$F2/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-1",
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

# phase.md: spec-1-001 이 Done 상태
cat > "$F2/backlog/phase-1.md" <<'EOF'
# phase-1: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-1-001 | merged-feature | P1 | Done | `specs/spec-1-001-merged-feature/` |
<!-- sdd:specs:end -->
EOF

# main 브랜치에 spec-1-001 관련 머지 커밋 생성
git -C "$F2" add -A
git -C "$F2" commit -m "setup" -q
git -C "$F2" commit --allow-empty -m "feat(spec-1-001): merged feature (#1)" -q

status_out2=$(cd "$F2" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out2" | grep -qE "⚠|경고|warn|spec-1-001.*done|done.*spec-1-001"; then
  ok "spec-1-001 Done 상태 + 머지됨 → 경고 메시지 출력됨"
else
  fail "spec-1-001 Done 상태 + 머지됨 → 경고 없음 — 출력: $status_out2"
fi

# ─────────────────────────────────────────────────────────
# Check 3: state.json spec=null + phase=active → 안내
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: state.json spec=null + phase=active → 안내"

F3="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3'" EXIT

# state.json: phase=phase-1, spec=null
cat > "$F3/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-1",
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

# phase.md: 모든 spec 이 Merged 상태
cat > "$F3/backlog/phase-1.md" <<'EOF'
# phase-1: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-1-001 | first | P1 | Merged | `specs/spec-1-001-first/` |
| spec-1-002 | second | P1 | Merged | `specs/spec-1-002-second/` |
<!-- sdd:specs:end -->
EOF

git -C "$F3" add -A
git -C "$F3" commit -m "setup" -q

status_out3=$(cd "$F3" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out3" | grep -qiE "phase done|다음 spec|all.*merged|모든.*merged|phase.*완료"; then
  ok "모든 spec Merged → phase done 또는 다음 spec 안내 출력됨"
else
  fail "모든 spec Merged → 안내 메시지 없음 — 출력: $status_out3"
fi

# ─────────────────────────────────────────────────────────
# Check 4: planAccepted=true + plan.md 없음 → 경고
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: planAccepted=true + plan.md 없음 → 경고"

F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4'" EXIT

# state.json: phase=phase-1, spec=spec-1-001-test, planAccepted=true
cat > "$F4/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-1",
  "spec": "spec-1-001-test",
  "planAccepted": true,
  "lastTestPass": null
}
EOF

# spec 디렉토리는 있지만 plan.md 없음
mkdir -p "$F4/specs/spec-1-001-test"
cat > "$F4/specs/spec-1-001-test/spec.md" <<'EOF'
# spec-1-001-test
내용
EOF

git -C "$F4" add -A
git -C "$F4" commit -m "setup" -q

status_out4=$(cd "$F4" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out4" | grep -qiE "⚠|경고|warn|plan.*없|plan.*miss|plan.*not found|plan.*누락"; then
  ok "planAccepted=true + plan.md 없음 → plan 관련 경고 출력됨"
else
  fail "planAccepted=true + plan.md 없음 → 경고 없음 — 출력: $status_out4"
fi

# ─────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
