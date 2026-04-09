#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash)
# 목적: 최근 N분 안에 테스트 PASS 기록이 없으면 git commit 차단
#       (constitution §7, §8.1 — No Test, No Commit)
#
# state 파일의 lastTestPass 가 N분 이내인지 확인.
# 사용자가 수동으로 테스트 통과를 기록하려면:
#   bin/sdd test passed       (테스트 직후 호출 권장)

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
source "$HOOK_DIR/_lib.sh"

# 임계 시간 (분). 환경변수로 조정 가능.
WINDOW_MIN="${HARNESS_TEST_WINDOW_MIN:-30}"

cmd="$(hook_tool_input command)"
[ -z "$cmd" ] && exit 0

# git commit 만 검사 (push 는 다른 hook 또는 hand-off 가 책임)
echo "$cmd" | grep -qE '^[[:space:]]*git[[:space:]]+commit\b' || exit 0

# docs / chore 만 단독으로 커밋하는 경우는 면제 (test 없는 commit 합법화)
if echo "$cmd" | grep -qE '\b(docs|chore|style)\([^)]*\):'; then
  exit 0
fi

last_pass="$(hook_state lastTestPass)"
if [ -z "$last_pass" ] || [ "$last_pass" = "null" ]; then
  hook_violation \
    "테스트 통과 기록 없음 (constitution §8.1)" \
    "lastTestPass 가 비어있습니다." \
    "해결: 테스트 실행 후 ${HC_DIM}bin/sdd test passed${HC_RST} 호출"
fi

# 시간 차이 (초) 계산 — macOS / GNU date 모두 호환
# 입력은 UTC 타임스탬프 ("...Z") 라고 가정. macOS date 는 -ju 로 UTC 강제 필요.
to_epoch() {
  local ts="$1"
  # macOS BSD date
  if date -ju -f "%Y-%m-%dT%H:%M:%SZ" "$ts" +%s 2>/dev/null; then
    return
  fi
  # GNU date (Linux)
  date -u -d "$ts" +%s 2>/dev/null || echo 0
}

now_epoch=$(date -u +%s)
last_epoch=$(to_epoch "$last_pass")
diff_min=$(( (now_epoch - last_epoch) / 60 ))

if [ "$diff_min" -gt "$WINDOW_MIN" ]; then
  hook_violation \
    "테스트 통과 기록이 오래됨 (${diff_min}분 전, 임계: ${WINDOW_MIN}분)" \
    "lastTestPass: $last_pass" \
    "해결: 테스트 재실행 후 bin/sdd test passed 호출" \
    "      또는 임계 조정: HARNESS_TEST_WINDOW_MIN=60"
fi

exit 0
