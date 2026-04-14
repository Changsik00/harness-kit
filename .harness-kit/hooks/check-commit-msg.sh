#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# 목적: 커밋 메시지가 <type>(spec-N-NNN): ... 형식인지 검증 (constitution §9.2)
#
# 허용 type: feat, fix, refactor, test, docs, chore, style, perf, build, ci
# docs(...), chore(...) 등 모두 형식은 지켜야 함

_self() { if [ -n "${BASH_VERSION:-}" ]; then echo "${BASH_SOURCE[0]}"; elif [ -n "${ZSH_VERSION:-}" ]; then echo "${(%):-%x}"; else echo "$0"; fi; }
HOOK_DIR="$(cd "$(dirname "$(_self)")" && pwd)"
source "$HOOK_DIR/_lib.sh"
hook_resolve_mode "COMMIT_MSG" "warn"

cmd="$(hook_tool_input command)"
[ -z "$cmd" ] && exit 0

# git commit 만 검사
if ! echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+commit\b'; then
  exit 0
fi

# -m 뒤의 메시지 추출
msg=""
if echo "$cmd" | grep -qE '\-m[[:space:]]'; then
  msg="$(echo "$cmd" | sed -E 's/.*-m[[:space:]]+["\x27]?([^"\x27]*)["\x27]?.*/\1/')"
fi

[ -z "$msg" ] && exit 0

# 허용 패턴: <type>(<scope>): <description>
# type: feat|fix|refactor|test|docs|chore|style|perf|build|ci
# scope: 자유 (보통 spec-N-NNN)
if echo "$msg" | grep -qE '^(feat|fix|refactor|test|docs|chore|style|perf|build|ci)\(.*\):[[:space:]].+'; then
  exit 0
fi

# Merge commit 허용
if echo "$msg" | grep -qiE '^Merge\b'; then
  exit 0
fi

hook_violation \
  "커밋 메시지 형식 위반 (constitution §9.2)" \
  "메시지: $msg" \
  "형식:   <type>(scope): <description>" \
  "type:   feat|fix|refactor|test|docs|chore|style|perf|build|ci" \
  "예시:   feat(spec-1-001): add webhook lock retry"
