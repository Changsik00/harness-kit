#!/usr/bin/env bash
# Stop hook
# 목적: Turbo 모드에서 Claude 가 멈출 때 intent.test 또는 precheck 자동 실행
#       실패 시 git revert HEAD --no-edit 수행
#
# 실행 조건:
#   1. mode = turbo
#   2. intent.yaml test 필드 또는 installed.json precheck 중 하나라도 있음
#   3. 최근 커밋이 10분(600초) 이내

set -uo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$HOOK_DIR/_lib.sh"

# Guard 1: turbo 모드가 아니면 no-op
mode="$(hook_state mode)"
[ "$mode" != "turbo" ] && exit 0

# Guard 2: intent.test 또는 precheck 중 하나라도 있어야 실행
intent_file="$HARNESS_ROOT/.claude/state/intent.yaml"
intent_test=""
if [ -f "$intent_file" ]; then
  intent_test=$(grep -E "^test:" "$intent_file" | sed 's/^test:[[:space:]]*//' | head -1)
fi

installed_json="$HARNESS_ROOT/.harness-kit/installed.json"
precheck_count="0"
if [ -f "$installed_json" ]; then
  precheck_count="$(jq '.precheck // [] | length' "$installed_json" 2>/dev/null || echo "0")"
fi

if [ -z "$intent_test" ] && [ "$precheck_count" -eq 0 ]; then
  exit 0
fi

# Guard 3: 최근 커밋이 10분(600초) 이내인지 확인
commit_ts="$(git -C "$HARNESS_ROOT" log -1 --format=%ct 2>/dev/null || echo "0")"
now_ts="$(date +%s)"
age=$(( now_ts - commit_ts ))
if [ "$age" -gt 600 ]; then
  exit 0
fi

# 검증 실행: intent.test 우선, 없으면 precheck fallback
pass=true
fail_cmd=""
fail_out=""

if [ -n "$intent_test" ]; then
  # intent.test 실행
  out=""
  if ! out=$(cd "$HARNESS_ROOT" && bash -c "$intent_test" 2>&1); then
    pass=false
    fail_cmd="$intent_test"
    fail_out="$out"
  fi
else
  # precheck fallback — installed.json 에서 실행
  tmp_cmds=$(mktemp)
  jq -r '.precheck // [] | .[]' "$installed_json" 2>/dev/null > "$tmp_cmds"
  while IFS= read -r cmd; do
    [ -z "$cmd" ] && continue
    out=""
    if ! out=$(cd "$HARNESS_ROOT" && bash -c "$cmd" 2>&1); then
      pass=false
      fail_cmd="$cmd"
      fail_out="$out"
      break
    fi
  done < "$tmp_cmds"
  rm -f "$tmp_cmds"
fi

if [ "$pass" = "true" ]; then
  echo "✓ [turbo:verify] 검증 통과" >&2
  exit 0
fi

# 실패 시 auto-revert
echo "✗ [turbo:verify] 검증 실패 — auto-revert 실행" >&2
echo "  실패 커맨드: $fail_cmd" >&2
[ -n "$fail_out" ] && echo "  출력: $fail_out" >&2
git -C "$HARNESS_ROOT" revert HEAD --no-edit >/dev/null 2>&1 || true
echo "  커밋 revert 완료. 코드 수정 후 재커밋 하세요." >&2
exit 0
