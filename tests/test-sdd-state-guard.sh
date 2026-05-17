#!/usr/bin/env bash
# tests/test-sdd-state-guard.sh
# spec-x-sdd-state-guard: 활성 spec 보호 가드 단위 테스트
#
# 가드 대상: phase_activate / phase_new / spec_new
# 가드 규칙: state.spec 이 비어있지 않으면 die — --force 로 우회

set -uo pipefail

PASS=0; FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$PROJECT_ROOT/sources/bin/sdd"
SDD_LIB_DIR="$PROJECT_ROOT/sources/bin/lib"
SDD_TEMPLATES_DIR="$PROJECT_ROOT/sources/templates"

ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

# ─────────────────────────────────────────────────────────
# Fixture 헬퍼 — test-sdd-phase-activate.sh 패턴 차용
# ─────────────────────────────────────────────────────────
make_fixture() {
  local dir
  dir="$(mktemp -d)"
  mkdir -p "$dir/.claude/state"
  mkdir -p "$dir/backlog"
  mkdir -p "$dir/specs"
  mkdir -p "$dir/.harness-kit/bin/lib"
  mkdir -p "$dir/.harness-kit/agent/templates"

  cp "$SDD" "$dir/.harness-kit/bin/sdd"
  local f
  for f in "$SDD_LIB_DIR"/*.sh; do
    cp "$f" "$dir/.harness-kit/bin/lib/$(basename "$f")"
  done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do
    cp "$f" "$dir/.harness-kit/agent/templates/$(basename "$f")"
  done

  cat > "$dir/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.10.0",
  "stack": "generic",
  "phase": null,
  "spec": null,
  "planAccepted": false,
  "lastTestPass": null,
  "baseBranch": null
}
EOF

  cp "$SDD_TEMPLATES_DIR/queue.md" "$dir/backlog/queue.md"

  git -C "$dir" init -q
  git -C "$dir" config user.email "test@local"
  git -C "$dir" config user.name "test"
  git -C "$dir" commit --allow-empty -m "init" -q

  echo "$dir"
}

# state.spec 을 특정 값으로 설정 (활성 spec-x / SDD-P spec 시뮬레이션)
set_active_spec() {
  local dir="$1" spec_id="$2"
  local tmp
  tmp="$(mktemp)"
  jq --arg s "$spec_id" '.spec = $s' "$dir/.claude/state/current.json" > "$tmp"
  mv "$tmp" "$dir/.claude/state/current.json"
}

# 사전 정의 phase 파일 작성
write_predef_phase() {
  local dir="$1" id="$2" title="$3"
  cat > "$dir/backlog/${id}.md" <<EOF
# ${id}: ${title}

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | \`${id}\` |
| **상태** | Planning |
| **Base Branch** | 없음 / \`${id}\` (opt-in) |

## 🎯 배경 및 목표

테스트용.
EOF
}

# 활성 phase + 빈 spec 표 상태 만들기 (spec_new 테스트용)
setup_active_phase() {
  local dir="$1" id="$2"
  write_predef_phase "$dir" "$id" "테스트 phase"
  # marker 영역 추가 (spec_new 가 marker append 요구)
  cat >> "$dir/backlog/${id}.md" <<EOF

## SPEC 표

<!-- sdd:specs:start -->
<!-- sdd:specs:end -->
EOF
  (cd "$dir" && bash .harness-kit/bin/sdd phase activate "$id" >/dev/null 2>&1)
}

# ─────────────────────────────────────────────────────────
# Check 1: 활성 spec-x 상태에서 phase activate → die + state 보존
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: 활성 spec-x 상태에서 phase activate → die + state 보존"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT
write_predef_phase "$F1" "phase-03" "STT v2"
set_active_spec "$F1" "spec-x-foo"

out=$(cd "$F1" && bash .harness-kit/bin/sdd phase activate phase-03 2>&1)
rc=$?
state_spec=$(jq -r '.spec' "$F1/.claude/state/current.json")
state_phase=$(jq -r '.phase' "$F1/.claude/state/current.json")

if [ "$rc" -ne 0 ]; then
  ok "rc=$rc (non-zero)"
else
  fail "rc=$rc (0이면 안 됨)"
fi

if [ "$state_spec" = "spec-x-foo" ]; then
  ok "state.spec 보존 = spec-x-foo"
else
  fail "state.spec=$state_spec (보존 실패)"
fi

if [ "$state_phase" = "null" ]; then
  ok "state.phase 보존 = null"
else
  fail "state.phase=$state_phase"
fi

if echo "$out" | grep -q "sdd specx done foo"; then
  ok "안내 메시지에 'sdd specx done foo' 포함"
else
  fail "안내 메시지에 'sdd specx done foo' 없음 — out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 2: 활성 spec-x 상태에서 phase activate --force → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: 활성 spec-x 상태에서 phase activate --force → 통과 + state 덮어쓰기"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT
write_predef_phase "$F2" "phase-03" "STT v2"
set_active_spec "$F2" "spec-x-foo"

out=$(cd "$F2" && bash .harness-kit/bin/sdd phase activate phase-03 --force 2>&1)
rc=$?
state_phase=$(jq -r '.phase' "$F2/.claude/state/current.json")
state_spec=$(jq -r '.spec' "$F2/.claude/state/current.json")

if [ "$rc" -eq 0 ] && [ "$state_phase" = "phase-03" ] && [ "$state_spec" = "null" ]; then
  ok "rc=0, state.phase=phase-03, state.spec=null (force 덮어쓰기 완료)"
else
  fail "rc=$rc, state.phase=$state_phase, state.spec=$state_spec, out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 3: 활성 spec-x 상태에서 phase new → die + state 보존
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: 활성 spec-x 상태에서 phase new <slug> → die + state 보존"

F3="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3'" EXIT
set_active_spec "$F3" "spec-x-bar"

out=$(cd "$F3" && bash .harness-kit/bin/sdd phase new test-phase 2>&1)
rc=$?
state_spec=$(jq -r '.spec' "$F3/.claude/state/current.json")

if [ "$rc" -ne 0 ] && [ "$state_spec" = "spec-x-bar" ]; then
  ok "rc=$rc, state.spec 보존"
else
  fail "rc=$rc, state.spec=$state_spec"
fi

if [ ! -f "$F3/backlog/phase-01.md" ]; then
  ok "phase-01.md 생성되지 않음 (가드 동작)"
else
  fail "phase-01.md 생성됨 (가드 미동작)"
fi

# ─────────────────────────────────────────────────────────
# Check 4: 활성 spec-x 상태에서 phase new --force → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: 활성 spec-x 상태에서 phase new <slug> --force → 통과"

F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4'" EXIT
set_active_spec "$F4" "spec-x-bar"

out=$(cd "$F4" && bash .harness-kit/bin/sdd phase new test-phase --force 2>&1)
rc=$?

if [ "$rc" -eq 0 ] && [ -f "$F4/backlog/phase-01.md" ]; then
  ok "rc=0, phase-01.md 생성됨"
else
  fail "rc=$rc, phase-01.md=$([ -f "$F4/backlog/phase-01.md" ] && echo yes || echo no), out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 5: 활성 SDD-P spec 상태에서 spec new → die + sdd ship 안내
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 5: 활성 SDD-P spec 상태에서 spec new <slug> → die + 'sdd ship' 안내"

F5="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4' '$F5'" EXIT
setup_active_phase "$F5" "phase-03"
set_active_spec "$F5" "spec-03-01-existing"

out=$(cd "$F5" && bash .harness-kit/bin/sdd spec new another-slug 2>&1)
rc=$?
state_spec=$(jq -r '.spec' "$F5/.claude/state/current.json")

if [ "$rc" -ne 0 ] && [ "$state_spec" = "spec-03-01-existing" ]; then
  ok "rc=$rc, state.spec 보존"
else
  fail "rc=$rc, state.spec=$state_spec"
fi

if echo "$out" | grep -q "sdd ship"; then
  ok "안내 메시지에 'sdd ship' 포함"
else
  fail "안내 메시지에 'sdd ship' 없음 — out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 6: 활성 SDD-P spec 상태에서 spec new --force → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 6: 활성 SDD-P spec 상태에서 spec new <slug> --force → 통과"

F6="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4' '$F5' '$F6'" EXIT
setup_active_phase "$F6" "phase-03"
set_active_spec "$F6" "spec-03-01-existing"

out=$(cd "$F6" && bash .harness-kit/bin/sdd spec new another-slug --force 2>&1)
rc=$?

# spec 디렉토리가 만들어졌어야 함
if [ "$rc" -eq 0 ] && ls -d "$F6/specs/spec-03-"*-another-slug >/dev/null 2>&1; then
  ok "rc=0, spec 디렉토리 생성됨"
else
  fail "rc=$rc, spec 디렉토리 미생성, out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 7: 활성 spec 없는 상태 → 회귀 (모든 명령 정상 동작)
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 7: 활성 spec 없는 상태 → 회귀 (가드 미발동)"

F7="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4' '$F5' '$F6' '$F7'" EXIT

# 7a: phase new 정상
out=$(cd "$F7" && bash .harness-kit/bin/sdd phase new fresh-slug 2>&1)
rc=$?
if [ "$rc" -eq 0 ] && [ -f "$F7/backlog/phase-01.md" ]; then
  ok "활성 spec 없음 + phase new → 정상 (회귀 OK)"
else
  fail "phase new 회귀: rc=$rc, out=$out"
fi

# 7b: phase activate 정상 (다른 fixture 로)
F7B="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4' '$F5' '$F6' '$F7' '$F7B'" EXIT
write_predef_phase "$F7B" "phase-03" "STT v2"

out=$(cd "$F7B" && bash .harness-kit/bin/sdd phase activate phase-03 2>&1)
rc=$?
state_phase=$(jq -r '.phase' "$F7B/.claude/state/current.json")
if [ "$rc" -eq 0 ] && [ "$state_phase" = "phase-03" ]; then
  ok "활성 spec 없음 + phase activate → 정상 (회귀 OK)"
else
  fail "phase activate 회귀: rc=$rc, state.phase=$state_phase, out=$out"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
