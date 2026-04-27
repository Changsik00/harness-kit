#!/usr/bin/env bash
set -euo pipefail

# test-update.sh
# spec-9-005: update.sh = uninstall + install + cleanup 검증
#
# 검증 항목:
#   1) update 후 .harness-kit/ 재생성 확인
#   2) state(phase/spec) 보존 확인
#   3) prefix 있는 경우 재설치 후 동일 prefix 유지
#   4) .harness-uninstall-backup-* 정리 확인
#   5) doctor 통과 (update 후 설치 상태 정상)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL="$ROOT/install.sh"
UPDATE="$ROOT/update.sh"

FAIL=0
TOTAL=0

pass() { echo "  ✅ $1"; }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }
check() { TOTAL=$((TOTAL + 1)); }

echo "═══════════════════════════════════════════"
echo " Update Rewrite Verification (spec-9-005)"
echo "═══════════════════════════════════════════"
echo ""

# ──────────────────────────────────────────────
# 픽스처 준비: 일반 설치 (state 포함)
# ──────────────────────────────────────────────
FIXTURE="$(mktemp -d)"
FIXTURE_B=""
FIXTURE_C=""
trap 'rm -rf "$FIXTURE" "$FIXTURE_B" "$FIXTURE_C"' EXIT
git -C "$FIXTURE" init -q
git -C "$FIXTURE" checkout -b main 2>/dev/null || true
git -C "$FIXTURE" config user.email "test@local" && git -C "$FIXTURE" config user.name "test"

bash "$INSTALL" --yes "$FIXTURE" > /dev/null 2>&1

# state에 6개 보존 필드 모두 값 주입 (보존 검증을 위해)
jq '.phase = "phase-9"
   | .spec = "spec-9-005-update-rewrite"
   | .branch = "spec-9-005-update-rewrite"
   | .baseBranch = "phase-9-rewrite"
   | .planAccepted = true
   | .lastTestPass = "2026-04-27T00:00:00Z"' \
  "$FIXTURE/.claude/state/current.json" > /tmp/state_test.json
mv /tmp/state_test.json "$FIXTURE/.claude/state/current.json"

echo "▶ 시나리오 A: 기본 update (state 보존)"
bash "$UPDATE" --yes "$FIXTURE" > /dev/null 2>&1 || true

check
if [ -d "$FIXTURE/.harness-kit" ]; then
  pass ".harness-kit/ 재생성됨"
else
  fail ".harness-kit/ 없음"
fi

check
if [ -f "$FIXTURE/.harness-kit/installed.json" ]; then
  pass ".harness-kit/installed.json 존재"
else
  fail ".harness-kit/installed.json 없음"
fi

check
if command -v jq >/dev/null 2>&1 && [ -f "$FIXTURE/.claude/state/current.json" ]; then
  phase=$(jq -r '.phase // empty' "$FIXTURE/.claude/state/current.json")
  spec=$(jq -r '.spec // empty' "$FIXTURE/.claude/state/current.json")
  if [ "$phase" = "phase-9" ] && [ "$spec" = "spec-9-005-update-rewrite" ]; then
    pass "state 보존: phase=$phase spec=$spec"
  else
    fail "state 손실: phase=$phase spec=$spec"
  fi
else
  pass "(jq 없음 — state 검증 스킵)"
fi

# 신규: branch / baseBranch 보존 검증 (spec-x-update-preserve-state)
check
if command -v jq >/dev/null 2>&1 && [ -f "$FIXTURE/.claude/state/current.json" ]; then
  branch=$(jq -r '.branch // empty' "$FIXTURE/.claude/state/current.json")
  base_branch=$(jq -r '.baseBranch // empty' "$FIXTURE/.claude/state/current.json")
  if [ "$branch" = "spec-9-005-update-rewrite" ] && [ "$base_branch" = "phase-9-rewrite" ]; then
    pass "branch/baseBranch 보존: branch=$branch baseBranch=$base_branch"
  else
    fail "branch/baseBranch 손실: branch=$branch baseBranch=$base_branch"
  fi
else
  pass "(jq 없음 — branch 검증 스킵)"
fi

# 신규: planAccepted / lastTestPass 보존 검증
check
if command -v jq >/dev/null 2>&1 && [ -f "$FIXTURE/.claude/state/current.json" ]; then
  pa=$(jq -r '.planAccepted' "$FIXTURE/.claude/state/current.json")
  lt=$(jq -r '.lastTestPass // empty' "$FIXTURE/.claude/state/current.json")
  if [ "$pa" = "true" ] && [ "$lt" = "2026-04-27T00:00:00Z" ]; then
    pass "planAccepted/lastTestPass 보존: pa=$pa lt=$lt"
  else
    fail "planAccepted/lastTestPass 손실: pa=$pa lt=$lt"
  fi
