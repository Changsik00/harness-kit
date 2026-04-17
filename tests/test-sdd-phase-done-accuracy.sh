#!/usr/bin/env bash
# tests/test-sdd-phase-done-accuracy.sh
# _check_phase_all_merged() 와 compute_next_spec() 정확도 테스트 (TDD Red 단계)
# 검증: Done 잔류 시 "모든 Merged" 미출력, Backlog보다 Done 우선 NEXT, git 기반 phase done 안내
#
# 예상 결과:
#   Check 1: FAIL (버그 — _check_phase_all_merged 가 Done 을 무시해 잘못 출력)
#   Check 2: PASS (정상 동작)
#   Check 3: FAIL (버그 — compute_next_spec 이 Backlog 만 검색해 Done 을 무시)
#   Check 4: FAIL (미구현 — git 기반 phase done 안내 없음)

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

# spec 디렉토리 + archive 필수 파일 생성 헬퍼
setup_spec_for_ship() {
  local dir="$1" phase_id="$2" spec_id="$3"
  local spec_dir="$dir/specs/${spec_id}"
  mkdir -p "$spec_dir"

  cat > "$spec_dir/walkthrough.md" <<'WEOF'
# Walkthrough: test
실제 내용입니다. placeholder 아님.
WEOF
  cat > "$spec_dir/pr_description.md" <<'PEOF'
# feat(test): test description
실제 PR 설명입니다.
PEOF
  cat > "$spec_dir/task.md" <<'TEOF'
# Task List: test
- [x] done
TEOF

  cat > "$dir/.claude/state/current.json" <<EOF
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "$phase_id",
  "spec": "$spec_id",
  "planAccepted": true,
  "lastTestPass": null
}
EOF

  git -C "$dir" add -A
  git -C "$dir" commit -m "setup" -q
}

# ─────────────────────────────────────────────────────────
# Check 1: Done 잔류 시 "모든 Merged" 메시지가 출력되면 안 됨
# 버그: _check_phase_all_merged 가 Done 을 무시하므로 잘못 출력됨 → FAIL 예상
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: Done 잔류 시 ship 출력에 '모든 Merged' 메시지 없어야 함"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT

# phase.md: spec-1-001 = In Progress (archive 대상), spec-1-002 = Done (archive 안 됨)
cat > "$F1/backlog/phase-1.md" <<'EOF'
# phase-1: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-1-001 | feature-a | P1 | In Progress | `specs/spec-1-001-feature-a/` |
| spec-1-002 | feature-b | P1 | Done | `specs/spec-1-002-feature-b/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_ship "$F1" "phase-1" "spec-1-001-feature-a"

cat > "$F1/backlog/queue.md" <<'QEOF'
## 📦 진행 중 Phase
<!-- sdd:active:start -->
- **phase-1** — test — 2 spec
<!-- sdd:active:end -->
## ✅ 완료
<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
QEOF
git -C "$F1" add -A
git -C "$F1" commit -m "add queue" -q

archive_out1=$(cd "$F1" && bash .harness-kit/bin/sdd ship 2>&1)

# Done 이 남아있으므로 "모든 Spec" 또는 "phase done" 메시지가 없어야 함
if echo "$archive_out1" | grep -qE "모든 Spec|모든.*Merged|phase done|모두.*머지"; then
  fail "Done 잔류 시 '모든 Merged' 메시지가 잘못 출력됨 (버그 확인) — 출력: $archive_out1"
else
  ok "Done 잔류 시 '모든 Merged' 메시지 미출력 (올바름)"
fi

# ─────────────────────────────────────────────────────────
# Check 2: 모든 spec이 Merged → "모든 Merged" 메시지 출력
# 현재도 정상 동작 → PASS 예상
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: 모든 spec Merged → ship 출력에 '모든 Merged' 메시지 있어야 함"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

# phase.md: spec-2-001 하나만 있고 In Progress
cat > "$F2/backlog/phase-2.md" <<'EOF'
# phase-2: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-2-001 | solo-spec | P1 | In Progress | `specs/spec-2-001-solo-spec/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_ship "$F2" "phase-2" "spec-2-001-solo-spec"

# queue.md 필요 (cmd_ship → queue_set_active_progress)
cat > "$F2/backlog/queue.md" <<'QEOF'
## 📦 진행 중 Phase
<!-- sdd:active:start -->
- **phase-2** — test — 1 spec
<!-- sdd:active:end -->
## ✅ 완료
<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
QEOF
git -C "$F2" add -A
git -C "$F2" commit -m "add queue" -q

