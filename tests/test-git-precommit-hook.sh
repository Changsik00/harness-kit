#!/usr/bin/env bash
set -uo pipefail

# test-git-precommit-hook.sh
# spec-x-hook-bypass-fix: pre-commit.sh 동작 + install/uninstall/doctor 통합 검증

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$ROOT/sources/hooks/pre-commit.sh"

PASS=0; FAIL=0

ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

echo "═══════════════════════════════════════════════════════"
echo " test-git-precommit-hook (spec-x-hook-bypass-fix)"
echo "═══════════════════════════════════════════════════════"

# ── 헬퍼: harness 상태 파일 주입 ─────────────────────────
_inject_state() {
  local repo="$1" plan_accepted="$2"
  mkdir -p "$repo/.claude/state" "$repo/.harness-kit/hooks"
  printf '{"planAccepted":%s}' "$plan_accepted" > "$repo/.claude/state/current.json"
  cp "$ROOT/sources/hooks/_lib.sh"          "$repo/.harness-kit/hooks/"
  cp "$ROOT/sources/hooks/check-staged-lint.sh" "$repo/.harness-kit/hooks/"
  cp "$HOOK"                                "$repo/.harness-kit/hooks/pre-commit.sh"
  chmod +x "$repo/.harness-kit/hooks/"*.sh
}

_make_repo() {
  local d; d="$(mktemp -d)"; CLEANUP+=("$d")
  git -C "$d" init -q
  git -C "$d" checkout -b main 2>/dev/null || true
  git -C "$d" config user.email "test@local"
  git -C "$d" config user.name "test"
  echo "$d"
}

# ─────────────────────────────────────────────────────────
# Test 1: pre-commit.sh 파일 존재 확인
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 1: sources/hooks/pre-commit.sh 존재"
if [ -f "$HOOK" ]; then
  ok "Test 1: pre-commit.sh 존재"
else
  fail "Test 1: pre-commit.sh 없음 ($HOOK)"
fi

# ─────────────────────────────────────────────────────────
# Test 2: planAccepted=false + production 파일 staged → exit 1 (차단)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 2: planAccepted=false + production 파일 staged → 차단"
REPO2="$(_make_repo)"
_inject_state "$REPO2" "false"

echo "echo hello" > "$REPO2/src.sh"
git -C "$REPO2" add src.sh

if HARNESS_ROOT="$REPO2" bash "$REPO2/.harness-kit/hooks/pre-commit.sh" 2>/dev/null; then
  fail "Test 2: 차단되어야 하는데 통과됨"
else
  ok "Test 2: production 파일 staged → 차단됨 (exit non-zero)"
fi

# ─────────────────────────────────────────────────────────
# Test 3: planAccepted=false + whitelist 파일 staged → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 3: planAccepted=false + whitelist 파일(*.md) staged → 통과"
REPO3="$(_make_repo)"
_inject_state "$REPO3" "false"

echo "# doc" > "$REPO3/README.md"
git -C "$REPO3" add README.md

if HARNESS_ROOT="$REPO3" bash "$REPO3/.harness-kit/hooks/pre-commit.sh" 2>/dev/null; then
  ok "Test 3: whitelist 파일 staged → 통과"
else
  fail "Test 3: whitelist 파일인데 차단됨"
fi

# ─────────────────────────────────────────────────────────
# Test 4: planAccepted=true + production 파일 staged → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 4: planAccepted=true + production 파일 staged → 통과"
REPO4="$(_make_repo)"
_inject_state "$REPO4" "true"

echo "echo world" > "$REPO4/app.sh"
git -C "$REPO4" add app.sh

if HARNESS_ROOT="$REPO4" bash "$REPO4/.harness-kit/hooks/pre-commit.sh" 2>/dev/null; then
  ok "Test 4: planAccepted=true → 통과"
else
  fail "Test 4: planAccepted=true인데 차단됨"
fi

# ─────────────────────────────────────────────────────────
# Test 5: install 후 .git/hooks/pre-commit 생성 확인
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 5: install 후 .git/hooks/pre-commit 생성"
REPO5="$(_make_repo)"
bash "$ROOT/install.sh" --yes "$REPO5" >/dev/null 2>&1

