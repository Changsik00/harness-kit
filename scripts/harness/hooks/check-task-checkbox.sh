#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# 목적: push 전 task.md 에 미완료 체크박스 [ ] 가 남아있지 않은지 검증 (agent.md §6.3)

_self() { if [ -n "${BASH_VERSION:-}" ]; then echo "${BASH_SOURCE[0]}"; elif [ -n "${ZSH_VERSION:-}" ]; then echo "${(%):-%x}"; else echo "$0"; fi; }
HOOK_DIR="$(cd "$(dirname "$(_self)")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "TASK_CHECKBOX" "warn"

cmd="$(hook_tool_input command)"
[ -z "$cmd" ] && exit 0

# git push 만 검사
if ! echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+push\b'; then
  exit 0
fi

# active spec 확인
spec="$(hook_state spec)"
[ -z "$spec" ] && exit 0

task_file="$HARNESS_ROOT/specs/$spec/task.md"
[ ! -f "$task_file" ] && exit 0

# 미완료 체크박스 개수
unchecked="$(grep -c '\- \[ \]' "$task_file" 2>/dev/null || echo "0")"

if [ "$unchecked" -gt 0 ]; then
  hook_violation \
    "task.md 에 미완료 체크박스 ${unchecked}개 남아있음 (agent.md §6.3)" \
    "파일: specs/$spec/task.md" \
    "해결: 모든 항목을 [x] 또는 [-] 로 갱신 후 push"
fi

exit 0
