#!/usr/bin/env bash
# tests/test-sdd-phase-activate.sh
# spec-x-sdd-phase-activate: phase activate 신규 명령 + phase new 가드 단위 테스트

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
# Fixture 헬퍼
# ─────────────────────────────────────────────────────────
make_fixture() {
  local dir
  dir="$(mktemp -d)"
  mkdir -p "$dir/.claude/state"
  mkdir -p "$dir/backlog"
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
  "kitVersion": "0.6.2",
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

# 사전 정의 phase 파일 작성 (사용자가 미리 작성한 시나리오 모사)
write_predef_phase() {
  local dir="$1"
  local id="$2"
  local title="$3"
  local base_branch="${4:-}"
  [ -z "$base_branch" ] && base_branch="없음 / \`${id}\` (opt-in)"
  local file="$dir/backlog/${id}.md"
  cat > "$file" <<EOF
# ${id}: ${title}

## 📋 메타

| 항목 | 값 |
|---|---|
| **Phase ID** | \`${id}\` |
| **상태** | Planning |
| **Base Branch** | ${base_branch} |

## 🎯 배경 및 목표

사전 정의된 phase 본문 — 활성화 시 이 내용이 보존되어야 함.
EOF
}

# ─────────────────────────────────────────────────────────
# Check 1: phase activate 정상 동작
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: sdd phase activate phase-03 → state/queue 갱신, 본문 미변경"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT
write_predef_phase "$F1" "phase-03" "STT v2 청킹"

before_md=$(cat "$F1/backlog/phase-03.md")
out=$(cd "$F1" && bash .harness-kit/bin/sdd phase activate phase-03 2>&1)
rc=$?

after_md=$(cat "$F1/backlog/phase-03.md")
state_phase=$(jq -r '.phase' "$F1/.claude/state/current.json")

if [ "$rc" -eq 0 ] && [ "$state_phase" = "phase-03" ]; then
  ok "rc=0, state.phase=phase-03"
else
  fail "rc=$rc, state.phase=$state_phase, out=$out"
fi

if [ "$before_md" = "$after_md" ]; then
  ok "phase-03.md 본문 미변경"
else
  fail "phase-03.md 본문 변경됨 — 본문 보존 정책 위반"
fi

if grep -q "phase-03" "$F1/backlog/queue.md"; then
  ok "queue.md active 마커에 phase-03 표기"
else
  fail "queue.md active 마커에 phase-03 없음"
fi

# ─────────────────────────────────────────────────────────
# Check 2: 파일 없음 → die
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: sdd phase activate phase-99 (파일 없음) → die"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

out=$(cd "$F2" && bash .harness-kit/bin/sdd phase activate phase-99 2>&1)
rc=$?

if [ "$rc" -ne 0 ]; then
  ok "rc=$rc (non-zero)"
else
  fail "rc=$rc (0이면 안 됨)"
fi

# ─────────────────────────────────────────────────────────
# Check 3: 다른 active phase 존재 → die
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: 다른 active phase 존재 시 활성화 거부"

F3="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3'" EXIT
write_predef_phase "$F3" "phase-03" "STT v2"
write_predef_phase "$F3" "phase-04" "다른 phase"

# phase-03을 먼저 활성화
(cd "$F3" && bash .harness-kit/bin/sdd phase activate phase-03 >/dev/null 2>&1)

# phase-04 활성화 시도 → die
out=$(cd "$F3" && bash .harness-kit/bin/sdd phase activate phase-04 2>&1)
rc=$?

state_phase=$(jq -r '.phase' "$F3/.claude/state/current.json")
if [ "$rc" -ne 0 ] && [ "$state_phase" = "phase-03" ]; then
  ok "rc=$rc, state.phase=phase-03 보존"
else
  fail "rc=$rc, state.phase=$state_phase (phase-03 이어야)"
fi

# ─────────────────────────────────────────────────────────
# Check 4: idempotent — 동일 id 재호출 시 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: 동일 id 재활성화 (idempotent)"

out=$(cd "$F3" && bash .harness-kit/bin/sdd phase activate phase-03 2>&1)
rc=$?
state_phase=$(jq -r '.phase' "$F3/.claude/state/current.json")

if [ "$rc" -eq 0 ] && [ "$state_phase" = "phase-03" ]; then
  ok "동일 id 재활성화 rc=0"
else
  fail "동일 id 재활성화 rc=$rc, state.phase=$state_phase"
fi

# ─────────────────────────────────────────────────────────
# Check 5: --base + meta 채워진 케이스
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 5: phase activate --base + meta 채워진 케이스 → 메타값 사용"

F5="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F5'" EXIT
write_predef_phase "$F5" "phase-03" "STT v2" "\`phase-03-stt-v2\`"

out=$(cd "$F5" && bash .harness-kit/bin/sdd phase activate phase-03 --base 2>&1)
rc=$?
base_branch=$(jq -r '.baseBranch' "$F5/.claude/state/current.json")

if [ "$rc" -eq 0 ] && [ "$base_branch" = "phase-03-stt-v2" ]; then
  ok "baseBranch=phase-03-stt-v2 (meta 추출)"
else
  fail "rc=$rc, baseBranch=$base_branch (expected phase-03-stt-v2), out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 6: --base + meta 비어있음 → die
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 6: phase activate --base + meta 비어있음 → die"

F6="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F5' '$F6'" EXIT
write_predef_phase "$F6" "phase-03" "STT v2"  # 기본 meta = "없음 / `phase-03` (opt-in)"

out=$(cd "$F6" && bash .harness-kit/bin/sdd phase activate phase-03 --base 2>&1)
rc=$?
base_branch=$(jq -r '.baseBranch' "$F6/.claude/state/current.json")

if [ "$rc" -ne 0 ] && [ "$base_branch" = "null" ]; then
  ok "rc=$rc, baseBranch=null 보존"
else
  fail "rc=$rc, baseBranch=$base_branch, out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 7: phase new — 사전 정의 phase 존재 시 die
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 7: 사전 정의 phase 존재 시 sdd phase new → die + activate 안내"

F7="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F5' '$F6' '$F7'" EXIT
write_predef_phase "$F7" "phase-03" "사전 정의"

out=$(cd "$F7" && bash .harness-kit/bin/sdd phase new another-slug 2>&1)
rc=$?

if [ "$rc" -ne 0 ]; then
  ok "rc=$rc (non-zero)"
else
  fail "rc=$rc (0이면 안 됨)"
fi

if echo "$out" | grep -q "phase activate"; then
  ok "안내 메시지에 'phase activate' 포함"
else
  fail "안내 메시지에 'phase activate' 없음 — out=$out"
fi

if [ ! -f "$F7/backlog/phase-04.md" ]; then
  ok "phase-04.md 생성되지 않음 (가드 동작)"
else
  fail "phase-04.md 생성됨 (가드 미동작)"
fi

# ─────────────────────────────────────────────────────────
# Check 8: phase new --force → 가드 우회
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 8: sdd phase new --force → 가드 우회, 다음 번호 생성"

out=$(cd "$F7" && bash .harness-kit/bin/sdd phase new another-slug --force 2>&1)
rc=$?

if [ "$rc" -eq 0 ] && [ -f "$F7/backlog/phase-04.md" ]; then
  ok "rc=0, phase-04.md 생성됨"
else
  fail "rc=$rc, phase-04.md 존재=$([ -f "$F7/backlog/phase-04.md" ] && echo yes || echo no), out=$out"
fi

# ─────────────────────────────────────────────────────────
# Check 9: 사전 정의 없을 때 phase new 정상 동작 (회귀)
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 9: 사전 정의 phase 없는 경우 sdd phase new 정상 동작 (회귀)"

F9="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F5' '$F6' '$F7' '$F9'" EXIT

out=$(cd "$F9" && bash .harness-kit/bin/sdd phase new fresh-slug 2>&1)
rc=$?

if [ "$rc" -eq 0 ] && [ -f "$F9/backlog/phase-01.md" ]; then
  ok "rc=0, phase-01.md 생성됨"
else
  fail "rc=$rc, phase-01.md 존재=$([ -f "$F9/backlog/phase-01.md" ] && echo yes || echo no), out=$out"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
