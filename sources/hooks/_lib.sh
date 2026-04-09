#!/usr/bin/env bash
# harness-kit hook 공통 라이브러리
# 각 hook 스크립트가 source 합니다.
#
# 환경변수:
#   HARNESS_HOOK_MODE   warn (기본) / block / off
#                       - warn  : 위반 발견 시 stderr 메시지만 출력하고 exit 0 (통과)
#                       - block : 위반 발견 시 stderr 메시지 출력하고 exit 2 (차단)
#                       - off   : hook 자체를 사실상 비활성 (exit 0 즉시)

set -uo pipefail

# off 모드 → 즉시 통과
if [ "${HARNESS_HOOK_MODE:-warn}" = "off" ]; then
  exit 0
fi

# 색상 (stderr 가 TTY 인 경우만)
if [ -t 2 ]; then
  HC_RED=$'\033[31m'; HC_YLW=$'\033[33m'; HC_DIM=$'\033[2m'; HC_RST=$'\033[0m'
else
  HC_RED=""; HC_YLW=""; HC_DIM=""; HC_RST=""
fi

# 프로젝트 루트 추정 (Claude Code 가 실행 시 cwd = 프로젝트 루트)
HARNESS_ROOT="$(pwd)"
HARNESS_STATE_FILE="$HARNESS_ROOT/.claude/state/current.json"

# 위반 신호: warn 모드면 0 (통과), block 모드면 2 (차단)
hook_violation() {
  local title="$1"; shift
  local mode="${HARNESS_HOOK_MODE:-warn}"

  case "$mode" in
    block)
      echo "${HC_RED}❌ [hook:block] $title${HC_RST}" >&2
      ;;
    warn|*)
      echo "${HC_YLW}⚠ [hook:warn] $title${HC_RST}" >&2
      ;;
  esac

  for line in "$@"; do
    echo "${HC_DIM}   $line${HC_RST}" >&2
  done
  echo "${HC_DIM}   (mode=$mode — block 모드로 전환하려면 환경변수 HARNESS_HOOK_MODE=block)${HC_RST}" >&2

  if [ "$mode" = "block" ]; then
    exit 2
  fi
  exit 0
}

# state 파일에서 키 읽기 (없으면 빈 문자열)
hook_state() {
  local key="$1"
  if [ -f "$HARNESS_STATE_FILE" ] && command -v jq >/dev/null 2>&1; then
    jq -r ".${key} // empty" "$HARNESS_STATE_FILE" 2>/dev/null || echo ""
  fi
}

# 현재 git branch (없으면 빈 문자열)
hook_branch() {
  git -C "$HARNESS_ROOT" branch --show-current 2>/dev/null || echo ""
}

# Claude Code 가 도구 호출 시 전달하는 입력 환경변수 이름은 버전에 따라 다를 수 있음.
# 가장 가능성 높은 후보를 모두 확인.
# bash 3.2 호환: ${key^^} 같은 4+ 문법 사용 금지. tr 로 대문자 변환.
hook_tool_input() {
  local key="$1"   # e.g. command, file_path
  local KEY
  KEY="$(printf '%s' "$key" | tr '[:lower:]' '[:upper:]')"
  local var val
  for var in "CLAUDE_TOOL_INPUT_${key}" "TOOL_INPUT_${key}" "CLAUDE_${KEY}"; do
    eval "val=\${$var:-}"
    if [ -n "$val" ]; then
      printf '%s' "$val"
      return 0
    fi
  done
  printf ''
}
