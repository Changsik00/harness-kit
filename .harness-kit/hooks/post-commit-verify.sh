#!/usr/bin/env bash
# Stop hook
# 목적: Turbo 모드에서 Claude 가 멈출 때 precheck 자동 실행
#       실패 시 git revert HEAD --no-edit 수행
#
# 실행 조건:
#   1. mode = turbo
#   2. .harness-kit/installed.json 에 precheck 항목 있음
#   3. 최근 커밋이 10분(600초) 이내

set -uo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$HOOK_DIR/_lib.sh"

# Guard 1: turbo 모드가 아니면 no-op
mode="$(hook_state mode)"
[ "$mode" != "turbo" ] && exit 0

# Guard 2: precheck 미설정이면 no-op
installed_json="$HARNESS_ROOT/.harness-kit/installed.json"
if [ ! -f "$installed_json" ]; then
  exit 0
fi

precheck_count="$(jq '.precheck // [] | length' "$installed_json" 2>/dev/null || echo "0")"
[ "$precheck_count" -eq 0 ] && exit 0

# Guard 3: 최근 커밋이 10분(600초) 이내인지 확인
commit_ts="$(git -C "$HARNESS_ROOT" log -1 --format=%ct 2>/dev/null || echo "0")"
now_ts="$(date +%s)"
age=$(( now_ts - commit_ts ))
if [ "$age" -gt 600 ]; then
  exit 0
fi

# precheck 실행 — 실패한 첫 커맨드에서 중단
pass=true
fail_cmd=""
fail_out=""

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
