#!/usr/bin/env bash
# notify-discord.sh
# harness-kit SDD 워크플로우용 Discord 알림 헬퍼 (notify-telegram.sh 와 1:1 대응)
#
# 사용법:
#   bash .harness-kit/bin/notify-discord.sh "메시지 본문"
#   bash .harness-kit/bin/notify-discord.sh "메시지" "info"
#   bash .harness-kit/bin/notify-discord.sh "메시지" "stop"
#
# 레벨 (2번째 인자, notify-telegram.sh 와 동일):
#   info   - ℹ️  일반 정보 (기본값)
#   align  - 📊  /hk-align 세션 상태 보고
#   plan   - 📝  spec/plan/task 작성 완료
#   accept - ✅  Plan Accept, Execution 모드 진입
#   stop   - 🛑  Hard Stop, 즉시 개입 필요
#   ship   - 🚀  PR 생성 완료
#   merge  - 🎉  Merged, 다음 단계 제안
#   phase  - 🏁  Phase Ship Go/No-Go
#
# 환경변수 (.env.discord 에서 로드):
#   DISCORD_BOT_TOKEN  - Discord 봇 토큰
#   DISCORD_CHANNEL_ID - 발송 대상 채널 ID
#                        (Discord 클라이언트에서 개발자 모드 활성화 →
#                         채널 우클릭 → "채널 ID 복사")
#
# Discord 마크다운 정책 (telegram 과 결정적 차이):
#   - **bold**, *italic*, __underline__, ~~strike~~, `code`, ```block```,
#     > quote, # ## ### heading, - * bullet — 모두 raw 로 전송 (Discord 가 렌더링).
#   - 표 (|col|col|) — Discord 미지원이므로 셀을 " — " 로 join 변환.
#   - [text](url) — 일반 메시지에선 md link 미지원이므로 "text (url)" 변환
#     (Discord 가 url 만 auto-link 처리).
#   - 메시지 본문 길이 제한 2000자 — 1897자 초과 시 "..." truncate.
#
# 이 파일이 없거나 네트워크 실패 시 silent skip (exit 0) — SDD 흐름 영향 없음.

set -uo pipefail

# 프로젝트 루트 찾기 (이 스크립트 위치 기준 2단계 상위)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ENV_FILE="$PROJECT_ROOT/.env.discord"

# .env.discord 없으면 조용히 종료
[ -f "$ENV_FILE" ] || exit 0

# 환경변수 로드
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# 필수 변수 확인 — 둘 중 하나라도 비어있으면 silent skip
if [ -z "${DISCORD_BOT_TOKEN:-}" ] || [ -z "${DISCORD_CHANNEL_ID:-}" ]; then
    exit 0
fi

# 인자 파싱
MESSAGE="${1:-}"
LEVEL="${2:-info}"

if [ -z "$MESSAGE" ]; then
    echo "Usage: $0 <message> [info|align|plan|accept|stop|ship|merge|phase]" >&2
    exit 1
fi

# 명시적 호출이면 cooldown 마커 기록 — 직후 30초 내 hook 자동 알림 차단
# (telegram 과 동일한 마커 파일 공유 — 둘 다 사용 시 한 쪽 명시 호출이
#  다른 쪽 hook 자동 호출까지 함께 차단하여 4중 알림 방지)
if [ "${HARNESS_NOTIFY_FROM_HOOK:-0}" != "1" ]; then
    EXPLICIT_MARKER="${TMPDIR:-/tmp}/notify-explicit-$(basename "$PROJECT_ROOT")"
    date +%s > "$EXPLICIT_MARKER" 2>/dev/null || true
fi

