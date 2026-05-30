#!/usr/bin/env bash
set -uo pipefail

# test-check-secrets-dual-mode.sh
# spec-x-check-secrets-dual-mode:
#   - 직접 git commit 시 (pre-commit.sh → HARNESS_GIT_HOOK_MODE=1) secret 검사 동작
#   - Claude Code 모드 (CLAUDE_TOOL_INPUT_command) 동작
#   - pre-commit.sh 에서 HARNESS_GIT_HOOK_MODE=1 로 check-secrets.sh 호출 여부
#
# 주의: _lib.sh 가 HARNESS_ROOT="$(pwd)" 로 무조건 덮어씀 → 스크립트 실행 시
#       cwd 를 temp repo 로 고정해야 정확한 git diff --cached 대상 확보.

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

# _run_secrets: cwd=repo 에서 check-secrets.sh 실행
# env_prefix: 환경변수 인라인 (예: "HARNESS_GIT_HOOK_MODE=1" 또는 "CLAUDE_TOOL_INPUT_command='git commit -m x'")
_run_secrets() {
  local repo="$1"
  local env_prefix="${2:-}"
  local script="$repo/.harness-kit/hooks/check-secrets.sh"
  bash -c "cd '$repo' && ${env_prefix} bash '$script'" 2>/dev/null
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
# Test 2: HARNESS_GIT_HOOK_MODE=1 (git hook 모드) + AWS 키 staged → 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 2: git hook 모드 + AWS 키 staged → 차단"
REPO2="$(_make_repo)"
_install_hooks "$REPO2"

# AWS 키 패턴 분리: 이 파일 staged 시 AKIA[0-9A-Z]{16} self-trigger 방지
_AKIA_PFX="AKIA"; echo "${_AKIA_PFX}IOSFODNN7EXAMPLE12345" > "$REPO2/secret.sh"
git -C "$REPO2" add secret.sh

exit_code=0
_run_secrets "$REPO2" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 2: git hook 모드에서 AWS 키 staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 2: git hook 모드에서 AWS 키 staged → 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 3: HARNESS_GIT_HOOK_MODE=1 (git hook 모드) + 정상 파일 staged → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 3: git hook 모드 + 정상 파일 staged → 통과"
REPO3="$(_make_repo)"
_install_hooks "$REPO3"

echo "echo hello" > "$REPO3/app.sh"
git -C "$REPO3" add app.sh

exit_code=0
_run_secrets "$REPO3" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 3: git hook 모드에서 정상 파일 → 통과 (exit=0)"
else
  fail "Test 3: git hook 모드에서 정상 파일 → 차단됨 (통과되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 4: Claude Code 모드 + git commit + AWS 키 staged → 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 4: Claude Code 모드 + git commit + AWS 키 staged → 차단"
REPO4="$(_make_repo)"
_install_hooks "$REPO4"

_AKIA_PFX="AKIA"; echo "${_AKIA_PFX}IOSFODNN7EXAMPLE12345" > "$REPO4/secret.sh"
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

_AKIA_PFX="AKIA"; echo "${_AKIA_PFX}IOSFODNN7EXAMPLE12345" > "$REPO5/secret.sh"
git -C "$REPO5" add secret.sh

exit_code=0
_run_secrets "$REPO5" "CLAUDE_TOOL_INPUT_command='git status'" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 5: git status 명령 → secret 검사 skip (exit=0)"
else
  fail "Test 5: git status 명령인데 차단됨 (skip되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 6: 환경변수 없음 (cmd=empty, HARNESS_GIT_HOOK_MODE 미설정) → 안전 탈출 (exit 0)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 6: 환경변수 없음 → 안전 탈출 (exit 0)"
REPO6="$(_make_repo)"
_install_hooks "$REPO6"

_AKIA_PFX="AKIA"; echo "${_AKIA_PFX}IOSFODNN7EXAMPLE12345" > "$REPO6/secret.sh"
git -C "$REPO6" add secret.sh

exit_code=0
_run_secrets "$REPO6" "" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 6: 환경변수 없음 → 안전 탈출 (exit=0)"
else
  fail "Test 6: 환경변수 없음인데 차단됨 (안전 탈출되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 7: pre-commit.sh 가 HARNESS_GIT_HOOK_MODE=1 로 check-secrets.sh 호출 여부
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 7: pre-commit.sh 에 HARNESS_GIT_HOOK_MODE=1 check-secrets.sh 호출 포함"
if grep -q 'HARNESS_GIT_HOOK_MODE=1' "$PRECOMMIT_HOOK" 2>/dev/null; then
  ok "Test 7: pre-commit.sh 에 HARNESS_GIT_HOOK_MODE=1 호출 존재"
else
  fail "Test 7: pre-commit.sh 에 HARNESS_GIT_HOOK_MODE=1 없음"
fi

# ─────────────────────────────────────────────────────────
# Test 8: pre-commit.sh 경유 + AWS 키 staged → 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 8: pre-commit.sh 경유 + AWS 키 staged → 차단"
REPO8="$(_make_repo)"
_install_hooks "$REPO8"

_AKIA_PFX="AKIA"; echo "${_AKIA_PFX}IOSFODNN7EXAMPLE12345" > "$REPO8/secret.sh"
git -C "$REPO8" add secret.sh

exit_code=0
_run_precommit "$REPO8" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 8: pre-commit.sh 경유 AWS 키 staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 8: pre-commit.sh 경유 AWS 키 staged → 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 9: .env 파일 staged → git hook 모드 차단
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 9: git hook 모드 + .env 파일 staged → 차단"
REPO9="$(_make_repo)"
_install_hooks "$REPO9"

# .env 파일 staged 여부로 차단 — 내용은 무관
echo "DUMMY=value" > "$REPO9/.env"
git -C "$REPO9" add .env

exit_code=0
_run_secrets "$REPO9" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 9: git hook 모드에서 .env staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 9: git hook 모드에서 .env staged → 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 10: pre-commit.sh 경유 + 정상 파일 staged → 통과
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 10: pre-commit.sh 경유 + 정상 파일 staged → 통과"
REPO10="$(_make_repo)"
_install_hooks "$REPO10"

echo "echo world" > "$REPO10/app.sh"
git -C "$REPO10" add app.sh

exit_code=0
_run_precommit "$REPO10" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 10: pre-commit.sh 경유 정상 파일 → 통과 (exit=0)"
else
  fail "Test 10: pre-commit.sh 경유 정상 파일 → 차단됨 (통과되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 11: Private Key 패턴 → git hook 모드 차단 (BSD grep -- 필요)
#   macOS BSD grep 에서 _pk_begin 변수 분리로 self-trigger 방지 검증
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 11: git hook 모드 + Private Key staged → 차단"
REPO11="$(_make_repo)"
_install_hooks "$REPO11"

# _pk_begin / KEY_SUFFIX 변수 분리: 이 파일 staged 시 self-trigger 방지
KEY_PFX="-----BEGIN"
KEY_SUFFIX=" RSA PRIVATE KEY-----"
echo "${KEY_PFX}${KEY_SUFFIX}" > "$REPO11/key.pem"
git -C "$REPO11" add key.pem

exit_code=0
_run_secrets "$REPO11" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 11: Private Key staged → 차단됨 (exit=$exit_code)"
else
  fail "Test 11: Private Key staged → 통과 (차단되어야 함, BSD grep -- 미적용 의심)"
fi

# ─────────────────────────────────────────────────────────
# Test 12: env 변수 보간 ${VAR:-default} → 오탐 아님 (통과)
#   spec-x-harness-footguns: ${POSTGRES_PASSWORD:-...} 는 시크릿 값이 아님
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 12: env 보간 password=\${VAR:-default} staged → 통과 (오탐 아님)"
REPO12="$(_make_repo)"
_install_hooks "$REPO12"

# 단일 인용 printf 로 ${...} 리터럴 보존
printf 'export POSTGRES_PASSWORD=${DB_PASSWORD:-default}\n' > "$REPO12/config.sh"
git -C "$REPO12" add config.sh

exit_code=0
_run_secrets "$REPO12" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 12: env 보간 → 통과 (exit=0)"
else
  fail "Test 12: env 보간인데 차단됨 (오탐 — exit=$exit_code)"
fi

# ─────────────────────────────────────────────────────────
# Test 13: placeholder 값 (changeme) → 오탐 아님 (통과)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 13: password: changeme staged → 통과 (placeholder, 오탐 아님)"
REPO13="$(_make_repo)"
_install_hooks "$REPO13"

printf 'password: changeme\napi_key: your_api_key_here\n' > "$REPO13/example.yml"
git -C "$REPO13" add example.yml

exit_code=0
_run_secrets "$REPO13" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 13: placeholder 값 → 통과 (exit=0)"
else
  fail "Test 13: placeholder 인데 차단됨 (오탐 — exit=$exit_code)"
fi

# ─────────────────────────────────────────────────────────
# Test 14: 진짜 하드코딩 시크릿 → 차단 유지 (regression)
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 14: password=하드코딩값 staged → 차단 유지"
REPO14="$(_make_repo)"
_install_hooks "$REPO14"

# 키워드/구분자 분리: 이 스크립트 staged 시 self-trigger 방지 (기존 _AKIA_PFX 컨벤션)
_PW_KEY="password"
printf '%s=Xy9hardcodedP4ssValue\n' "$_PW_KEY" > "$REPO14/leak.sh"
git -C "$REPO14" add leak.sh

exit_code=0
_run_secrets "$REPO14" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  ok "Test 14: 하드코딩 시크릿 → 차단됨 (exit=$exit_code)"
else
  fail "Test 14: 하드코딩 시크릿인데 통과 (차단되어야 함)"
fi

# ─────────────────────────────────────────────────────────
# Test 15: 키워드가 ${..} 보간 내부 + :- 기본값 연산자 → 오탐 아님
#   현장 제보 원본 형태: ${POSTGRES_PASSWORD:-default}
# ─────────────────────────────────────────────────────────
echo ""
echo "▶ Test 15: \${POSTGRES_PASSWORD:-default} 보간 staged → 통과 (현장 제보 형태)"
REPO15="$(_make_repo)"
_install_hooks "$REPO15"

printf 'run: echo ${POSTGRES_PASSWORD:-defaultpass}\n' > "$REPO15/run.sh"
git -C "$REPO15" add run.sh

exit_code=0
_run_secrets "$REPO15" "HARNESS_GIT_HOOK_MODE=1" || exit_code=$?

if [ "$exit_code" -eq 0 ]; then
  ok "Test 15: 보간(:- 연산자) → 통과 (exit=0)"
else
  fail "Test 15: 보간인데 차단됨 (오탐 — exit=$exit_code)"
fi

# ─────────────────────────────────────────────────────────
# 결과
# ─────────────────────────────────────────────────────────
echo ""
echo "───────────────────────────────────────────────────────"
echo " PASS: $PASS  FAIL: $FAIL"
echo "───────────────────────────────────────────────────────"
[ "$FAIL" -eq 0 ]
