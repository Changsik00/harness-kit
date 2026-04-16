#!/usr/bin/env bash
# tests/test-sdd-archive-completion.sh
# sdd archive 완료 흐름 단위 테스트
# 검증: phase.md 상태 전이, state.json 초기화, NEXT 안내, specx done

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

  # sdd 바이너리 복사 (심링크 대신 복사 — bash 가 BASH_SOURCE 기준으로 lib 을 찾으므로)
  cp "$SDD" "$dir/.harness-kit/bin/sdd"
  for f in "$SDD_LIB_DIR"/*.sh; do
    cp "$f" "$dir/.harness-kit/bin/lib/$(basename "$f")"
  done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do
    cp "$f" "$dir/.harness-kit/agent/templates/$(basename "$f")"
  done

  # 초기 state.json
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

# spec 디렉토리 + 필수 파일 생성 헬퍼
setup_spec_for_archive() {
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

  # state.json
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

  # git add all
  git -C "$dir" add -A
  git -C "$dir" commit -m "setup" -q
}

# ─────────────────────────────────────────────────────────
# Check 1: sdd archive 후 phase.md spec 상태 In Progress → Merged
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: sdd archive → phase.md spec 상태 In Progress → Merged"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT

cat > "$F1/backlog/phase-1.md" <<'EOF'
# phase-1: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-1-001 | test-a | P1 | In Progress | `specs/spec-1-001-test-a/` |
| spec-1-002 | test-b | P1 | Backlog | `specs/spec-1-002-test-b/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_archive "$F1" "phase-1" "spec-1-001-test-a"

(cd "$F1" && bash .harness-kit/bin/sdd archive >/dev/null 2>&1)

status_after=$(grep "spec-1-001" "$F1/backlog/phase-1.md" | grep -o "Merged" || echo "NOT_MERGED")

if [ "$status_after" = "Merged" ]; then
  ok "spec-1-001 상태 = Merged (In Progress → Merged)"
else
  fail "spec-1-001 상태 expected=Merged got=$(grep 'spec-1-001' "$F1/backlog/phase-1.md")"
fi

# ─────────────────────────────────────────────────────────
# Check 2: sdd archive 후 phase.md spec 상태 Active → Merged
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: sdd archive → phase.md spec 상태 Active → Merged"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

cat > "$F2/backlog/phase-2.md" <<'EOF'
# phase-2: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-2-001 | only-one | P1 | Active | `specs/spec-2-001-only-one/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_archive "$F2" "phase-2" "spec-2-001-only-one"

(cd "$F2" && bash .harness-kit/bin/sdd archive >/dev/null 2>&1)

status_after2=$(grep "spec-2-001" "$F2/backlog/phase-2.md" | grep -o "Merged" || echo "NOT_MERGED")

if [ "$status_after2" = "Merged" ]; then
  ok "spec-2-001 상태 = Merged (Active → Merged)"
else
  fail "spec-2-001 상태 expected=Merged got=$(grep 'spec-2-001' "$F2/backlog/phase-2.md")"
fi

# ─────────────────────────────────────────────────────────
# Check 2b: sdd archive 후 phase.md spec 상태 Done → Merged
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2b: sdd archive → phase.md spec 상태 Done → Merged"

F2b="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F2b'" EXIT

cat > "$F2b/backlog/phase-2b.md" <<'EOF'
# phase-2b: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-2b-001 | done-test | P1 | Done | `specs/spec-2b-001-done-test/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_archive "$F2b" "phase-2b" "spec-2b-001-done-test"

(cd "$F2b" && bash .harness-kit/bin/sdd archive >/dev/null 2>&1)

status_after2b=$(grep "spec-2b-001" "$F2b/backlog/phase-2b.md" | grep -o "Merged" || echo "NOT_MERGED")

if [ "$status_after2b" = "Merged" ]; then
  ok "spec-2b-001 상태 = Merged (Done → Merged)"
else
  fail "spec-2b-001 상태 expected=Merged got=$(grep 'spec-2b-001' "$F2b/backlog/phase-2b.md")"
fi

# ─────────────────────────────────────────────────────────
# Check 3: sdd archive 후 state.json 초기화 (spec=null, planAccepted=false)
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: sdd archive 후 state.json 초기화"

# F1 의 state.json 확인 (Check 1 에서 이미 archive 실행됨)
spec_val=$(jq -r '.spec' "$F1/.claude/state/current.json")
plan_val=$(jq -r '.planAccepted' "$F1/.claude/state/current.json")

if [ "$spec_val" = "null" ] && [ "$plan_val" = "false" ]; then
  ok "state.json: spec=null, planAccepted=false"
else
  fail "state.json: spec=$spec_val (expected null), planAccepted=$plan_val (expected false)"
fi

# ─────────────────────────────────────────────────────────
# Check 4: 모든 spec Merged → phase done 유도 메시지
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: 모든 spec Merged → phase done 유도 메시지"

# F2 에서 spec-2-001 하나뿐이므로 archive 후 모든 spec Merged
# 다시 실행하지 않고 출력을 캡처해야 하므로 새 fixture 생성
F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4'" EXIT

cat > "$F4/backlog/phase-4.md" <<'EOF'
# phase-4: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-4-001 | single | P1 | In Progress | `specs/spec-4-001-single/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_archive "$F4" "phase-4" "spec-4-001-single"

archive_out4=$(cd "$F4" && bash .harness-kit/bin/sdd archive 2>&1)

if echo "$archive_out4" | grep -q "phase done"; then
  ok "phase done 유도 메시지 출력됨"
else
  fail "phase done 유도 메시지 없음 — 출력: $archive_out4"
fi

# ─────────────────────────────────────────────────────────
# Check 5: 잔여 Backlog 있으면 NEXT 안내 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 5: 잔여 Backlog 있으면 NEXT 안내 출력"

F5="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4' '$F5'" EXIT

cat > "$F5/backlog/phase-5.md" <<'EOF'
# phase-5: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| `spec-5-001` | first | P1 | In Progress | `specs/spec-5-001-first/` |
| `spec-5-002` | second | P1 | Backlog | — |
<!-- sdd:specs:end -->
EOF

setup_spec_for_archive "$F5" "phase-5" "spec-5-001-first"

archive_out5=$(cd "$F5" && bash .harness-kit/bin/sdd archive 2>&1)

if echo "$archive_out5" | grep -q "다음:"; then
  ok "NEXT spec 안내 출력됨"
else
  fail "NEXT spec 안내 없음 — 출력: $archive_out5"
fi

# ─────────────────────────────────────────────────────────
# Check 6: sdd specx done <slug> → queue.md specx→done 이동
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 6: sdd specx done <slug> → queue.md specx→done 이동"

F6="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4' '$F5' '$F6'" EXIT

cat > "$F6/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": null,
  "spec": "spec-x-fix-typo",
  "planAccepted": true,
  "lastTestPass": null
}
EOF

cat > "$F6/backlog/queue.md" <<'EOF'
## 📥 spec-x 대기
<!-- sdd:specx:start -->
- [ ] spec-x-fix-typo — 오탈자 수정
<!-- sdd:specx:end -->
## ✅ 완료
<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
EOF

git -C "$F6" add -A
git -C "$F6" commit -m "setup" -q

(cd "$F6" && bash .harness-kit/bin/sdd specx done fix-typo >/dev/null 2>&1)

specx_section=$(sed -n '/sdd:specx:start/,/sdd:specx:end/p' "$F6/backlog/queue.md")
done_section=$(sed -n '/sdd:done:start/,/sdd:done:end/p' "$F6/backlog/queue.md")

has_in_specx=$(echo "$specx_section" | grep -c "fix-typo" || true)
has_in_done=$(echo "$done_section" | grep -c "fix-typo" || true)

if [ "$has_in_specx" -eq 0 ] && [ "$has_in_done" -gt 0 ]; then
  ok "spec-x-fix-typo: specx 섹션 제거 + done 섹션 추가"
else
  fail "specx=$has_in_specx done=$has_in_done (expected: specx=0 done>0)"
fi

# ─────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