archive_out2=$(cd "$F2" && bash .harness-kit/bin/sdd ship 2>&1)

# archive 후 유일한 spec 이 Merged → "모든 Spec" 또는 "phase done" 메시지가 있어야 함
if echo "$archive_out2" | grep -qE "모든 Spec|모든.*Merged|phase done|모두.*머지"; then
  ok "모든 spec Merged → '모든 Merged' 메시지 출력됨"
else
  fail "모든 spec Merged → '모든 Merged' 메시지 없음 — 출력: $archive_out2"
fi

# ─────────────────────────────────────────────────────────
# Check 3: Done + Backlog 혼재 시 NEXT 가 Done spec 이어야 함
# 버그: compute_next_spec 이 Backlog 만 검색 → NEXT = spec-3-002 → FAIL 예상
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: Done + Backlog 혼재 → sdd status NEXT 가 Done spec(spec-3-001) 이어야 함"

F3="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3'" EXIT

# phase.md: spec-3-001 = Done, spec-3-002 = Backlog
cat > "$F3/backlog/phase-3.md" <<'EOF'
# phase-3: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-3-001 | done-first | P1 | Done | `specs/spec-3-001-done-first/` |
| spec-3-002 | backlog-second | P1 | Backlog | — |
<!-- sdd:specs:end -->
EOF

# state.json: phase=phase-3, spec=null
cat > "$F3/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-3",
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

git -C "$F3" add -A
git -C "$F3" commit -m "setup" -q

status_out3=$(cd "$F3" && bash .harness-kit/bin/sdd status 2>&1)

# Done 이 Backlog 보다 우선이므로 NEXT 에 spec-3-001 이 포함되어야 함
if echo "$status_out3" | grep -E "NEXT" | grep -q "spec-3-001"; then
  ok "Done + Backlog 혼재 → NEXT = spec-3-001 (Done 우선)"
else
  next_line=$(echo "$status_out3" | grep "NEXT" || echo "(NEXT 라인 없음)")
  fail "Done + Backlog 혼재 → NEXT 에 spec-3-001 없음 (compute_next_spec 버그) — NEXT 라인: $next_line"
fi

# ─────────────────────────────────────────────────────────
# Check 4: git 기준 모든 spec 머지됨 + phase.md Done 잔류
#          → sdd status 에 "phase done 가능" 또는 "git 기준 모든 spec 머지" 안내 있어야 함
# 미구현 → FAIL 예상
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: git 기준 모든 spec 머지 + phase.md Done 잔류 → status 에 phase done 안내 있어야 함"

F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4'" EXIT

# phase.md: spec-4-001 = Done (유일한 spec)
cat > "$F4/backlog/phase-4.md" <<'EOF'
# phase-4: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-4-001 | only-done | P1 | Done | `specs/spec-4-001-only-done/` |
<!-- sdd:specs:end -->
EOF

# state.json: phase=phase-4, spec=null
cat > "$F4/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": "phase-4",
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null
}
EOF

git -C "$F4" add -A
git -C "$F4" commit -m "setup" -q

# main 브랜치에 spec-4-001 관련 머지 커밋 추가 (git 기준 머지됨 시뮬레이션)
git -C "$F4" commit --allow-empty -m "feat(spec-4-001): only done feature (#1)" -q

status_out4=$(cd "$F4" && bash .harness-kit/bin/sdd status 2>&1)

# "git 기준 모든 spec 머지 완료 → phase done 가능" 안내가 있어야 함
# 기존 경고 "⚠ spec-4-001: phase.md(Done) ↔ git(머지됨)" 와 구분되어야 함
# 즉, 개별 spec 경고가 아니라 phase 전체 완료 안내가 필요함
if echo "$status_out4" | grep -qE "phase.*done.*가능|모든.*spec.*git|git.*모든.*머지|phase.*완료.*가능|모두.*머지.*phase"; then
  ok "git 기준 모든 spec 머지 → phase done 안내 출력됨"
else
  fail "git 기준 모든 spec 머지 → phase done 안내 없음 (미구현) — 출력: $status_out4"
fi

# ─────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "  (TDD Red: Check 1·3·4 FAIL 예상, Check 2 PASS 예상)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
