#!/usr/bin/env bash
# harness-kit uninstaller
#
# Usage:
#   ./uninstall.sh                    # 현재 디렉토리에서 제거
#   ./uninstall.sh /path/to/project   # 지정 디렉토리에서 제거
#   ./uninstall.sh --keep-state       # state 파일 유지
#   ./uninstall.sh --yes              # 확인 프롬프트 생략
#
# 제거 대상:
#   - .harness-kit/                  (전체)
#   - .claude/commands/              (키트가 깐 슬래시만, 가능하면 사용자 것 보존)
#   - .claude/settings.json 의 hooks 키트 항목 (jq 로 제거)
#   - CLAUDE.md 의 HARNESS-KIT 블록
#
# 보존:
#   - backlog/, specs/               (사용자 작업 산출물)
#   - .claude/state/                 (--keep-state 시)

set -euo pipefail

if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'; C_CYN=$'\033[36m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_CYN=""; C_RST=""
fi
log()  { echo "${C_CYN}[uninstall]${C_RST} $*"; }
ok()   { echo "${C_GRN}✓${C_RST} $*"; }
warn() { echo "${C_YLW}⚠${C_RST} $*" >&2; }
err()  { echo "${C_RED}✗${C_RST} $*" >&2; }

TARGET=""
KEEP_STATE=0
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --keep-state) KEEP_STATE=1 ;;
    --yes|-y)     ASSUME_YES=1 ;;
    -h|--help)
      sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)            TARGET="$arg" ;;
  esac
done
[ -z "$TARGET" ] && TARGET="$(pwd)"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { err "대상 디렉토리 없음"; exit 1; }

log "대상: $TARGET"
log "백로그/스펙은 보존됩니다."

if [ $ASSUME_YES -eq 0 ]; then
  read -r -p "정말 제거할까요? [y/N] " ans
  case "$ans" in y|Y|yes|YES) ;; *) log "취소됨"; exit 0 ;; esac
fi

# 백업 (안전망)
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$TARGET/.harness-uninstall-backup-$TS"
mkdir -p "$BACKUP"
for p in .harness-kit .claude CLAUDE.md telegram.sh discord.sh .env.telegram.example .env.discord.example; do
  [ -e "$TARGET/$p" ] && cp -rf "$TARGET/$p" "$BACKUP/" 2>/dev/null || true
done
log "안전 백업: $BACKUP"

# 1. .harness-kit/ 제거 (거버넌스 + bin + hooks 전체)
if [ -d "$TARGET/.harness-kit" ]; then
  rm -rf "$TARGET/.harness-kit"
  ok ".harness-kit/ 제거"
fi

# 1-b. v0.3 old-layout 잔재 정리 (있을 경우)
if [ -d "$TARGET/agent" ] && [ -f "$TARGET/agent/constitution.md" ]; then
  warn "v0.3 잔재 감지: agent/ 제거"
  rm -rf "$TARGET/agent"
fi
if [ -d "$TARGET/scripts/harness" ]; then
  warn "v0.3 잔재 감지: scripts/harness/ 제거"
  rm -rf "$TARGET/scripts/harness"
  rmdir "$TARGET/scripts" 2>/dev/null || true
fi

# 2. 루트 런처 + env 템플릿 제거 (실제 토큰 파일은 보존)
#    telegram.sh/discord.sh/.env.*.example 는 키트가 설치한 것 → 제거.
#    실제 .env.telegram / .env.discord 는 사용자 시크릿이므로 절대 건드리지 않음.
for rf in telegram.sh discord.sh .env.telegram.example .env.discord.example; do
  if [ -f "$TARGET/$rf" ]; then
    rm -f "$TARGET/$rf"
    ok "루트 파일 제거: $rf"
  fi
done

# 3. .claude/settings.json 에서 hooks 제거
SETTINGS="$TARGET/.claude/settings.json"
if [ -f "$SETTINGS" ] && command -v jq >/dev/null; then
  tmp="$(mktemp)"
  jq 'del(.hooks)' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  ok ".claude/settings.json 에서 hooks 제거 (사용자 권한은 보존)"
fi