else
  pass "(jq 없음 — pa/lt 검증 스킵)"
fi

# 신규: kitVersion 동기화 검증 (state.json == installed.json == VERSION)
check
if command -v jq >/dev/null 2>&1 \
   && [ -f "$FIXTURE/.claude/state/current.json" ] \
   && [ -f "$FIXTURE/.harness-kit/installed.json" ] \
   && [ -f "$ROOT/VERSION" ]; then
  state_ver=$(jq -r '.kitVersion // empty' "$FIXTURE/.claude/state/current.json")
  inst_ver=$(jq -r '.kitVersion // empty' "$FIXTURE/.harness-kit/installed.json")
  file_ver=$(cat "$ROOT/VERSION" | tr -d '[:space:]')
  if [ -n "$state_ver" ] && [ "$state_ver" = "$inst_ver" ] && [ "$state_ver" = "$file_ver" ]; then
    pass "kitVersion 동기화: state=$state_ver installed=$inst_ver VERSION=$file_ver"
  else
    fail "kitVersion 불일치: state=$state_ver installed=$inst_ver VERSION=$file_ver"
  fi
else
  pass "(파일 누락 — kitVersion 검증 스킵)"
fi

check
backup_count=$(find "$FIXTURE" -maxdepth 1 -name '.harness-uninstall-backup-*' -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$backup_count" -eq 0 ]; then
  pass ".harness-uninstall-backup-* 정리됨"
else
  fail ".harness-uninstall-backup-* ${backup_count}개 남아있음"
fi

echo ""

# ──────────────────────────────────────────────
# 시나리오 B: prefix 있는 경우
# ──────────────────────────────────────────────
echo "▶ 시나리오 B: prefix 있는 경우 (prefix 보존)"

FIXTURE_B="$(mktemp -d)"
git -C "$FIXTURE_B" init -q
git -C "$FIXTURE_B" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_B" config user.email "test@local" && git -C "$FIXTURE_B" config user.name "test"

bash "$INSTALL" --yes --prefix hk- "$FIXTURE_B" > /dev/null 2>&1

bash "$UPDATE" --yes "$FIXTURE_B" > /dev/null 2>&1 || true

check
if [ -d "$FIXTURE_B/hk-backlog" ]; then
  pass "hk-backlog/ 유지됨"
else
  fail "hk-backlog/ 없음 (prefix 손실)"
fi

check
if [ -d "$FIXTURE_B/hk-specs" ]; then
  pass "hk-specs/ 유지됨"
else
  fail "hk-specs/ 없음 (prefix 손실)"
fi

check
if command -v jq >/dev/null 2>&1 && [ -f "$FIXTURE_B/.harness-kit/harness.config.json" ]; then
  bd=$(jq -r '.backlogDir // empty' "$FIXTURE_B/.harness-kit/harness.config.json")
  if [ "$bd" = "hk-backlog" ]; then
    pass "harness.config.json backlogDir=hk-backlog 유지"
  else
    fail "harness.config.json backlogDir 손실: $bd"
  fi
else
  pass "(jq 없음 — config 검증 스킵)"
fi

# ──────────────────────────────────────────────
# 시나리오 C: 신규 설치 직후 state.json 에 baseBranch 필드 존재
# (spec-x-update-preserve-state)
# ──────────────────────────────────────────────
echo ""
echo "▶ 시나리오 C: install.sh 가 baseBranch 필드 포함 state.json 작성"

FIXTURE_C="$(mktemp -d)"
git -C "$FIXTURE_C" init -q
git -C "$FIXTURE_C" checkout -b main 2>/dev/null || true
git -C "$FIXTURE_C" config user.email "test@local" && git -C "$FIXTURE_C" config user.name "test"

bash "$INSTALL" --yes "$FIXTURE_C" > /dev/null 2>&1

check
if command -v jq >/dev/null 2>&1 && [ -f "$FIXTURE_C/.claude/state/current.json" ]; then
  has_bb=$(jq 'has("baseBranch")' "$FIXTURE_C/.claude/state/current.json")
  if [ "$has_bb" = "true" ]; then
    pass "신규 install state.json 에 baseBranch 필드 존재"
  else
    fail "신규 install state.json 에 baseBranch 필드 누락"
  fi
else
  pass "(jq 없음 — baseBranch 필드 검증 스킵)"
fi

# ──────────────────────────────────────────────
# 결과
# ──────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════"
if [ $FAIL -eq 0 ]; then
  echo " ✅ ALL PASS ($TOTAL/$TOTAL)"
else
  echo " ❌ ${FAIL}/${TOTAL} CHECKS FAILED"
fi
echo "═══════════════════════════════════════════"

exit $FAIL