if [ -f "$REPO5/.git/hooks/pre-commit" ] && [ -x "$REPO5/.git/hooks/pre-commit" ]; then
  ok "Test 5: .git/hooks/pre-commit 생성 및 실행 권한 확인"
else
  fail "Test 5: .git/hooks/pre-commit 없거나 실행 권한 없음"
fi

# ─────────────────────────────────────────────────────────
# Test 6: .git/hooks/pre-commit에 harness 마커 블록 포함
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 6: pre-commit 파일에 harness 마커 블록 포함"
if grep -q "harness-kit:start" "$REPO5/.git/hooks/pre-commit" 2>/dev/null; then
  ok "Test 6: harness 마커 블록 존재"
else
  fail "Test 6: harness 마커 블록 없음"
fi

# ─────────────────────────────────────────────────────────
# Test 7: install 멱등성 — 재설치 후 마커 블록 중복 없음
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 7: 재설치 후 harness 마커 블록 중복 없음"
bash "$ROOT/install.sh" --yes "$REPO5" >/dev/null 2>&1

marker_count=$(grep -c "harness-kit:start" "$REPO5/.git/hooks/pre-commit" 2>/dev/null || echo "0")
if [ "$marker_count" -eq 1 ]; then
  ok "Test 7: 마커 블록 중복 없음 (count=1)"
else
  fail "Test 7: 마커 블록 중복 발생 (count=$marker_count)"
fi

# ─────────────────────────────────────────────────────────
# Test 8: uninstall 후 harness 블록 제거
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 8: uninstall 후 harness 블록 제거"
bash "$ROOT/uninstall.sh" --yes "$REPO5" >/dev/null 2>&1

if grep -q "harness-kit:start" "$REPO5/.git/hooks/pre-commit" 2>/dev/null; then
  fail "Test 8: uninstall 후에도 harness 블록 남아있음"
else
  ok "Test 8: uninstall 후 harness 블록 제거됨"
fi

# ─────────────────────────────────────────────────────────
# Test 9: --no-hooks 시 pre-commit 미설치
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 9: install --no-hooks 시 .git/hooks/pre-commit 미생성"
REPO9="$(_make_repo)"
bash "$ROOT/install.sh" --yes --no-hooks "$REPO9" >/dev/null 2>&1

if [ ! -f "$REPO9/.git/hooks/pre-commit" ]; then
  ok "Test 9: --no-hooks → pre-commit 미생성"
else
  fail "Test 9: --no-hooks인데 pre-commit 생성됨"
fi

# ─────────────────────────────────────────────────────────
# Test 10: doctor — pre-commit 없을 때 WARN 출력
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 10: doctor — .git/hooks/pre-commit 없을 때 WARN"
REPO10="$(_make_repo)"
bash "$ROOT/install.sh" --yes "$REPO10" >/dev/null 2>&1
rm -f "$REPO10/.git/hooks/pre-commit"

doctor_out=$(bash "$ROOT/doctor.sh" "$REPO10" 2>&1)
if echo "$doctor_out" | grep -qi "pre-commit.*미설치\|미설치.*pre-commit\|git.*hook.*없\|pre-commit.*없"; then
  ok "Test 10: doctor가 .git/hooks/pre-commit 미설치 경고 출력"
else
  fail "Test 10: doctor가 .git/hooks/pre-commit 미설치 감지 못함"
fi

# ─────────────────────────────────────────────────────────
# Test 11: 재설치 후 실행 권한 복구
# 시나리오: install → chmod 제거(버그 재현) → 재설치 → 권한 복구 확인
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 11: 재설치 후 .git/hooks/pre-commit 실행 권한 복구"
REPO11="$(_make_repo)"
bash "$ROOT/install.sh" --yes "$REPO11" >/dev/null 2>&1
# 버그 재현: 실행 권한 제거
chmod 600 "$REPO11/.git/hooks/pre-commit"
# 재설치 (마커 이미 존재 → append 스킵 경로)
bash "$ROOT/install.sh" --yes "$REPO11" >/dev/null 2>&1

if [ -x "$REPO11/.git/hooks/pre-commit" ]; then
  ok "Test 11: 재설치 후 실행 권한 복구됨"
else
  fail "Test 11: 재설치 후에도 실행 권한 없음 (chmod +x 누락 버그)"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
