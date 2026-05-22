#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) + git pre-commit hook 겸용
# 목적: git commit 시 staged 파일에 시크릿/토큰/키 패턴이 포함되어 있는지 검사
#
# 실행 경로:
#   1. Claude Code PreToolUse (Bash 도구): CLAUDE_TOOL_INPUT_command = "git commit ..."
#   2. pre-commit.sh 에서 직접 호출:       HARNESS_GIT_HOOK_MODE=1
#
# 검사 패턴:
#   - AWS 키: AKIA[0-9A-Z]{16}
#   - Private key: -----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----
#   - 일반 토큰: password=, secret=, token=, api_key= (값이 있는 경우)
#   - .env 파일 staged 여부

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "SECRETS" "block"

cmd="$(hook_tool_input command)"
if [ -n "$cmd" ]; then
  # Claude Code 모드 — git commit 명령만 검사
  if ! echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+commit\b'; then
    exit 0
  fi
elif [ "${HARNESS_GIT_HOOK_MODE:-0}" = "1" ]; then
  # pre-commit.sh 에서 호출 (직접 commit 모드) — 명령어 매칭 불필요
  :
else
  # cmd 없고 git hook 모드도 아님 → 안전 탈출 (Claude Code 환경변수 미제공)
  exit 0
fi

violations=""

# 1. .env 파일이 staged 되어 있는지
env_files="$(git -C "$HARNESS_ROOT" diff --cached --name-only 2>/dev/null | grep -E '(^|/)\.env(\..+)?$')"
if [ -n "$env_files" ]; then
  violations="${violations}  .env 파일 staged: ${env_files}\n"
fi

# 2. staged diff 에서 시크릿 패턴 검색
staged_diff="$(git -C "$HARNESS_ROOT" diff --cached 2>/dev/null)"

if [ -n "$staged_diff" ]; then
  # AWS Access Key (추가된 줄만 검사)
  if echo "$staged_diff" | grep -E '^\+[^+]' | grep -qE 'AKIA[0-9A-Z]{16}'; then
    violations="${violations}  AWS Access Key 패턴 발견 (AKIA...)\n"
  fi

  # Private Key (추가된 줄만 검사 — 제거 라인의 self-trigger 방지)
  # _pk_begin 변수 분리: staged diff 내 리터럴 패턴 매칭 방지
  _pk_begin="-----BEGIN"
  if echo "$staged_diff" | grep -E '^\+[^+]' | grep -qE -- "${_pk_begin}.*(PRIVATE KEY|RSA|EC|OPENSSH)"; then
    violations="${violations}  Private Key 패턴 발견\n"
  fi

  # 일반 시크릿 (추가된 줄만, 값이 있는 경우)
  if echo "$staged_diff" | grep -E '^\+' | grep -qiE '(password|secret|api_key|api_secret|access_token|private_key)[[:space:]]*[=:][[:space:]]*[^[:space:]]+'; then
    violations="${violations}  시크릿 할당 패턴 발견 (password=, secret=, api_key= 등)\n"
  fi

  # GitHub/GitLab 토큰 (추가된 줄만 검사)
  if echo "$staged_diff" | grep -E '^\+[^+]' | grep -qE '(ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|glpat-[a-zA-Z0-9\-]{20,})'; then
    violations="${violations}  GitHub/GitLab 토큰 패턴 발견\n"
  fi
fi

if [ -n "$violations" ]; then
  hook_violation \
    "시크릿/토큰 패턴 감지 — 커밋 전 확인 필요" \
    "$(printf "$violations")" \
    "해결: 해당 파일을 .gitignore 에 추가하거나 시크릿을 환경변수로 분리"
fi

exit 0
