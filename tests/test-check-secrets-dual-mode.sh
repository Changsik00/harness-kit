#!/usr/bin/env bash
set -uo pipefail

# test-check-secrets-dual-mode.sh
# spec-x-check-secrets-dual-mode:
#   - 직접 git commit 시 (Claude Code 환경변수 없음) secret 검사 동작 여부
#   - pre-commit.sh 에서 check-secrets.sh 호출 여부
#
# 주의: _lib.sh 가 HARNESS_ROOT="$(pwd)" 로 무조건 덮어씀 → 스크립트 실행 시
#       cwd 를 temp repo 로 고정해야 정확한 git diff --cached 대상 확보.
#       bash -c "cd ... && ..." 패턴 사용.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_HOOK="$ROOT/sources/hooks/check-secrets.sh"
PRECOMMIT_HOOK="$ROOT/sources/hooks/pre-commit.sh"

PASS=0; FAIL=0

ok()   { echo "  ✅ PASS: $*"; PASS=$(( PASS + 1 )); }
fail() { echo "  ❌ FAIL: $*"; FAIL=$(( FAIL + 1 )); }

CLEANUP=()
trap 'for d in "${CLEANUP[@]:-}"; do [ -n "$d" ] && [ -d "$d" ] && rm -rf "$d"; done' EXIT

_make_repo() {
  local d; d="$(mktemp -d)"; CLEANUP+=("$d")
  git -C "$d" init -q
  git -C "$d" checkout -b main 2>/dev/null || true
  git -C "$d" config user.email "test@local"
  git -C "$d" config user.name "test"
  echo "$d"
}

_install_hooks() {
  local repo="$1"
  mkdir -p "$repo/.harness-kit/hooks"
  cp "$ROOT/sources/hooks/_lib.sh"          "$repo/.harness-kit/hooks/"
  cp "$ROOT/sources/hooks/check-secrets.sh" "$repo/.harness-kit/hooks/"
  cp "$ROOT/sources/hooks/pre-commit.sh"    "$repo/.harness-kit/hooks/"
  if [ -f "$ROOT/sources/hooks/check-staged-lint.sh" ]; then
    cp "$ROOT/sources/hooks/check-staged-lint.sh" "$repo/.harness-kit/hooks/"
  fi
  chmod +x "$repo/.harness-kit/hooks/"*.sh
}

# _run_secrets: repo 내부에서 check-secrets.sh 실행 (cd → _lib.sh의 pwd = repo)
# 선택적 환경변수 prefix 인자: "CLAUDE_TOOL_INPUT_command=git commit -m x"
_run_secrets() {
  local repo="$1"; shift
  local env_prefix="${1:-}"
  local script="$repo/.harness-kit/hooks/check-secrets.sh"
  if [ -n "$env_prefix" ]; then
    bash -c "cd '$repo' && $env_prefix bash '$script'" 2>/dev/null
  else
    bash -c "cd '$repo' && bash '$script'" 2>/dev/null
  fi
}

_run_precommit() {
  local repo="$1"
  local script="$repo/.harness-kit/hooks/pre-commit.sh"
  bash -c "cd '$repo' && HARNESS_ROOT='$repo' bash '$script'" 2>/dev/null
}

echo "═══════════════════════════════════════════════════════"
echo " test-check-secrets-dual-mode (spec-x-check-secrets-dual-mode)"
echo "═══════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────
# Test 1: check-secrets.sh 파일 존재 확인
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 1: sources/hooks/check-secrets.sh 존재"
if [ -f "$SECRETS_HOOK" ]; then
  ok "Test 1: check-secrets.sh 존재"
else
  fail "Test 1: check-secrets.sh 없음"
fi

# ─────────────────────────────────────────────────────────
# Test 2: Claude Code 환경 없음 + AWS 키 staged → 차단
#   직접 git commit 시나리오: CLAUDE_TOOL_INPUT_command 미설정
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 2: 직접 commit 모드 + AWS 키 staged → 차단"
REPO2="$(_make_repo)"
_install_hooks "$REPO2"

echo "AWS_KEY=AKIAIOSFODNN7EXAMPLE12345" > "$REPO2/secret.sh"
git -C "$REPO2" add secret.sh

