#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# 목적: 한 커밋의 변경 줄 수가 임계치를 초과하면 경고 (One Task = One Commit 원칙)
#
# 환경변수:
#   HARNESS_DIFF_MAX_LINES  임계치 (기본: 500)

_self() { if [ -n "${BASH_VERSION:-}" ]; then echo "${BASH_SOURCE[0]}"; elif [ -n "${ZSH_VERSION:-}" ]; then echo "${(%):-%x}"; else echo "$0"; fi; }
HOOK_DIR="$(cd "$(dirname "$(_self)")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "DIFF_SIZE" "warn"

cmd="$(hook_tool_input command)"
[ -z "$cmd" ] && exit 0

# git commit 만 검사
if ! echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+commit\b'; then
  exit 0
fi

max_lines="${HARNESS_DIFF_MAX_LINES:-500}"

# staged 변경의 총 줄 수 (추가 + 삭제)
diff_lines="$(git -C "$HARNESS_ROOT" diff --cached --numstat 2>/dev/null | awk '{ add += $1; del += $2 } END { print add + del }')"
[ -z "$diff_lines" ] && exit 0
[ "$diff_lines" = "0" ] && exit 0

if [ "$diff_lines" -gt "$max_lines" ]; then
  hook_violation \
    "커밋 변경량이 ${diff_lines}줄로 임계치(${max_lines}줄) 초과" \
    "One Task = One Commit 원칙에 따라 커밋을 분리하세요" \
    "임계치 조정: HARNESS_DIFF_MAX_LINES=1000"
fi

exit 0