# 3b. .git/hooks/pre-commit 에서 harness 블록 제거
GIT_HOOK="$TARGET/.git/hooks/pre-commit"
if [ -f "$GIT_HOOK" ] && grep -q "# harness-kit:start" "$GIT_HOOK" 2>/dev/null; then
  tmp="$(mktemp)"
  awk '/# harness-kit:start/{skip=1} skip{if(/# harness-kit:end/){skip=0; next} next} {print}' \
    "$GIT_HOOK" > "$tmp"
  if [ -s "$tmp" ]; then
    mv "$tmp" "$GIT_HOOK"
  else
    rm -f "$GIT_HOOK" "$tmp"
  fi
  ok ".git/hooks/pre-commit 에서 harness 블록 제거"
fi

# 4. .claude/commands/ — 키트가 설치한 슬래시 커맨드 제거
# install.sh 가 installed.json.installedCommands 에 명단을 기록 (spec-15-03).
# .harness-kit/ 는 이미 제거되었으므로 백업 디렉토리에서 installed.json 을 읽는다.
_INSTALLED_BACKUP="$BACKUP/.harness-kit/installed.json"
if command -v jq >/dev/null 2>&1 \
   && [ -f "$_INSTALLED_BACKUP" ] \
   && jq -e '.installedCommands' "$_INSTALLED_BACKUP" >/dev/null 2>&1; then
  # 기록된 명단 사용 (정확)
  while IFS= read -r c; do
    [ -n "$c" ] && rm -f "$TARGET/.claude/commands/${c}.md" 2>/dev/null
  done < <(jq -r '.installedCommands[]' "$_INSTALLED_BACKUP")
else
  # legacy fallback (구 install 또는 jq 미설치) — hk-* glob 일괄 제거
  rm -f "$TARGET/.claude/commands/hk-"*.md 2>/dev/null || true
fi
# 비어있으면 디렉토리 제거
rmdir "$TARGET/.claude/commands" 2>/dev/null || true

# 5. .claude/state/ — KEEP_STATE 가 아니면 제거
if [ $KEEP_STATE -eq 0 ]; then
  rm -rf "$TARGET/.claude/state"
  ok ".claude/state/ 제거"
fi

# 6. CLAUDE.md 의 HARNESS-KIT 블록 제거
if [ -f "$TARGET/CLAUDE.md" ] && grep -q "HARNESS-KIT:BEGIN" "$TARGET/CLAUDE.md"; then
  tmp="$(mktemp)"
  awk '
    /HARNESS-KIT:BEGIN/ { skip=1; next }
    /HARNESS-KIT:END/   { skip=0; next }
    !skip
  ' "$TARGET/CLAUDE.md" > "$tmp"
  # 끝의 빈 줄 정리
  sed -e :a -e '/^$/{$d;N;ba' -e '}' "$tmp" > "$TARGET/CLAUDE.md" 2>/dev/null || mv "$tmp" "$TARGET/CLAUDE.md"
  ok "CLAUDE.md 에서 HARNESS-KIT 블록 제거"
fi

# 7. .gitignore 정리
# '# harness-kit' 헤더 + 그 뒤로 이어지는 키트 관리 라인 블록을 통째로 제거.
# skip=N 카운터 대신 "헤더 직후 연속된 알려진 패턴" 을 명시 매칭 — 순서/개수 무관하게
# .harness-kit/, .harness-backup-*/, .claude/state/, .env.telegram, .env.discord 모두 제거.
# 블록 밖(비-키트 라인) 의 동일 패턴은 건드리지 않아 사용자 시크릿 ignore 라인을 보존.
if [ -f "$TARGET/.gitignore" ]; then
  tmp="$(mktemp)"
  awk '
    /^# harness-kit$/                  { inblk=1; next }
    inblk==1 && /^!?\.harness-kit\/$/   { next }
    inblk==1 && /^\.harness-backup-\*\/$/ { next }
    inblk==1 && /^\.claude\/state\/$/   { next }
    inblk==1 && /^\.env\.telegram$/     { next }
    inblk==1 && /^\.env\.discord$/      { next }
    inblk==1                           { inblk=0 }
    { print }
  ' "$TARGET/.gitignore" > "$tmp"
  # harness 블록은 보통 파일 끝에 append 되므로 leftover 빈 줄 정리
  sed -e :a -e '/^$/{$d;N;ba' -e '}' "$tmp" > "$TARGET/.gitignore" 2>/dev/null || mv "$tmp" "$TARGET/.gitignore"
  rm -f "$tmp"
  ok ".gitignore 정리"
fi

echo ""
log "${C_GRN}제거 완료${C_RST}"
log "되돌리려면: cp -rf $BACKUP/* $TARGET/"