exit_code=0
_run_secrets "$REPO2" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 2: 직접 commit 모드에서 AWS 키 staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 2: 직접 commit 모드에서 AWS 키 staged → 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 3: Claude Code 환경 없음 + 정상 파일 staged → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 3: 직접 commit 모드 + 정상 파일 staged → 통과"
REPO3="$(_make_repo)"
_install_hooks "$REPO3"

echo "echo hello" > "$REPO3/app.sh"
git -C "$REPO3" add app.sh

exit_code=0
_run_secrets "$REPO3" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 3: 직접 commit 모드에서 정상 파일 → 통과 (exit=0)"
else
  fail "Test 3: 직접 commit 모드에서 정상 파일 → 차단됨 (통과되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 4: Claude Code 모드 + git commit 명령 + AWS 키 staged → 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 4: Claude Code 모드 + git commit + AWS 키 staged → 차단"
REPO4="$(_make_repo)"
_install_hooks "$REPO4"

echo "AWS_KEY=AKIAIOSFODNN7EXAMPLE12345" > "$REPO4/secret.sh"
git -C "$REPO4" add secret.sh

exit_code=0
_run_secrets "$REPO4" "CLAUDE_TOOL_INPUT_command='git commit -m test'" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 4: Claude Code 모드에서 AWS 키 staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 4: Claude Code 모드에서 AWS 키 staged → 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 5: Claude Code 모드 + git commit 아닌 명령 → skip (exit 0)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 5: Claude Code 모드 + git status + AWS 키 staged → skip"
REPO5="$(_make_repo)"
_install_hooks "$REPO5"

echo "AWS_KEY=AKIAIOSFODNN7EXAMPLE12345" > "$REPO5/secret.sh"
git -C "$REPO5" add secret.sh

exit_code=0
_run_secrets "$REPO5" "CLAUDE_TOOL_INPUT_command='git status'" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 5: git status 명령 → secret 검사 skip (exit=0)"
else
  fail "Test 5: git status 명령인데 차단됨 (skip되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 6: pre-commit.sh 가 check-secrets.sh 호출 구문 포함 여부
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 6: pre-commit.sh 에 check-secrets.sh 호출 포함"
if grep -q 'check-secrets.sh' "$PRECOMMIT_HOOK" 2>/dev/null; then
  ok "Test 6: pre-commit.sh 에 check-secrets.sh 호출 존재"
else
  fail "Test 6: pre-commit.sh 에 check-secrets.sh 호출 없음"
fi

# ─────────────────────────────────────────────────────────
# Test 7: pre-commit.sh 경유 + AWS 키 staged → 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 7: pre-commit.sh 경유 + AWS 키 staged → 차단"
REPO7="$(_make_repo)"
_install_hooks "$REPO7"

echo "AWS_KEY=AKIAIOSFODNN7EXAMPLE12345" > "$REPO7/secret.sh"
git -C "$REPO7" add secret.sh

exit_code=0
_run_precommit "$REPO7" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 7: pre-commit.sh 경유 AWS 키 staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 7: pre-commit.sh 경유 AWS 키 staged → 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 8: .env 파일 staged → 직접 commit 모드 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 8: 직접 commit 모드 + .env 파일 staged → 차단"
REPO8="$(_make_repo)"
_install_hooks "$REPO8"

echo "DB_PASSWORD=supersecret123" > "$REPO8/.env"
git -C "$REPO8" add .env

exit_code=0
_run_secrets "$REPO8" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 8: 직접 commit 모드에서 .env staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 8: 직접 commit 모드에서 .env staged → 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 9: pre-commit.sh 경유 + 정상 파일 staged → 통과 (state 파일 없음)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 9: pre-commit.sh 경유 + 정상 파일 staged → 통과"
REPO9="$(_make_repo)"
_install_hooks "$REPO9"

echo "echo world" > "$REPO9/app.sh"
git -C "$REPO9" add app.sh

exit_code=0
_run_precommit "$REPO9" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 9: pre-commit.sh 경유 정상 파일 → 통과 (exit=0)"
else
  fail "Test 9: pre-commit.sh 경유 정상 파일 → 차단됨 (통과되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
