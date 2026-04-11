#!/usr/bin/env bash
# tests/test-sdd-archive-completion.sh
# spec-8-003: sdd archive 완료 흐름 강제 단위 테스트

set -uo pipefail

PASS=0; FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SDD="$PROJECT_ROOT/scripts/harness/bin/sdd"
SDD_LIB_DIR="$PROJECT_ROOT/scripts/harness/bin/lib"
SDD_TEMPLATES_DIR="$PROJECT_ROOT/agent/templates"

ok()   { echo "  ✅ PASS: $*"; ((PASS++)); }
fail() { echo "  ❌ FAIL: $*"; ((FAIL++)); }

# ─────────────────────────────────────────────────────────
# Fixture 설정 헬퍼
# ─────────────────────────────────────────────────────────
make_fixture() {
  local dir="$(mktemp -d)"
  mkdir -p "$dir/.claude/state"
  mkdir -p "$dir/backlog"
  mkdir -p "$dir/scripts/harness/bin/lib"
  mkdir -p "$dir/agent/templates"

  ln -s "$SDD" "$dir/scripts/harness/bin/sdd"
  for f in "$SDD_LIB_DIR"/*.sh; do
    ln -s "$f" "$dir/scripts/harness/bin/lib/$(basename "$f")" 2>/dev/null || true
  done
  for f in "$SDD_TEMPLATES_DIR"/*.md; do
    ln -s "$f" "$dir/agent/templates/$(basename "$f")" 2>/dev/null || true
  done

  git -C "$dir" init -q
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

# phase.md 생성 (spec-1-001 In Progress, spec-1-002 Backlog)
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

(cd "$F1" && bash scripts/harness/bin/sdd archive >/dev/null 2>&1)

status_after=$(grep "spec-1-001" "$F1/backlog/phase-1.md" | grep -o "Merged" || echo "NOT_MERGED")

if [ "$status_after" = "Merged" ]; then
  ok "spec-1-001 상태 = Merged"
else
  fail "spec-1-001 상태 expected=Merged got=$(grep 'spec-1-001' "$F1/backlog/phase-1.md")"
fi

# ─────────────────────────────────────────────────────────
# Check 2: 모든 spec Merged → phase done 유도 메시지 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: 모든 spec Merged → phase done 유도 메시지"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

# phase.md: spec-2-001만 있고 In Progress
cat > "$F2/backlog/phase-2.md" <<'EOF'
# phase-2: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-2-001 | only-one | P1 | In Progress | `specs/spec-2-001-only-one/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_archive "$F2" "phase-2" "spec-2-001-only-one"

archive_out=$(cd "$F2" && bash scripts/harness/bin/sdd archive 2>&1)

if echo "$archive_out" | grep -q "phase done"; then
  ok "phase done 유도 메시지 출력됨"
else
  fail "phase done 유도 메시지 없음 — 출력: $archive_out"
fi

# ─────────────────────────────────────────────────────────
# Check 3: 잔여 Backlog 있으면 유도 메시지 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: 잔여 Backlog 있으면 유도 메시지 없음"

# F1 에서 spec-1-002가 아직 Backlog — Check 1 에서 이미 archive 실행됨
# 유도 메시지가 없었는지 확인 (재실행)

F3="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3'" EXIT

cat > "$F3/backlog/phase-3.md" <<'EOF'
# phase-3: test
<!-- sdd:specs:start -->
| ID | 슬러그 | 우선순위 | 상태 | 디렉토리 |
|---|---|:---:|---|---|
| spec-3-001 | first | P1 | In Progress | `specs/spec-3-001-first/` |
| spec-3-002 | second | P1 | Backlog | `specs/spec-3-002-second/` |
<!-- sdd:specs:end -->
EOF

setup_spec_for_archive "$F3" "phase-3" "spec-3-001-first"

archive_out3=$(cd "$F3" && bash scripts/harness/bin/sdd archive 2>&1)

if echo "$archive_out3" | grep -q "phase done"; then
  fail "잔여 Backlog 있는데 phase done 메시지가 출력됨"
else
  ok "잔여 Backlog 있어서 phase done 메시지 없음"
fi

# ─────────────────────────────────────────────────────────
# Check 4: sdd specx done <slug> → queue.md specx→done 이동
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: sdd specx done <slug> → queue.md specx→done 이동"

F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4'" EXIT

# state.json (phase 없음 — spec-x는 phase 비소속)
cat > "$F4/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.3.0",
  "stack": "generic",
  "phase": null,
  "spec": "spec-x-fix-typo",
  "planAccepted": true,
  "lastTestPass": null
}
EOF

# queue.md 생성 (specx 섹션에 항목 있음)
cat > "$F4/backlog/queue.md" <<'EOF'
## 📥 spec-x 대기
<!-- sdd:specx:start -->
- [ ] spec-x-fix-typo — 오탈자 수정
<!-- sdd:specx:end -->
## ✅ 완료
<!-- sdd:done:start -->
없음
<!-- sdd:done:end -->
EOF

git -C "$F4" add -A
git -C "$F4" commit -m "setup" -q

(cd "$F4" && bash scripts/harness/bin/sdd specx done fix-typo >/dev/null 2>&1)

specx_section=$(sed -n '/sdd:specx:start/,/sdd:specx:end/p' "$F4/backlog/queue.md")
done_section=$(sed -n '/sdd:done:start/,/sdd:done:end/p' "$F4/backlog/queue.md")

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
