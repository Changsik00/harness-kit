#!/usr/bin/env bash
# harness-kit SDD 알림 dispatcher — NM_NOTIFY_CHANNEL 값에 따라 telegram/discord 헬퍼로 분기
#
# 사용법 (notify-telegram.sh / notify-discord.sh 와 동일 인터페이스):
#   bash .harness-kit/bin/notify.sh "메시지 본문"
#   bash .harness-kit/bin/notify.sh "메시지" "info"
#   bash .harness-kit/bin/notify.sh "메시지" "stop"
#
# 레벨 (info|align|plan|accept|stop|ship|merge|phase) — 하위 헬퍼와 동일.
#
# 채널 라우팅 (환경변수 NM_NOTIFY_CHANNEL):
#   미설정 또는 telegram  → notify-telegram.sh 만 호출
#   discord               → notify-discord.sh  만 호출
#   both                  → 둘 다 호출
#   none                  → 발송 안 함 (silent skip)
#
# 채널은 보통 launcher 가 export (예: discord-nextmarket-system.sh).
# 직접 claude 실행 시 미설정 → telegram 기본 (역호환).
#
# 하위 헬퍼가 없거나 .env.{telegram,discord} 가 없으면 헬퍼 내부에서 silent skip.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MESSAGE="${1:-}"
LEVEL="${2:-info}"

if [ -z "$MESSAGE" ]; then
    echo "Usage: $0 <message> [info|align|plan|accept|stop|ship|merge|phase]" >&2
    exit 1
fi

CHANNEL="${NM_NOTIFY_CHANNEL:-telegram}"

call_helper() {
    local helper="$1"
    local path="$SCRIPT_DIR/$helper"
    [ -f "$path" ] || return 0
    bash "$path" "$MESSAGE" "$LEVEL" || true
}

case "$CHANNEL" in
    telegram) call_helper "notify-telegram.sh" ;;
    discord)  call_helper "notify-discord.sh" ;;
    both)
        call_helper "notify-telegram.sh"
        call_helper "notify-discord.sh"
        ;;
    none)     : ;;
    *)
        # 알 수 없는 값은 telegram 으로 fallback (방어적 기본값)
        call_helper "notify-telegram.sh"
        ;;
esac

exit 0
