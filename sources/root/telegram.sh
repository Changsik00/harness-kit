#!/usr/bin/env bash
# Claude Code 를 Telegram 알림 채널과 함께 실행하는 런처 (harness-kit notify dispatcher 연동)
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'

# 스크립트 위치 = 프로젝트 루트 (BASH_SOURCE 기반 — 프로젝트 비종속)
PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_PATH/.env.telegram"

echo -e "${CYAN}[*] Working directory: $PROJECT_PATH${NC}"
cd "$PROJECT_PATH"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}[!] .env.telegram not found at: $ENV_FILE${NC}"
    echo -e "${YELLOW}    .env.telegram.example 를 복사해 토큰을 채우세요:${NC}"
    echo -e "${YELLOW}      cp .env.telegram.example .env.telegram${NC}"
    exit 1
fi

echo -e "${CYAN}[*] Loading environment variables from .env.telegram${NC}"
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
    echo -e "${RED}[!] TELEGRAM_BOT_TOKEN not set${NC}"
    exit 1
fi
echo -e "${GREEN}    [+] TELEGRAM_BOT_TOKEN loaded${NC}"

# harness-kit notify dispatcher 가 이 세션을 Telegram 채널로 인식하도록 export
export NM_NOTIFY_CHANNEL=telegram
echo -e "${GREEN}    [+] NM_NOTIFY_CHANNEL=telegram${NC}"

echo -e "${CYAN}[*] Starting Claude Code with Telegram channel...${NC}"
echo -e "${YELLOW}[!] Running with --dangerously-skip-permissions${NC}"
echo ""

claude --dangerously-skip-permissions \
       --channels plugin:telegram@claude-plugins-official \
       "$@"