# Discord 호환 마크다운 변환 — 비활성 (의도적)
# Discord 는 bold/italic/code/quote/heading/bullet 등 마크다운을 네이티브 렌더링하므로
# raw 그대로 전송하는 것이 가독성이 좋음. 이 함수는 telegram 의 markdown_simplify 와
# 대칭 위치를 유지하기 위해 보존하지만, 실제 호출은 하지 않음.
# (필요해지면 함수 + 아래 호출 라인 모두 주석 해제)
# markdown_to_discord() {
#     awk '
#         function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
#         /^[[:space:]]*\|[[:space:]:|-]+\|[[:space:]]*$/ { next }
#         /^[[:space:]]*\|.*\|[[:space:]]*$/ {
#             sub(/^[[:space:]]*\|/, "")
#             sub(/\|[[:space:]]*$/, "")
#             n = split($0, c, /\|/)
#             out = ""
#             for (i = 1; i <= n; i++) {
#                 if (i > 1) out = out " — "
#                 out = out trim(c[i])
#             }
#             $0 = out
#         }
#         { print }
#     ' | sed -E '
#         s/\[([^]]+)\]\(([^)]+)\)/\1 (\2)/g
#     '
# }
# MESSAGE=$(printf '%s\n' "$MESSAGE" | markdown_to_discord)

# 레벨별 이모지 prefix (telegram 과 동일)
case "$LEVEL" in
    info)   PREFIX="ℹ️" ;;
    align)  PREFIX="📊" ;;
    plan)   PREFIX="📝" ;;
    accept) PREFIX="✅" ;;
    stop)   PREFIX="🛑" ;;
    ship)   PREFIX="🚀" ;;
    merge)  PREFIX="🎉" ;;
    phase)  PREFIX="🏁" ;;
    *)      PREFIX="ℹ️" ;;
esac

# 프로젝트 이름 (디렉토리명) — Discord 는 bold 지원하므로 강조
REPO_NAME="$(basename "$PROJECT_ROOT")"

# Discord 한 메시지 본문 2000자 제한 대응 — chunking 으로 분할 전송.
# 본문(MESSAGE)을 CHUNK_SIZE 단위로 쪼개 각 청크에 헤더(`prefix [repo] [N/M]`) prepend.
# jq 의 .[a:b] 는 unicode code point 단위라 UTF-8 byte boundary 손상 없음.
# 안전 마진: 헤더 약 60자 여유 → 본문 1700자.
CHUNK_SIZE=1700

command -v jq >/dev/null 2>&1 || exit 0

TOTAL_LEN=$(jq -nr --arg s "$MESSAGE" '$s | length')
NUM_CHUNKS=$(( (TOTAL_LEN + CHUNK_SIZE - 1) / CHUNK_SIZE ))
[ "$NUM_CHUNKS" -lt 1 ] && NUM_CHUNKS=1

i=0
while [ "$i" -lt "$NUM_CHUNKS" ]; do
    START=$(( i * CHUNK_SIZE ))
    END=$(( (i + 1) * CHUNK_SIZE ))
    CHUNK=$(jq -nr --arg s "$MESSAGE" --argjson a $START --argjson b $END '$s[$a:$b]')

    if [ "$NUM_CHUNKS" -eq 1 ]; then
        HEADER="${PREFIX} **[${REPO_NAME}]**"
    else
        HEADER="${PREFIX} **[${REPO_NAME}]** [$((i + 1))/${NUM_CHUNKS}]"
    fi
    FULL_MESSAGE="${HEADER}
${CHUNK}"

    # Discord API 호출
    # Windows Git Bash 의 UTF-8 처리 이슈 회피를 위해 JSON body 를 임시 파일에 쓴 뒤
    # --data-binary @file 로 전송 (telegram helper 와 동일 패턴).
    TMP_BODY=$(mktemp 2>/dev/null || echo "/tmp/notify-discord.$$.$i.json")
    jq -nc --arg c "$FULL_MESSAGE" '{content:$c}' > "$TMP_BODY" 2>/dev/null
    curl -s -X POST \
        -H "Authorization: Bot ${DISCORD_BOT_TOKEN}" \
        -H "Content-Type: application/json" \
        --data-binary "@$TMP_BODY" \
        "https://discord.com/api/v10/channels/${DISCORD_CHANNEL_ID}/messages" \
        --max-time 5 > /dev/null 2>&1 || true
    rm -f "$TMP_BODY" 2>/dev/null || true

    # Discord rate limit (채널당 5 msg / 5s) 대비 청크 사이 짧은 간격
    [ "$((i + 1))" -lt "$NUM_CHUNKS" ] && sleep 0.3

    i=$((i + 1))
done

exit 0
