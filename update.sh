#!/usr/bin/env bash
# harness-kit updater
#
# Usage:
#   ./update.sh                    # 현재 디렉토리 갱신
#   ./update.sh /path/to/project   # 지정 디렉토리 갱신
#   ./update.sh --yes              # 모든 프롬프트 자동 수락
#
# 동작:
#   1. prefix / 버전 읽기 (uninstall 전)
#   2. uninstall --yes --keep-state
#   3. install --yes [--prefix ...]
#   4. cleanup (백업 디렉토리 정리)
#   5. doctor

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -t 1 ]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YLW=$'\033[33m'
  C_CYN=$'\033[36m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YLW=""; C_CYN=""; C_DIM=""; C_RST=""
fi
log()  { echo "${C_CYN}[update]${C_RST} $*"; }
ok()   { echo "${C_GRN}✓${C_RST} $*"; }
warn() { echo "${C_YLW}⚠${C_RST} $*" >&2; }
err()  { echo "${C_RED}✗${C_RST} $*" >&2; }
die()  { err "$*"; exit 1; }

# ── 인자 파싱 ────────────────────────────────────────────────
TARGET=""
ASSUME_YES=0

for arg in "$@"; do
  case "$arg" in
    --yes|-y)  ASSUME_YES=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        die "알 수 없는 옵션: $arg" ;;
    *)         [ -z "$TARGET" ] || die "대상 디렉토리는 하나만 지정 가능"; TARGET="$arg" ;;
  esac
done
[ -z "$TARGET" ] && TARGET="$(pwd)"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || die "대상 디렉토리가 존재하지 않음"

INSTALLED_JSON="$TARGET/.harness-kit/installed.json"
[ -f "$INSTALLED_JSON" ] || die "$TARGET 에 harness-kit 이 설치되어 있지 않습니다. (설치: $KIT_DIR/install.sh $TARGET)"

# ── 버전 / prefix 읽기 (uninstall 전에) ──────────────────────
PREV_VER=$(jq -r '.kitVersion // "unknown"' "$INSTALLED_JSON")
NEW_VER=$(cat "$KIT_DIR/VERSION")

HK_PREFIX=""
HK_GITIGNORE_ARG=""
_CONFIG="$TARGET/.harness-kit/harness.config.json"
if [ -f "$_CONFIG" ] && command -v jq >/dev/null 2>&1; then
  _bd=$(jq -r '.backlogDir // empty' "$_CONFIG" 2>/dev/null || true)
  # backlogDir 에서 prefix 역산: "hk-backlog" → "hk-"
  if [ -n "$_bd" ] && [ "$_bd" != "backlog" ]; then
    HK_PREFIX="${_bd%backlog}"
  fi
  # gitignore 설정 보존
  _gi=$(jq -r 'if has("gitignore") then (.gitignore | tostring) else "true" end' "$_CONFIG" 2>/dev/null || echo "true")
  if [ "$_gi" = "false" ]; then
    HK_GITIGNORE_ARG="--no-gitignore"
  else
    HK_GITIGNORE_ARG="--gitignore"
  fi
fi

echo ""
log "버전: ${C_YLW}${PREV_VER}${C_RST} → ${C_GRN}${NEW_VER}${C_RST}"
[ -n "$HK_PREFIX" ] && log "prefix: ${C_CYN}${HK_PREFIX}${C_RST}"
echo ""

# ── preflight 스캔 ────────────────────────────────────────────
semver_lt() {
  local IFS=.
  local i
  # shellcheck disable=SC2206
  local a=($1) b=($2)
  for ((i=0; i<3; i++)); do
    local x=${a[i]:-0} y=${b[i]:-0}
    if ((x < y)); then return 0; fi
    if ((x > y)); then return 1; fi
  done
  return 1
}

_pf_warn=0

if semver_lt "$NEW_VER" "$PREV_VER"; then
  warn "다운그레이드: $PREV_VER → $NEW_VER"
  _pf_warn=$((_pf_warn + 1))
