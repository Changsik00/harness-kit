#!/usr/bin/env bash
# Claude Code 를 Discord 알림 채널과 함께 실행하는 런처 (harness-kit notify dispatcher 연동)
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'

# 스크립트 위치 = 프로젝트 루트 (BASH_SOURCE 기반 — 프로젝트 비종속)
PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_PATH/.env.discord"

echo -e "${CYAN}[*] Working directory: $PROJECT_PATH${NC}"
cd "$PROJECT_PATH"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}[!] .env.discord not found at: $ENV_FILE${NC}"
    echo -e "${YELLOW}    .env.discord.example 를 복사해 토큰을 채우세요:${NC}"
    echo -e "${YELLOW}      cp .env.discord.example .env.discord${NC}"
    exit 1
fi

echo -e "${CYAN}[*] Loading environment variables from .env.discord${NC}"
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [ -z "${DISCORD_BOT_TOKEN:-}" ]; then
    echo -e "${RED}[!] DISCORD_BOT_TOKEN not set${NC}"
    exit 1
fi
echo -e "${GREEN}    [+] DISCORD_BOT_TOKEN loaded${NC}"

# harness-kit notify dispatcher 가 이 세션을 Discord 채널로 인식하도록 export
export NM_NOTIFY_CHANNEL=discord
echo -e "${GREEN}    [+] NM_NOTIFY_CHANNEL=discord${NC}"

echo -e "${CYAN}[*] Starting Claude Code with Discord channel...${NC}"
echo -e "${YELLOW}[!] Running with --dangerously-skip-permissions${NC}"
echo ""

claude --dangerously-skip-permissions \
       --channels plugin:discord@claude-plugins-official \
       "$@"
