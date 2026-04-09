#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# 목적: main 브랜치에서 git commit / git push 를 차단 (constitution §9.1)
#
# 동작:
#   - HARNESS_HOOK_MODE=warn (기본): 위반 시 stderr 출력 + exit 0
#   - HARNESS_HOOK_MODE=block:        위반 시 stderr 출력 + exit 2 (차단)
#   - HARNESS_HOOK_MODE=off:          즉시 통과

# 자기 자신 위치에서 lib 찾기
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$HOOK_DIR/_lib.sh"

cmd="$(hook_tool_input command)"
[ -z "$cmd" ] && exit 0

# git commit / git push 만 검사
if ! echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+(commit|push)\b'; then
  exit 0
fi

branch="$(hook_branch)"
[ -z "$branch" ] && exit 0

if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
  hook_violation \
    "main 브랜치 직접 작업 금지 (constitution §9.1)" \
    "현재 브랜치: $branch" \
    "명령:        $cmd" \
    "해결: feature 브랜치 생성 후 다시 시도" \
    "       git checkout -b spec-{phaseN}-{seq}-{slug}"
fi

exit 0