fi

if [ -f "$TARGET/agent/constitution.md" ] || [ -f "$TARGET/scripts/harness/bin/sdd" ]; then
  warn "v0.3 레이아웃 잔재 감지 — cleanup 대상"
  _pf_warn=$((_pf_warn + 1))
fi

if [ $ASSUME_YES -eq 0 ]; then
  printf "진행할까요? [y/N] "
  read -r _ans < /dev/tty 2>/dev/null || read -r _ans 2>/dev/null || _ans=""
  case "$_ans" in y|Y) ;; *) log "취소됨"; exit 0 ;; esac
fi

# ── 1. uninstall (state 보존) ────────────────────────────────
log "기존 설치 제거 중..."
"$KIT_DIR/uninstall.sh" --yes --keep-state "$TARGET"

# ── 2. state 임시 저장 (install.sh 가 덮어쓰므로) ────────────
# spec-15-05: exclusion 정책 — install 이 fresh 작성하는 키 (kitVersion, installedAt)
# 만 제외하고 나머지 모든 키 보존. 새 state 필드 추가 시 update.sh 손대지 않음.
_STATE="$TARGET/.claude/state/current.json"
_SAVED_JSON='{}'
if command -v jq >/dev/null 2>&1 && [ -f "$_STATE" ]; then
  _SAVED_JSON=$(jq -c 'del(.kitVersion, .installedAt)' \
    "$_STATE" 2>/dev/null || echo '{}')
fi

# ── 3. install ───────────────────────────────────────────────
log "재설치 중..."
PREFIX_ARG=""
[ -n "$HK_PREFIX" ] && PREFIX_ARG="--prefix $HK_PREFIX"
# shellcheck disable=SC2086
"$KIT_DIR/install.sh" --yes $PREFIX_ARG $HK_GITIGNORE_ARG "$TARGET"

# ── 4. state 복원 (jq * merge 로 백업 객체를 새 state 위에 덮어씀) ─
# 백업에 없는 키 (kitVersion, installedAt) 는 install 이 쓴 새 값을 유지.
if command -v jq >/dev/null 2>&1 && [ -f "$_STATE" ] && [ "$_SAVED_JSON" != '{}' ]; then
  _tmp="$(mktemp)"
  if jq --argjson saved "$_SAVED_JSON" '. * $saved' \
       "$_STATE" > "$_tmp" 2>/dev/null; then
    mv "$_tmp" "$_STATE"
    ok "state 복원 완료"
  else
    warn "state 복원 실패 — 기본값으로 초기화"
    rm -f "$_tmp"
  fi
fi

# ── 5. cleanup (버전별 정리) ───────────────────────────────
if [ -f "$KIT_DIR/cleanup.sh" ]; then
  log "버전별 정리 실행 중..."
  "$KIT_DIR/cleanup.sh" --from "$PREV_VER" --to "$NEW_VER" --yes "$TARGET" || warn "cleanup 일부 실패 (계속 진행)"
fi

# ── 6. cleanup (백업 디렉토리 정리) ─────────────────────────
_backup_count=0
while IFS= read -r -d '' d; do
  rm -rf "$d"
  _backup_count=$((_backup_count + 1))
done < <(find "$TARGET" -maxdepth 1 \
  \( -name '.harness-backup-*' -o -name '.harness-uninstall-backup-*' \) \
  -type d -print0 2>/dev/null)
[ "$_backup_count" -gt 0 ] && ok "백업 디렉토리 ${_backup_count}개 정리"

# ── 7. doctor ────────────────────────────────────────────────
echo ""
log "doctor 점검"
"$KIT_DIR/doctor.sh" "$TARGET" || true

echo ""
echo "${C_GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
echo "${C_GRN}업데이트 완료: ${PREV_VER} → ${NEW_VER}${C_RST}"
echo "${C_GRN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RST}"
echo ""
