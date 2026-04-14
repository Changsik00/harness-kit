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
for p in .harness-kit .claude CLAUDE.md; do
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

# 3. .claude/settings.json 에서 hooks 제거
SETTINGS="$TARGET/.claude/settings.json"
if [ -f "$SETTINGS" ] && command -v jq >/dev/null; then
  tmp="$(mktemp)"
  jq 'del(.hooks)' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  ok ".claude/settings.json 에서 hooks 제거 (사용자 권한은 보존)"
fi

# 4. .claude/commands/ — 키트가 깔았을만한 파일 제거
KIT_COMMANDS="align spec-new plan-accept spec-status handoff phase-new phase-status task-done archive"
for c in $KIT_COMMANDS; do
  rm -f "$TARGET/.claude/commands/$c.md" 2>/dev/null || true
done
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
if [ -f "$TARGET/.gitignore" ]; then
  tmp="$(mktemp)"
  awk '
    /^# harness-kit$/ { skip=2; next }
    skip > 0 && /^\.claude\/state\// { skip--; next }
    skip > 0 && /^\.harness-backup-\*\// { skip--; next }
    { print }
  ' "$TARGET/.gitignore" > "$tmp"
  mv "$tmp" "$TARGET/.gitignore"
  ok ".gitignore 정리"
fi

echo ""
log "${C_GRN}제거 완료${C_RST}"
log "되돌리려면: cp -rf $BACKUP/* $TARGET/"
