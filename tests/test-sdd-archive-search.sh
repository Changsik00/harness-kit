#!/usr/bin/env bash
# tests/test-sdd-archive-search.sh
# sdd archive 검색 폴백 단위 테스트
# 검증: spec list 아카이브 표시, phase list 아카이브 표시, phase show 아카이브, status 아카이브 수 진단

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
  local dir
  dir="$(mktemp -d)"
  mkdir -p "$dir/.claude/state"
  mkdir -p "$dir/backlog"
  mkdir -p "$dir/specs"
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

  # 초기 state.json (비활성 상태)
  cat > "$dir/.claude/state/current.json" <<'EOF'
{
  "kitVersion": "0.5.0",
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

# spec 디렉토리 + 최소 파일 생성 헬퍼
make_spec_dir() {
  local dir="$1" spec_slug="$2"
  local spec_dir="$dir/specs/$spec_slug"
  mkdir -p "$spec_dir"
  cat > "$spec_dir/spec.md" <<EOF
# Spec: $spec_slug
테스트용 spec 파일.
EOF
}

# archive spec 디렉토리 + 최소 파일 생성 헬퍼
make_archive_spec_dir() {
  local dir="$1" spec_slug="$2"
  local spec_dir="$dir/archive/specs/$spec_slug"
  mkdir -p "$spec_dir"
  cat > "$spec_dir/spec.md" <<EOF
# Spec: $spec_slug
아카이브된 테스트용 spec 파일.
EOF
}

# state.json 에 active phase/spec 설정
set_active_state() {
  local dir="$1" phase="$2" spec="${3:-null}"
  cat > "$dir/.claude/state/current.json" <<EOF
{
  "kitVersion": "0.5.0",
  "stack": "generic",
  "phase": "$phase",
  "spec": $( [ "$spec" = "null" ] && echo "null" || echo "\"$spec\"" ),
  "planAccepted": false,
  "lastTestPass": null
}
EOF
}

# ─────────────────────────────────────────────────────────
# Check 1: sdd spec list — archive된 spec이 (archived) 표시로 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: sdd spec list — archive된 spec이 (archived) 표시로 포함"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT

# 현재 spec 디렉토리
make_spec_dir "$F1" "spec-01-001-test"

# archive spec 디렉토리
make_archive_spec_dir "$F1" "spec-01-002-test-archived"

git -C "$F1" add -A
git -C "$F1" commit -m "setup" -q

spec_list_out1=$(cd "$F1" && bash .harness-kit/bin/sdd spec list 2>&1)

if echo "$spec_list_out1" | grep -q "spec-01-001-test"; then
  ok "spec list: 현재 spec-01-001-test 포함"
else
  fail "spec list: spec-01-001-test 없음 — 출력: $spec_list_out1"
fi

if echo "$spec_list_out1" | grep -q "spec-01-002-test-archived"; then
  ok "spec list: archive된 spec-01-002-test-archived 포함"
else
  fail "spec list: spec-01-002-test-archived 없음 — 출력: $spec_list_out1"
fi

if echo "$spec_list_out1" | grep -qi "archived"; then
  ok "spec list: 'archived' 표시 포함"
else
  fail "spec list: 'archived' 표시 없음 — 출력: $spec_list_out1"
fi

# ─────────────────────────────────────────────────────────
# Check 2: sdd phase list — archive된 phase가 (archived) 표시로 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: sdd phase list — archive된 phase가 (archived) 표시로 포함"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

# 현재 phase
cat > "$F2/backlog/phase-02.md" <<'EOF'
# phase-02: active test phase
EOF
set_active_state "$F2" "phase-02"

# archive phase
mkdir -p "$F2/archive/backlog"
cat > "$F2/archive/backlog/phase-01.md" <<'EOF'
# phase-01: archived test phase
EOF
make_archive_spec_dir "$F2" "spec-01-001-test-archived"

git -C "$F2" add -A
git -C "$F2" commit -m "setup" -q

phase_list_out2=$(cd "$F2" && bash .harness-kit/bin/sdd phase list 2>&1)

if echo "$phase_list_out2" | grep -q "phase-01"; then
  ok "phase list: archive된 phase-01 포함"
else
  fail "phase list: phase-01 없음 — 출력: $phase_list_out2"
fi

if echo "$phase_list_out2" | grep -qi "archived"; then
  ok "phase list: 'archived' 표시 포함"
else
  fail "phase list: 'archived' 표시 없음 — 출력: $phase_list_out2"
fi

if echo "$phase_list_out2" | grep -q "phase-02"; then
  ok "phase list: 현재 phase-02 포함"
else
  fail "phase list: phase-02 없음 — 출력: $phase_list_out2"
fi

# ─────────────────────────────────────────────────────────
# Check 3: sdd phase show N — archive된 phase 상세 표시
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: sdd phase show phase-01 — archive된 phase 상세 표시"

F3="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3'" EXIT

# archive phase + spec
mkdir -p "$F3/archive/backlog"
cat > "$F3/archive/backlog/phase-01.md" <<'EOF'
# phase-01: archived test phase
EOF
make_archive_spec_dir "$F3" "spec-01-001-test"

git -C "$F3" add -A
git -C "$F3" commit -m "setup" -q

phase_show_out3=$(cd "$F3" && bash .harness-kit/bin/sdd phase show phase-01 2>&1)

if echo "$phase_show_out3" | grep -q "phase-01"; then
  ok "phase show: phase-01 표시"
else
  fail "phase show: phase-01 없음 — 출력: $phase_show_out3"
fi

if echo "$phase_show_out3" | grep -qi "archived"; then
  ok "phase show: 'archived' 표시 포함"
else
  fail "phase show: 'archived' 표시 없음 — 출력: $phase_show_out3"
fi

if echo "$phase_show_out3" | grep -q "spec-01-001-test"; then
  ok "phase show: archive spec-01-001-test 목록 포함"
else
  fail "phase show: spec-01-001-test 없음 — 출력: $phase_show_out3"
fi

# ─────────────────────────────────────────────────────────
# Check 4: sdd status — archive 항목 수 진단 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 4: sdd status — archive 항목 수 진단 포함"

F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F3' '$F4'" EXIT

# 현재 spec들
make_spec_dir "$F4" "spec-02-001-current"
make_spec_dir "$F4" "spec-02-002-current"

# archive에 5개 spec 디렉토리
for i in 1 2 3 4 5; do
  make_archive_spec_dir "$F4" "spec-01-00${i}-archived"
done

# active phase 설정
set_active_state "$F4" "phase-02"

git -C "$F4" add -A
git -C "$F4" commit -m "setup" -q

status_out4=$(cd "$F4" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out4" | grep -qi "archive"; then
  ok "sdd status: 'archive' 관련 출력 포함"
else
  fail "sdd status: 'archive' 없음 — 출력: $status_out4"
fi

# archive 항목 수(5)가 출력에 포함되는지 확인
if echo "$status_out4" | grep -q "5"; then
  ok "sdd status: archive spec 수(5) 출력 포함"
else
  fail "sdd status: archive spec 수 5가 없음 — 출력: $status_out4"
fi

# ─────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
