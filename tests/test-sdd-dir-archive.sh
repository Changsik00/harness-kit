#!/usr/bin/env bash
# tests/test-sdd-dir-archive.sh
# sdd archive 디렉토리 아카이브 명령 단위 테스트
# 검증: --dry-run, 완료 phase 이동, active phase 보존, spec-x 보존, --keep=N, status 제안

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

# queue.md 생성 헬퍼 — done 목록과 active 정보를 받아 생성
make_queue() {
  local dir="$1"
  shift
  # 나머지 인자: done_phases (공백 구분) — "phase-01 phase-02" 형태
  # 마지막 인자로 active_phase 를 받음 (빈 문자열이면 없음)
  local done_phases="$1"
  local active_phase="${2:-}"

  local done_rows=""
  for p in $done_phases; do
    done_rows="${done_rows}| [${p}](${p}.md) | test phase | 1 (Merged) |\n"
  done
  [ -z "$done_rows" ] && done_rows="없음\n"

  local active_block=""
  if [ -n "$active_phase" ]; then
    active_block="## 📦 진행 중 Phase
<!-- sdd:active:start -->
- **${active_phase}** — test — 1 spec
<!-- sdd:active:end -->"
  fi

  cat > "$dir/backlog/queue.md" <<EOF
## ✅ 완료
<!-- sdd:done:start -->
| Phase | 제목 | SPECs |
|-------|------|-------|
$(printf "%b" "$done_rows")
<!-- sdd:done:end -->

$active_block
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
# Check 1: sdd archive --dry-run — 대상 목록만 출력, 파일 이동 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 1: sdd archive --dry-run — 대상 목록만 출력, 파일 이동 없음"

F1="$(make_fixture)"
trap "rm -rf '$F1'" EXIT

# phase-01: done, phase-02: active
make_queue "$F1" "phase-01" "phase-02"
set_active_state "$F1" "phase-02"

# phase-01 용 backlog + spec dirs
cat > "$F1/backlog/phase-01.md" <<'EOF'
# phase-01: test
EOF
cat > "$F1/backlog/phase-02.md" <<'EOF'
# phase-02: test
EOF
make_spec_dir "$F1" "spec-01-001-test"
make_spec_dir "$F1" "spec-02-001-test"

git -C "$F1" add -A
git -C "$F1" commit -m "setup" -q

dry_out1=$(cd "$F1" && bash .harness-kit/bin/sdd archive --dry-run 2>&1)

# spec-01 디렉토리가 아직 존재해야 함
if [ -d "$F1/specs/spec-01-001-test" ]; then
  ok "--dry-run: spec-01 디렉토리 이동 없음"
else
  fail "--dry-run: spec-01 디렉토리가 사라짐 (이동됨)"
fi

# 출력에 "dry-run" 포함 여부
if echo "$dry_out1" | grep -qi "dry-run"; then
  ok "--dry-run: 출력에 'dry-run' 포함"
else
  fail "--dry-run: 출력에 'dry-run' 없음 — 출력: $dry_out1"
fi

# ─────────────────────────────────────────────────────────
# Check 2: sdd archive — 완료 phase 의 spec/backlog 가 archive/ 로 이동
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 2: sdd archive — 완료 phase 의 spec/backlog 가 archive/ 로 이동"

F2="$(make_fixture)"
trap "rm -rf '$F1' '$F2'" EXIT

make_queue "$F2" "phase-01" "phase-02"
set_active_state "$F2" "phase-02"

cat > "$F2/backlog/phase-01.md" <<'EOF'
# phase-01: test
EOF
cat > "$F2/backlog/phase-02.md" <<'EOF'
# phase-02: test
EOF
make_spec_dir "$F2" "spec-01-001-test"
make_spec_dir "$F2" "spec-02-001-test"

git -C "$F2" add -A
git -C "$F2" commit -m "setup" -q

(cd "$F2" && bash .harness-kit/bin/sdd archive 2>&1) || true

# archive/specs/spec-01-001-test/ 존재 확인
if [ -d "$F2/archive/specs/spec-01-001-test" ]; then
  ok "archive/specs/spec-01-001-test/ 존재"
else
  fail "archive/specs/spec-01-001-test/ 없음"
fi

# specs/spec-01-001-test/ 은 사라져야 함
if [ ! -d "$F2/specs/spec-01-001-test" ]; then
  ok "specs/spec-01-001-test/ 이동됨 (원본 없음)"
else
  fail "specs/spec-01-001-test/ 아직 존재 (이동 안 됨)"
fi

# archive/backlog/phase-01.md 존재 확인
if [ -f "$F2/archive/backlog/phase-01.md" ]; then
  ok "archive/backlog/phase-01.md 존재"
else
  fail "archive/backlog/phase-01.md 없음"
fi

# ─────────────────────────────────────────────────────────
# Check 3: active phase 의 spec 은 이동되지 않음
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 3: active phase 의 spec 은 이동되지 않음"

# Check 2 에서 사용한 fixture 그대로 확인
if [ -d "$F2/specs/spec-02-001-test" ]; then
  ok "specs/spec-02-001-test/ 유지 (active phase 보존)"
else
  fail "specs/spec-02-001-test/ 사라짐 (active phase 가 이동됨)"
fi

# ─────────────────────────────────────────────────────────
# Check 4: done 섹션 미등록 spec-x 디렉토리는 보존됨
# ─────────────────────────────────────────────────────────
# (queue.md done 섹션에 spec-x 항목이 없으면 archive 대상에서 제외 — 안전망)
echo ""
echo "Check 4: done 섹션 미등록 spec-x 디렉토리는 보존됨"

F4="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4'" EXIT

make_queue "$F4" "phase-01" ""
# phase-01 done, no active phase, no spec-x in done section

cat > "$F4/backlog/phase-01.md" <<'EOF'
# phase-01: test
EOF
make_spec_dir "$F4" "spec-01-001-test"
make_spec_dir "$F4" "spec-x-fix-typo"

git -C "$F4" add -A
git -C "$F4" commit -m "setup" -q

(cd "$F4" && bash .harness-kit/bin/sdd archive 2>&1) || true

if [ -d "$F4/specs/spec-x-fix-typo" ]; then
  ok "specs/spec-x-fix-typo/ 유지 (done 미등록 spec-x 보존)"
else
  fail "specs/spec-x-fix-typo/ 사라짐 (done 미등록인데 이동됨)"
fi

# ─────────────────────────────────────────────────────────
# Check 5: --keep=1 — 최근 1개 완료 phase 유지
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 5: --keep=1 — 최근 1개 완료 phase 유지"

F5="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4' '$F5'" EXIT

# phase-01, phase-02 모두 done, phase-03 active
make_queue "$F5" "phase-01 phase-02" "phase-03"
set_active_state "$F5" "phase-03"

cat > "$F5/backlog/phase-01.md" <<'EOF'
# phase-01: test
EOF
cat > "$F5/backlog/phase-02.md" <<'EOF'
# phase-02: test
EOF
cat > "$F5/backlog/phase-03.md" <<'EOF'
# phase-03: test
EOF
make_spec_dir "$F5" "spec-01-001-test"
make_spec_dir "$F5" "spec-02-001-test"
make_spec_dir "$F5" "spec-03-001-test"

git -C "$F5" add -A
git -C "$F5" commit -m "setup" -q

(cd "$F5" && bash .harness-kit/bin/sdd archive --keep=1 2>&1) || true

# phase-01 (older done) → 아카이브됨
if [ -d "$F5/archive/specs/spec-01-001-test" ]; then
  ok "--keep=1: phase-01 spec 아카이브됨"
else
  fail "--keep=1: phase-01 spec 아카이브 안 됨"
fi

# phase-02 (most recent done) → 보존됨
if [ -d "$F5/specs/spec-02-001-test" ]; then
  ok "--keep=1: phase-02 spec 유지 (최근 완료 1개 보존)"
else
  fail "--keep=1: phase-02 spec 사라짐 (보존되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Check 6: sdd status — 20개+ 디렉토리 시 아카이브 제안 표시
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 6: sdd status — 20개+ 디렉토리 시 아카이브 제안 표시"

F6="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4' '$F5' '$F6'" EXIT

# 25개 spec-* 디렉토리 생성
for i in $(seq -w 1 25); do
  make_spec_dir "$F6" "spec-01-0${i}-slug${i}"
done

git -C "$F6" add -A
git -C "$F6" commit -m "setup" -q

status_out6=$(cd "$F6" && bash .harness-kit/bin/sdd status 2>&1)

if echo "$status_out6" | grep -q "sdd archive"; then
  ok "sdd status: 25개 디렉토리 → 'sdd archive' 제안 포함"
else
  fail "sdd status: 'sdd archive' 제안 없음 — 출력: $status_out6"
fi

# ─────────────────────────────────────────────────────────
# Check 7: done 섹션 등록 spec-x 는 archive 됨
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 7: done 섹션 등록 spec-x 는 archive 됨"

F7="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4' '$F5' '$F6' '$F7'" EXIT

# queue.md 직접 작성 — done 섹션에 spec-x 추가
cat > "$F7/backlog/queue.md" <<'EOF'
## ✅ 완료
<!-- sdd:done:start -->
| Phase | 제목 | SPECs |
|-------|------|-------|
- [x] spec-x-test-slug (완료)
<!-- sdd:done:end -->
EOF

make_spec_dir "$F7" "spec-x-test-slug"

git -C "$F7" add -A
git -C "$F7" commit -m "setup" -q

(cd "$F7" && bash .harness-kit/bin/sdd archive 2>&1) || true

if [ -d "$F7/archive/specs/spec-x-test-slug" ]; then
  ok "archive/specs/spec-x-test-slug/ 존재 (done 등록 spec-x 이동됨)"
else
  fail "archive/specs/spec-x-test-slug/ 없음 (done 등록 spec-x 가 이동되어야 함)"
fi

if [ ! -d "$F7/specs/spec-x-test-slug" ]; then
  ok "specs/spec-x-test-slug/ 이동됨 (원본 없음)"
else
  fail "specs/spec-x-test-slug/ 아직 존재 (이동되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Check 8: done 섹션 등록 + --dry-run 시 이동 안 됨
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 8: done 섹션 등록 + --dry-run 시 이동 안 됨"

F8="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4' '$F5' '$F6' '$F7' '$F8'" EXIT

cat > "$F8/backlog/queue.md" <<'EOF'
## ✅ 완료
<!-- sdd:done:start -->
| Phase | 제목 | SPECs |
|-------|------|-------|
- [x] spec-x-dryrun-slug (완료)
<!-- sdd:done:end -->
EOF

make_spec_dir "$F8" "spec-x-dryrun-slug"

git -C "$F8" add -A
git -C "$F8" commit -m "setup" -q

dry_out8=$(cd "$F8" && bash .harness-kit/bin/sdd archive --dry-run 2>&1)

if [ -d "$F8/specs/spec-x-dryrun-slug" ]; then
  ok "--dry-run: spec-x-dryrun-slug 이동되지 않음"
else
  fail "--dry-run: spec-x-dryrun-slug 사라짐 (dry-run 인데 이동됨)"
fi

if echo "$dry_out8" | grep -q "spec-x-dryrun-slug"; then
  ok "--dry-run 출력: spec-x-dryrun-slug 이동 대상으로 표시됨"
else
  fail "--dry-run 출력: spec-x-dryrun-slug 누락 — 출력: $dry_out8"
fi

# ─────────────────────────────────────────────────────────
# Check 9: archive commit 은 무관한 워킹트리 변경을 흡수하지 않음
# ─────────────────────────────────────────────────────────
echo ""
echo "Check 9: archive commit 은 무관한 워킹트리 변경을 흡수하지 않음"

F9="$(make_fixture)"
trap "rm -rf '$F1' '$F2' '$F4' '$F5' '$F6' '$F7' '$F8' '$F9'" EXIT

make_queue "$F9" "phase-01" ""

cat > "$F9/backlog/phase-01.md" <<'EOF'
# phase-01: test
EOF
make_spec_dir "$F9" "spec-01-001-test"

# 초기 README 추가하여 setup commit 에 포함
cat > "$F9/README.md" <<'EOF'
initial readme
EOF

git -C "$F9" add -A
git -C "$F9" commit -m "setup" -q

# 무관한 워킹트리 변경 2종 추가 (commit 안 함)
cat > "$F9/unrelated.md" <<'EOF'
unrelated untracked file
EOF
cat > "$F9/README.md" <<'EOF'
modified readme content
EOF

# archive 실행
(cd "$F9" && bash .harness-kit/bin/sdd archive 2>&1) >/dev/null || true

# archive commit 의 변경 파일 목록
archive_files=$(git -C "$F9" show --name-only --pretty="format:" HEAD | grep -v '^$')

# 검증 1: archive commit 에 unrelated.md 가 포함되지 않음
if echo "$archive_files" | grep -q "^unrelated.md$"; then
  fail "archive commit 이 unrelated.md (untracked) 를 흡수함 — 변경 파일: $archive_files"
else
  ok "archive commit 에 unrelated.md 미포함"
fi

# 검증 2: archive commit 에 README.md 변경이 포함되지 않음
if echo "$archive_files" | grep -q "^README.md$"; then
  fail "archive commit 이 README.md (modified) 를 흡수함 — 변경 파일: $archive_files"
else
  ok "archive commit 에 README.md 변경 미포함"
fi

# 검증 3: 워킹트리에 unrelated.md 가 untracked 로 남아있음
if [ -f "$F9/unrelated.md" ] && git -C "$F9" status --porcelain unrelated.md | grep -q "^??"; then
  ok "unrelated.md 가 워킹트리에 untracked 로 보존됨"
else
  fail "unrelated.md 가 보존되지 않음 — status: $(git -C "$F9" status --porcelain unrelated.md)"
fi

# 검증 4: 워킹트리에 README.md modification 이 unstaged 로 남아있음
if git -C "$F9" status --porcelain README.md | grep -q "^.M"; then
  ok "README.md modification 이 워킹트리에 unstaged 로 보존됨"
else
  fail "README.md modification 이 보존되지 않음 — status: $(git -C "$F9" status --porcelain README.md)"
fi

# ─────────────────────────────────────────────────────────
# 결과 요약
# ─────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  결과: PASS=$PASS  FAIL=$FAIL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
[ "$FAIL" -eq 0 ]
